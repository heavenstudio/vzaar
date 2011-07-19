module Vzaar

  class AccountType

    attr_accessor :xml, :version, :id, :title, :monthly, :currency, :bandwidth,
      :borderless, :search_enhancer

    def initialize(xml)
      @xml = xml
      doc = REXML::Document.new xml
      @version = doc.elements['account/version'] ?
        doc.elements['account/version'].text : ''
      @id = doc.elements['account/account_id'] ?
        doc.elements['account/account_id'].text : ''
      @title = doc.elements['account/title'] ?
        doc.elements['account/title'].text : ''
      @monthly = doc.elements['account/cost/monthly'] ?
        doc.elements['account/cost/monthly'].text : ''
      @currency = doc.elements['account/cost/currency'] ?
        doc.elements['account/cost/currency'].text : ''
      @bandwidth = doc.elements['account/bandwidth'] ?
        doc.elements['account/bandwidth'].text : ''
      @borderless = doc.elements['account/rights/borderless'] ?
        doc.elements['account/rights/borderless'].text : ''
      @search_enhancer = doc.elements['account/rights/searchEnhancer'] ?
        doc.elements['account/rights/searchEnhancer'].text : ''
    end

  end

end
