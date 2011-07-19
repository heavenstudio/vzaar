module Vzaar

  class VideoDetails

    attr_accessor :xml,
      :author_account_type_id,
      :author_name,
      :author_url,
      :duration,
      :framegrab_height,
      :framegrab_url,
      :framegrab_width,
      :height,
      :html,
      :play_count,
      :provider_name,
      :provider_url,
      :thumbnail_height,
      :thumbnail_url,
      :thumbnail_width,
      :title,
      :type,
      :version,
      :video_status_id,
      :video_url,
      :width
    
    def initialize(xml)
      @xml = xml
      doc = REXML::Document.new xml
      @author_account_type_id = doc.elements['oembed/author_account'] ? 
        doc.elements['oembed/author_account'].text : ''
      @author_name = doc.elements['oembed/author_name'] ?
        doc.elements['oembed/author_name'].text : ''
      @author_url = doc.elements['oembed/author_url'] ? 
        doc.elements['oembed/author_url'].text : ''
      @duration = doc.elements['oembed/duration'] ?
        doc.elements['oembed/duration'].text : ''
      @framegrab_height = doc.elements['oembed/framegrab_height'] ?
        doc.elements['oembed/framegrab_height'].text : ''
      @framegrab_url = doc.elements['oembed/framegrab_url'] ?
        doc.elements['oembed/framegrab_url'].text : ''
      @framegrab_width = doc.elements['oembed/framegrab_width'] ?
        doc.elements['oembed/framegrab_width'].text : ''
      @height = doc.elements['oembed/height'] ? doc.elements['oembed/height'].text : ''
      @html = doc.elements['oembed/html'] ? doc.elements['oembed/html'].texts[1] : ''
      @play_count = doc.elements['oembed/play_count'] ? 
        doc.elements['oembed/play_count'].text : ''
      @provider_name = doc.elements['oembed/provider_name'] ?
        doc.elements['oembed/provider_name'].text : ''
      @provider_url = doc.elements['oembed/provider_url'] ? 
        doc.elements['oembed/provider_url'].text : ''
      @thumbnail_height = doc.elements['oembed/thumbnail_height'] ?
        doc.elements['oembed/thumbnail_height'].text : ''
      @thumbnail_url = doc.elements['oembed/thumbnail_url'] ?
        doc.elements['oembed/thumbnail_url'].text : ''
      @thumbnail_width = doc.elements['oembed/thumbnail_width'] ?
        doc.elements['oembed/thumbnail_width'].text : ''
      @title = doc.elements['oembed/title'] ? doc.elements['oembed/title'].text : ''
      @type = doc.elements['oembed/type'] ? doc.elements['oembed/type'].text : ''
      @version = doc.elements['oembed/version'] ?
        doc.elements['oembed/version'].text : ''
      @video_status_id = doc.elements['oembed/video_status_id'] ?
        doc.elements['oembed/video_status_id'].text : ''
      @video_url = doc.elements['oembed/video_url'] ?
        doc.elements['oembed/video_url'].text : ''
      @width = doc.elements['oembed/width'] ? doc.elements['oembed/width'].text : ''
    end

  end

end
