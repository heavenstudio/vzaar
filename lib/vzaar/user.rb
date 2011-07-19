module Vzaar

  class User

    attr_accessor :xml, :version, :id, :name, :url, :account_type_id, :created_at,
      :video_count, :play_count
    
    def initialize(xml)
      @xml = xml
      doc = REXML::Document.new xml
      @version = doc.elements['user/version'] ? doc.elements['user/version'].text : ''
      @id = doc.elements['user/author_id'] ? doc.elements['user/author_id'].text : ''
      @name = doc.elements['user/author_name'] ?
        doc.elements['user/author_name'].text : ''
      @url = doc.elements['user/author_url'] ? doc.elements['user/author_url'].text : ''
      @account_type_id = doc.elements['user/author_account'] ? 
        doc.elements['user/author_account'].text : ''
      @created_at = doc.elements['user/created_at'] ?
        doc.elements['user/created_at'].text : ''
      @video_count = doc.elements['user/video_count'] ?
        doc.elements['user/video_count'].text : ''
      @play_count = doc.elements['user/play_count'] ? 
        doc.elements['user/play_count'].text : ''
    end

  end

end
