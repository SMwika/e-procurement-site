class TendersController < ApplicationController
  helper_method :sort_column, :sort_direction
  include ApplicationHelper
  include QueryHelper
  protect_from_forgery except: :download_all

  def performSearch( data )
    @params = params
    fullResult = QueryHelper.buildTenderSearchQuery(data)
    @numResults = fullResult.count
    @tenders = fullResult.paginate(:page => params[:page]).order(sort_column + ' ' + sort_direction)

    @tendersInfo = {}
    @tenders.each do |tender|
      agreementInfo = { :tenderActualValue => nil, :winningOrgName => nil, :winningOrgId => 0 }
      if tender.agreements && tender.agreements.length > 0
        agreementInfo[:tenderActualValue] = tender.agreements.first.amount
        winningOrgId = tender.agreements.first.organization_id
        if winningOrgId
          winningOrgNameObj = Organization.select("name").where(:id => winningOrgId).first
          agreementInfo[:winningOrgName] = winningOrgNameObj[:name]
          agreementInfo[:winningOrgId] = winningOrgId
        end
        @tendersInfo[tender.id] = agreementInfo
      end
    end

    @sort = params[:sort]
    @direction = params[:direction]

    @searchType = "tender" 
    paramList = []
    data.each do |key, field|
      paramList.push(field)
    end
    checkSavedSearch(paramList, @searchType)
  end

  def search
    data = QueryHelper.buildTenderQueryData(params)
    performSearch(data)
  end

  def download_all
    filePath = "./public/AllTenders.zip"
    send_file filePath
  end
   
  def show
    @tender = Tender.find(params[:id])
    @cpv = TenderCpvClassifier.where(:cpv_code => @tender.cpv_code).first
    @tenderUrl = @tender.url_id
    @officalUrl = "http://tenders.procurement.gov.ge/public/?go="+@tender.url_id.to_s+"&lang="+t("spa_locale")
    @isWatched = false
    @highlights = []
    if current_user
      watched_tenders = WatchTender.where(:user_id => current_user.id, :tender_url => @tender.url_id)
      watched_tenders.each do |watched|
        @isWatched = true
        if params[:highlights] and watched.has_updated
          watched.diff_hash.split("#").each do |highlight|
            @highlights.push(highlight.split("/")[0].gsub("#",""))
          end
        end
        #reset the update flag to false since this tender has now been viewed
        watched.has_updated = false
        watched.save
      end
    end

    @complaints = Complaint.where(:tender_id => @tender.id, :organization_id => !nil)
    @minorCPVCategories = []
    if @tender.sub_codes
      cpvCodes = @tender.sub_codes.split("#")
      cpvCodes.each do |code|
        @minorCPVCategories.push(code)
      end
    end

    @risks = []
    @totalRisk = 0
    flags = @tender.risk_indicators
    if flags
      flags = flags.split("#")
    end
    if flags
      totalFlag = TenderCorruptionFlag.where(:corruption_indicator_id => 100,:tender_id => @tender.id ).first
      if totalFlag
        @totalRisk = totalFlag.value
      end
      flags.each do |flag|
        indicator = CorruptionIndicator.find( flag.to_s )
        @risks.push(indicator)
      end
    end

    #get all tender documentation
    @documentation = []
    documentation = Document.where(:tender_id => @tender.id)
    documentation.each do |document|
      @documentation.push( document )
    end

    @procurer = Organization.find(@tender.procurring_entity_id).name
    agreements = @tender.agreements
    @agreementInfo = []
    agreements.each do |agreement|
      infoItem = { :Type => "Agreement", :OrgName => nil, :whiteList => false, :blackList => false, :OrgID => agreement.organization_id, :value => agreement.amount, :startDate => agreement.start_date, :expiryDate => agreement.expiry_date, :document => agreement.documentation_url }
      if agreement.amendment_number > 0
        infoItem[:Type] = "Amendment "+agreement.amendment_number.to_s
      end
      infoItem[:OrgName] = Organization.find(agreement.organization_id).name
      infoItem[:whiteList] = WhiteListItem.where("organization_id = ?",agreement.organization_id).count > 0
      infoItem[:blackList] = BlackListItem.where("organization_id = ?",agreement.organization_id).count > 0
      @agreementInfo.push(infoItem)
    end

    bidders = @tender.bidders
    @bidderInfo = []
    bidders.each do |bidder|
      org = Organization.find(bidder.organization_id)
      if org
        infoItem = { :id => org.id, :whiteList => false, :blackList => false, :name => org.name, :won => false, :highBid => bidder.first_bid_amount, :lowBid => bidder.last_bid_amount, :numBids => bidder.number_of_bids}
        agreements.each do |agreement|
          if agreement.organization_id == org.id           
            infoItem[:won] = true
            break
          end
        end
        infoItem[:whiteList] = WhiteListItem.where("organization_id = ?",org.id).count > 0
        infoItem[:blackList] = BlackListItem.where("organization_id = ?",org.id).count > 0
        @bidderInfo.push(infoItem)
      end
    end
    @bidderInfo.sort! { |a,b| (a[:lowBid] < b[:lowBid] ? -1 : 1) }
  end

  private
  def sort_column
    Tender.column_names.include?(params[:sort_by]) ? params[:sort_by] : 'updated_at'
  end

  def sort_direction
    %w{asc desc}.include?(params[:direction]) ? params[:direction] : 'asc'
  end
end
