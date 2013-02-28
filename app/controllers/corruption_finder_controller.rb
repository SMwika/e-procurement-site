#!/bin/env ruby
# encoding: utf-8


class CorruptionFinderController < ApplicationController

  def index
    tenders = Tender.where("dataset_id = 11 AND tender_announcement_date >= '2012-01-01' AND tender_announcement_date <= '2012-12-31'")
     @total = 0
     tenders.each do |tender|
       @total = @total + tender.estimated_value
     end

     tenders = Tender.where("dataset_id = 11 AND tender_announcement_date >= '2012-01-01' AND tender_announcement_date <= '2012-12-31' AND tender_type = 'შესყიდვის ელექტრონული პროცედურა'")
     @total1 = 0
     tenders.each do |tender|
       @total1 = @total1 + tender.estimated_value
     end

    tenders = Tender.where("dataset_id = 11 AND tender_announcement_date >= '2012-01-01' AND tender_announcement_date <= '2012-12-31' AND tender_type = 'კონსოლიდირებული ტენდერი'")
    @total2 = 0
    tenders.each do |tender|
      @total2 = @total2 + tender.estimated_value
    end

    tenders = Tender.where("dataset_id = 11 AND tender_announcement_date >= '2012-01-01' AND tender_announcement_date <= '2012-12-31' AND tender_type = 'ელექტრონული ტენდერი'")
    @total3 = 0
    tenders.each do |tender|
      @total3 = @total3 + tender.estimated_value
    end
    tenders = Tender.where("dataset_id = 11 AND tender_announcement_date >= '2012-01-01' AND tender_announcement_date <= '2012-12-31' AND tender_type = 'გამარტივებული ელექტრონული ტენდერი'")
    @total4 = 0
    tenders.each do |tender|
      @total4 = @total4 + tender.estimated_value
    end
  end

  def search
    criteria = params[:criteria]
  
    if criteria == "all"
      highRiskFlags = TenderCorruptionFlag.where(:corruption_indicator_id => 100).order("value DESC").limit(100)
      
      @riskyTenders = []
      count = 0
      highRiskFlags.each do |flag|
        tenderData = {}
        tender = Tender.find(flag.tender_id)
        tenderData[:id] = tender.id
        tenderData[:code] = tender.tender_registration_number
        tenderData[:value] = flag.value

        flags = TenderCorruptionFlag.where(:tender_id => tender.id)
        tenderData[:info] = ""
        flags.each do |flag|
          if not flag.corruption_indicator_id == 100
            tenderData[:info]+= CorruptionIndicator.find(flag.corruption_indicator_id).name+", "
          end
        end
        tenderData[:info].chop!.chop!
        @riskyTenders.push(tenderData)
      end

      respond_to do |format|  
        format.js   
      end
    end
  end


=begin
      tenders = {}
      count = 0
      TenderCorruptionFlag.find_each do | flag |
        riskAssessment = tenders[flag.tender_id]
        if not riskAssessment
          riskAssessment = {}
          riskAssessment[:total] = 0
          riskAssessment[:indicators] = []
        end
        indicator = CorruptionIndicator.find( flag.corruption_indicator_id )
        riskAssessment[:total] = riskAssessment[:total] + (indicator.weight * flag.value)
        riskAssessment[:indicators].push(indicator)
        tenders[flag.tender_id] = riskAssessment
      end
      
      def mysort(a,b)
        if b[:total] > a[:total]
          return 1
        else
          return -1
        end
      end
      tenders = tenders.sort { |a,b| mysort(a[1],b[1])}
      
      @riskyTenders = []
      count = 0
      tenders.each do |tender_id, risk|
        count = count + 1
        if count > 25
          break
        end
        tenderData = {}
        tenderData[:id] = tender_id
        tenderData[:code] = Tender.find(tender_id).tender_registration_number
        tenderData[:value] = risk[:total]
        tenderData[:info] = ""
        risk[:indicators].each do |indicator|
          tenderData[:info]+=indicator.name+", "
        end
        tenderData[:info].chop!.chop!
        @riskyTenders.push(tenderData)
      end
=end
end