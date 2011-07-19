module Vzaar

  class Video
    
    attr_accessor :xml, :version, :id, :title, :description, :created_at, :url,
      :thumbnail_url, :play_count, :author_name, :author_url, :author_account_type_id,
      :video_count, :duration

    def initialize(xml)
      @xml = xml
      doc = REXML::Document.new xml
      @version = doc.elements['video/version'] ? doc.elements['video/version'].text : ''
      @id = doc.elements['video/id'] ? doc.elements['video/id'].text : ''
      @title = doc.elements['video/title'] ? doc.elements['video/title'].text : ''
      @description = doc.elements['video/description'] ?
        doc.elements['video/description'].text : ''
      @create_at = doc.elements['video/created_at'] ?
        doc.elements['video/created_at'].text : ''
      @url = doc.elements['video/url'] ? doc.elements['video/url'].text : ''
      @thumbnail_url = doc.elements['video/thumbnail_url'] ?
        doc.elements['video/thumbnail_url'].text : ''
      @play_count = doc.elements['video/play_count'] ?
        doc.elements['video/play_count'].text : ''
      @author_name = doc.elements['video/user/author_name'] ?
        doc.elements['video/user/author_name'].text : ''
      @author_url = doc.elements['video/user/author_url'] ?
        doc.elements['video/user/author_url'].text : ''
      @author_account_type_id = doc.elements['video/user/author_account'] ?
        doc.elements['video/user/author_account'].text : ''
      @video_count = doc.elements['video/user/video_count'] ?
        doc.elements['video/user/video_count'].text : ''
      @duration = doc.elements['video/duration'] ?
        doc.elements['video/duration'].text : ''
    end

  end

end
