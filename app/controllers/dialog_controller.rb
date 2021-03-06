class DialogController < ApplicationController
  def show_white_list
    orgID = params[:id]
    @item = WhiteListItem.where(:organization_id => orgID).first
  end
  
  def show_black_list
    orgID = params[:id]
    @item = BlackListItem.where(:organization_id => orgID).first
   
    if @item.tender_id != "NULL"
      @tenders = []
      regNumberList = @item.tender_id.split(",")
     
      regNumberList.each do |number|
        puts number
        tender = Tender.where(:tender_registration_number => number).first
        if tender
          @tenders.push(tender)
        end
      end
    end
  end

  def show_complaint
    complaintID = params[:id]
    @item = Complaint.find(complaintID)
    @tenderName = Tender.find(@item.tender_id).tender_registration_number
    @orgName = Organization.find(@item.organization_id).name
  end
end
