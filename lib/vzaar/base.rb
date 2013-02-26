module Vzaar

  # You can use Vzaar::Base class for accessing and managing your resources on vzaar.
  class Base
    attr_accessor :login

    # When creating a Vzaar::Base instance you can (but don't have to) specify
    # login and application_token. However if you don't specify them you
    # won't be able to perform authenticated calls.
    #
    # You can also specify server different from live server, e.g. sandbox.vzaar.com,
    # if you're just doing testing. Additionally you can pass your logger as the
    # :logger option. By default the log/debug info is written to the standard output.
    # 
    # The options can be read from environment variables. Just set VZAAR_LOGIN,
    # VZAAR_APPLICATION_TOKEN and/or VZAAR_SERVER and you don't have to worry about 
    # passing the options to the initializer.
    # 
    # Usage:
    # * vzaar = Vzaar::Base.new 
    # * vzaar = Vzaar::Base.new :login => 'your_vzaar_login', :application_token => 'your_very_long_application_token'
    # * vzaar = Vzaar::Base.new :login => 'your_vzaar_login', :application_token => 'your_app_token', :server => 'sandbox.vzaar.com' 
    # * vzaar = Vzaar::Base.new :server => 'sandbox.vzaar.com', :logger => your_logger 
    # * vzaar = Vzaar::Base.new :logger => your_logger
    def initialize(options= {})
      @login = options[:login] || ENV['VZAAR_LOGIN'] || ''
      application_token = options[:application_token] || ENV['VZAAR_APPLICATION_TOKEN'] || ''
      server = options[:server] || ENV['VZAAR_SERVER'] || VZAAR_LIVE_SERVER
      @logger = options[:logger] || Logger.new(STDOUT)

      server.gsub! 'http://', ''
      server.gsub! 'https://', ''
      consumer = OAuth::Consumer.new '', '', { :site => "http://#{server}" }
      @public_connection = OAuth::AccessToken.new consumer, '', ''
      consumer = OAuth::Consumer.new '', '', { :site => "https://#{server}" }
      if @login.length > 0 and application_token.length > 0
        @auth_connection = OAuth::AccessToken.new consumer, @login, application_token
      else
        # Authenticated requests won't be possible
        @auth_connection = nil
        log_info "Authenticated calls won't be possible"
      end
    end

    # Test method for authentication. Returns a login of an authenticated user.
    #
    # Usage:
    # * my_login = vzaar.whoami
    def whoami
      result = nil
      auth_connection(HTTP_GET, '/api/test/whoami') do |xml|
        doc = REXML::Document.new xml
        result = doc.elements['vzaar-api/test/login'].text
      end
      result
    end

    # Gets the details of an account type.
    #
    # Usage:
    # * account_type = vzaar.account_type 1
    # * title = vzaar.account_type(1).title
    # * bandwidth = vzaar.account_type(1).bandwidth
    def account_type(account_type_id)
      result = nil
      public_connection(HTTP_GET, "/api/accounts/#{account_type_id}.xml") do |xml|
        result = AccountType.new xml
      end
      result
    end

    # Gets a user public details. Whitelabel users can retrive their details by
    # using the method with 'authenticated' option on.
    #
    # Usage:
    # * me = vzaar.user_details 'some_login' (this works only if 'some_login' is not a protected resource)
    # * me = vzaar.user_details 'your_login', true ('your_login' must be the same as the one provided for Vzaar::Base.new method in order to authorize on server.)
    #
    # Note: even if you created an authorized instance of Vzaar::Base class
    # (by specifying login and application token in Vzaar::Base.new), you
    # need to set the 'authenticated' param to true in order to perform
    # authenticated call.
    def user_details(login, authenticated = false)
      result = nil
      if authenticated
        auth_connection(HTTP_GET, "/api/users/#{login}.xml") do |xml|
          result = User.new xml
        end
      else
        public_connection(HTTP_GET, "/api/users/#{login}.xml") do |xml|
          result = User.new xml
        end
      end
      result
    end

    # Gets a list of a user's active videos along with it's relevant metadata.
    # Set 'authenticated' option to true to retrieve private videos.
    #
    # Usage:
    # * videos = vzaar.video_list 'your_login' (gets your public videos)
    # * videos = vzaar.video_list 'some_other_login' (gets public videos of some_other_login)
    # * videos = vzaar.video_list 'your_login', true (gets all your videos, provided your_login is the one you provided for Vzaar::Base initializer)
    # * videos = vzaar.video_list 'some_other_login', true (gets public videos of some_other_login - you cannot access other users' private videos) 
    #
    # Note: even if you created an authorized instance of Vzaar::Base class
    # if you don't set the 'authenticated' param to true you will receive
    # only public videos.
    def video_list(login = nil, authenticated = false, page=1)
      result = []
      response = nil
      if authenticated
        response = auth_connection(HTTP_GET, "/api/#{login}/videos.xml?page=#{page}")
      else
        response = public_connection(HTTP_GET, "/api/#{login}/videos.xml?page=#{page}")
      end
      if response and response.body
        doc = REXML::Document.new response.body
        videos = doc.elements['videos']
        videos.elements.each('video') do |video|
          result << Video.new(video.to_s)
        end
      end
      result
    end
    
    def videos(page=1)
      video_list(@login, true, page)
    end

    # Gets video details, including embed code. Use 'authenticated' option to 
    # retrieve details of private video.
    #
    # Usage:
    # * video = vzaar.video_details 1234 (1234 must be a public video)
    # * video = vzaar.video_details 1234, true (1234 can be a private video but you must the owner)
    #
    # Note: even if you create an authorized instance of Vzaar::Base class
    # if you don't set the 'authenticated' param to true you will not be able
    # to retrieve data for private video.
    def video_details(video_id, authenticated = false)
      result = nil
      if authenticated
        auth_connection(HTTP_GET, "/api/videos/#{video_id}.xml") do |xml|
          result = VideoDetails.new xml
        end
      else
        public_connection(HTTP_GET, "/api/videos/#{video_id}.xml") do |xml|
          result = VideoDetails.new xml
        end
      end
      result
    end

    # Deletes a video from a users account. Use either 'DELETE' or 'POST' method.
    # You must be the owner of the video in order to authorize on the server.
    #
    # Usage:
    # * vzaar.delete_video 1234 (uses 'DELETE' method)
    # * vzaar.delete_video 1234, 'POST'
    def delete_video(video_id, method = HTTP_DELETE)
      if method == HTTP_DELETE
        auth_connection method, "/api/videos/#{video_id}.xml"
      else
        request_xml = %{
          <?xml version="1.0" encoding="UTF-8"?>
          <vzaar-api>
            <_method>delete</_method>
          </vzaar-api>
        }
        auth_connection method, "/api/videos/#{video_id}.xml", request_xml
      end
    end

    # Edits a video title and description. Use either 'PUT' or 'POST' method.
    #
    # Usage:
    # * vzaar.edit_video 1234, 'new title', 'new desc' (uses 'PUT' method)
    # * vzaar.edit_video 1234, 'new title', 'new desc', 'POST'
    def edit_video(video_id, title, description, method = HTTP_PUT)
      request_xml = %{
        <?xml version="1.0" encoding="UTF-8"?>
        <vzaar-api>
      }
      request_xml += %{<_method>put</_method>} if method != HTTP_PUT
      request_xml += %{
          <video>
            <title>#{title}</title>
            <description>#{description}</description >
          </video>
        </vzaar-api>
      }
      auth_connection HTTP_PUT, "/api/videos/#{video_id}.xml", request_xml
    end

    # Provides a signature which is required to upload a video directly to S3 bucket.
    # Options:
    # * success_action_redirect - when sending files to S3 you can be redirected to a given url on success. You'll need to specify the url when requesting a signature. Vzaar API server will attach a guid to it and return full url in the response. You'll need to specify the full url later when uploading a video in order to get authorized on S3.
    # * include_metadata - if you set the param to true, then when uploading a video you can and have to(!) send metadata to S3 along with your video. The names of the metadata must be: 'x-amz-meta-title' and 'x-amz-meta-profile'. None of them can be omitted even if empty. Vzaar doesn't restric the values of the metadata in any way. If include_metadata is false, which is the default behaviour, no metadata can be send to S3.
    # * flash_request - adds flash specific params to the signature
    #
    # Usage:
    # * vzaar.signature
    # * vzaar.signature :success_action_redirect => 'http://my.domain.com/using_vzaar'
    # * vzaar.signature :success_action_redirect => 'http://my.domain.com/using_vzaar', :include_metadata => true
    # * vzaar.signature :include_metadata => true
    # * vzaar.signature :flash_request => true
    def signature(options = {})
      signature = nil
      url = '/api/videos/signature'
      if options[:success_action_redirect]
        url += "?success_action_redirect=#{options[:success_action_redirect]}"
      end
      if options[:include_metadata]
        url += url.include?('?') ? '&' : '?'
        url += "include_metadata=yes"
      end
      if options[:flash_request]
        url += url.include?('?') ? '&' : '?'
        url += "flash_request=yes"
      end
      auth_connection HTTP_GET, url do |xml|
        signature = Signature.new xml
      end
      signature
    end

    # Tells vzaar that you have uploaded a video to S3 and now you want to 
    # register it in vzaar. This method is called automatically from within
    # the upload_video method. 
    #
    # Usage:
    # * vzaar.process_video :guid => signature.guid, 
    # :title => 'Some title', :description => 'Some description', 
    # :profile => 1, :transcoding => true
    def process_video(options = {})
      vzaar_video_id = nil
      request_xml = %{
        <?xml version="1.0" encoding="UTF-8"?>
        <vzaar-api>
          <video>
            <guid>#{options[:guid]}</guid>
            <title>#{options[:title]}</title>
            <description>#{options[:description]}</description>
            <profile>#{options[:profile]}</profile>
      }
      if !options[:transcoding].nil?
        request_xml += %{
            <transcoding>#{options[:transcoding]}</transcoding>
        }
      end
      request_xml += %{ 
          </video>
        </vzaar-api>
      }
      auth_connection HTTP_POST, '/api/videos', request_xml do |response_body|
        vzaar_video_id = get_video_id_from_response_body(response_body)
      end
      vzaar_video_id
    end

    # Uploads a video to vzaar. You can force transcoding video by setting
    # transcoding param to true, you can force DNE (Do not encode) by 
    # setting transcoding param to false. When trancoding == nil (default)
    # then user settings on vzaar will decide whether to encode or DNE.
    #
    # Usage:
    # * vzaar.upload_video '/home/me/video.mp4', 'some title', 'some desc', '1'
    # * vzaar.upload_video '/home/me/video.mp4', ""
    def upload_video(path, title = "", description = "", profile = "", transcoding = nil)
      # Get signature
      sig = signature
      @logger.debug "Uploading..." 
      # Upload to S3
      res = upload_to_s3 sig.acl, sig.bucket, sig.policy, sig.aws_access_key,
        sig.signature, sig.key, path
      if res
        @logger.debug "Upload complete"
        # And process in vzaar
        process_video :guid => sig.guid, :title => title,
          :description => description, :profile => profile,
          :transcoding => transcoding
      else
        @logger.debug "Upload to s3 failed"
        return nil
      end
    end

    private 
      # Gets the video id from a uploaded video (parsed from the xml response)
      def get_video_id_from_response_body(response_body)
        doc = Nokogiri::XML(response_body)
        doc.css('vzaar-api video').first.content
      end
      
      # Performs the public connection
      def public_connection(method, url, xml = '')
        res = nil
        begin
          case method
            when "GET"
              res = @public_connection.get url
            when "POST"
              if xml and xml.length > 0
                res = @public_connection.post url, xml,
                  { 'Content-Type' => 'application/xml' }
              else
                res = @public_connection.post url
              end
            when "PUT"
              if xml and xml.length > 0
                res = @public_connection.put url, xml,
                  { 'Content-Type' => 'application/xml' }
              else
                res = @public_connection.put url
              end
            when "DELETE"
              if xml and xml.length > 0
                res = @public_connection.delete url, xml,
                  { 'Content-Type' => 'application/xml' }
              else
                res = @public_connection.delete url
              end
            else
              handle_exception 'unknown_method'
          end
          case res.code
            when HTTP_OK 
              yield res.body if block_given?
            when HTTP_CREATED
              yield res.body if block_given?
            when HTTP_FORBIDDEN
              handle_exception 'protected_resource'
            when HTTP_NOT_FOUND
              handle_exception 'resource_not_found'
            when HTTP_BAD_GATEWAY
              handle_exception 'server_not_responding'
            else
              handle_exception 'unknown'
          end
        rescue Exception => e
          raise e if e.is_a? VzaarError
          handle_exception 'unknown', e.message
        end
        res
      end

      # Performs the authenticated connection
      def auth_connection(method, url, xml = '')
        res = nil
        begin 
          if @auth_connection
            case method
              when "GET"
                res = @auth_connection.get url
              when "POST"
                if xml and xml.length > 0
                  res = @auth_connection.post url, xml,
                    { 'Content-Type' => 'application/xml' }
                else
                  res = @auth_connection.post url
                end
              when "PUT"
                if xml and xml.length > 0
                  res = @auth_connection.put url, xml,
                    { 'Content-Type' => 'application/xml' }
                else 
                  res = @auth_connection.put url
                end
              when "DELETE"
                if xml and xml.length > 0
                  res = @auth_connection.delete url, xml,
                    { 'Content-Type' => 'application/xml' }
                else
                  res = @auth_connection.delete url
                end
              else
                unknown_method
            end
            case res.code
              when HTTP_OK
                yield res.body if block_given?
              when HTTP_CREATED 
                yield res.body if block_given?
              when HTTP_BAD_GATEWAY
                handle_exception 'server_not_responding'
              else
                handle_exception 'not_authorized'
            end
          else
            handle_exception 'authorization_info_not_provided'
          end
        rescue Exception => e
          raise e if e.is_a? VzaarError
          handle_exception 'unknown', e.message
        end
        res
      end

      def upload_to_s3(acl, bucket, policy, aws_access_key, signature, key, file_path)
        client = HTTPClient.new
        client.send_timeout = 1800
        url = "https://#{bucket}.s3.amazonaws.com/"
        begin
          file = File.open file_path
          res = client.post url, [
            ['acl', acl],
            ['bucket', bucket],
            ['success_action_status', '201'],
            ['policy', policy],
            ['AWSAccessKeyId', aws_access_key],
            ['signature', signature],
            ['key', key],
            ['file', file]
          ]
        rescue Exception => e
          file.close if file
          handle_exception 'unknown', e.message
        end
        file.close if file
        if res.status_code == 201
          return true
        else
          return false
        end
      end

      def upload_to_s3_curl(acl, bucket, policy, aws_access_key, signature, key, file_path)
        require 'curb'
        acl_field = Curl::PostField.content 'acl', acl
        bucket_field = Curl::PostField.content 'bucket', bucket
        success_action_status_field = Curl::PostField.content 'success_action_status',
          '201'
        policy_field = Curl::PostField.content 'policy', policy
        aws_access_key_field = Curl::PostField.content 'AWSAccessKeyId', aws_access_key
        signature_field = Curl::PostField.content 'signature', signature
        key_field = Curl::PostField.content 'key', key
        file_field = Curl::PostField.file 'file', file_path
        curl = Curl::Easy.new "https://#{bucket}.s3.amazonaws.com/"
        curl.multipart_form_post = true
        begin
          curl.http_post acl_field, bucket_field, success_action_status_field, policy_field,
            aws_access_key_field, signature_field, key_field, file_field  
        rescue Exception => e
          handle_exception 'unknown', e.message
        end
        if curl.response_code == 201
          return true
        else
          return false
        end
      end

      def log_info(message)
        @logger.info message
      end

      def handle_exception(type, message = '')
        case type
        when 'not_authorized'
          message = "You have not been authorized on the server. " +
            "Please check your login and application token."
        when 'authorization_info_not_provided'
          message = 'You need to provide login and application token to perform ' +
            'to perform this action.'
        when 'server_not_responding'
            message = "The server you're trying to connect to is not responding."
        when 'protected_resource'
          message = "The resource is protected and you have not been authorized " +
            "to access it."
        when 'resource_not_found'
          message = "The resource has not been found on the server."
        when 'unknown_method'
          message = "The method used for connecting is not a proper HTTP method."
        else
          message = "Unknown error occured when accessing the server: " + message
        end
        @logger.error message
        raise VzaarError.new message
      end

  end

end
