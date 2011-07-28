require 'vzaar/base'

module Vzaar

  module ViewHelpers
  
    def include_vzaar_javascripts
      javascript_include_tag 'vzaar/json_parse', 'vzaar/swfupload', 'vzaar/handlers', 
        'vzaar/swfupload.queue', 'vzaar/fileprogress'
    end

    def link_vzaar_stylesheets
      stylesheet_link_tag 'stylesheets/vzaar/swfupload.css'
    end
    
    def vzaar_basic_params(signature)
      content_tag(:input, nil, :type => "hidden", :name => "key", :value => "#{signature.key}") +
      content_tag(:input, nil, :type => "hidden", :name => "AWSAccessKeyId", :value => "#{signature.aws_access_key}") +
      content_tag(:input, nil, :type => "hidden", :name => "acl", :value => "#{signature.acl}") +
      content_tag(:input, nil, :type => "hidden", :name => "success_action_status", :value => "201") +
      content_tag(:input, nil, :type => "hidden", :name => "policy", :value => "#{signature.policy}") +
      content_tag(:input, nil, :type => "hidden", :name => "signature", :value => "#{signature.signature}")
    end
    
    def vzaar_success_redirect(signature)
      content_tag(:input, nil, :type => "hidden", :name => "success_action_redirect", :value => signature.success_action_redirect)
    end

    # 
    # <%=
    #     vzaar_flash_uploader :vzaar_params => {},
    #       :success_url => 'http://localhost/videos/'
    # %>
    #
    # TODO: Handle succuess url correctly
    #
    def vzaar_flash_uploader(options = {})
      default_options = {
        :flash_request => true,
        :connection => Vzaar.connection
      }
      options = default_options.merge options
      connection = options[:connection]
      signature = connection.signature options
      result = ''
      result += flash_uploader_script signature, options
      result += flash_uploader_html
      result
    end

    # TODO: documentation
    # if using metadata you should change x-amz-meta-title and x-amz-meta-profile
    # to relevant values using javascript
    # TODO: change to use Vzaar.connection
    def vzaar_basic_uploader(options = {})
      default_options = {
        :success_action_redirect => nil,
        :include_metadata => false,
        :vzaar_params => {}
      }
      options = default_options.merge options
      vz = Vzaar::Base.new options[:vzaar_params]
      signature = vz.signature options
      upload_form = %Q{
        <form action="http://#{signature.bucket}.s3.amazonaws.com/" method="post" 
          enctype="multipart/form-data" id="uploadToS3">
	        <div class="uploadFieldsWrapper" style="width:490px; float:left">
			      #{vzaar_basic_params(signature)}
      }
      if signature.profile and signature.title
        upload_form += %Q{
            <input id='vzaar-title' type="hidden" name="x-amz-meta-title"
              value="#{signature.title}">
            <input id='vzaar-profile' type="hidden" name="x-amz-meta-profile"
              value="#{signature.profile}">
        }
      end
      upload_form += vzaar_success_redirect(signature) if signature.success_action_redirect
      upload_form += %Q{
      		  <label class='videoFileStep'>video file to be uploaded</label>
      		  <input name="file" type="file" id="fileField" onchange="EnableBasicButton();"> 
            <br />
            <input name="upload" type="submit" />
	        </div>	
        </form>
      }
      upload_form
    end

    private

      def flash_uploader_post_params(signature)
        result = {}
        result[:AWSAccessKeyId] = signature.aws_access_key
        result[:key] = signature.key
        result[:acl] = signature.acl
        result[:policy] = signature.policy
        result[:signature] = signature.signature
        result[:success_action_status] = '201'
        result['content-type'] = 'binary/octet-stream'
        result
      end

      def flash_uploader_script(signature, options = {})
        result = ''
        result += %Q{
          <script type="text/javascript">
        }
        if options[:success_url]
          url = options[:success_url]
          url += url.include?('?') ? '&' : '?'
          url += "guid=" + signature.guid
          result += "var successURL = '#{url}';"
        end
        result += %Q{
          var swfu;
          window.onload = function () {
            swfu = new SWFUpload({
              upload_url: "http://#{signature.bucket}.s3.amazonaws.com/",
              http_success : [201], 
              assume_success_timeout : 0,
              // File Upload Settings
              file_post_name: 'file',
              file_types : "*.*",
              file_types_description : "All Files",
              file_upload_limit : "10",
              file_queue_limit : 0,
              // Event Handler Settings - these functions as defined in handlers.js
              file_queued_handler : fileQueued,
              file_queue_error_handler : fileQueueError,
              file_dialog_complete_handler : fileDialogComplete,
              upload_start_handler : uploadStart,
              upload_progress_handler : uploadProgress,
              upload_error_handler : uploadError,
              upload_success_handler : uploadSuccess,
              upload_complete_handler : uploadComplete,
              // Button Settings
              button_width: "65",
              button_height: "29",
              button_placeholder_id: "spanButtonPlaceHolder",
              button_text: '<span class="theFont">Browse</span>',
              button_text_style: ".theFont { font-size: 16; }",
              button_text_left_padding: 6,
              button_text_top_padding: 3,
              button_window_mode: SWFUpload.WINDOW_MODE.TRANSPARENT,
              button_cursor: SWFUpload.CURSOR.HAND,
              moving_average_history_size: 10,
              // Flash Settings
              flash_url : "/flash/vzaar/swfupload.swf",
              flash9_url : "/flash/vzaar/swfupload_fp9.swf",
              custom_settings : {
                progressTarget : "fsUploadProgress",
                uploaded_files : []
              },
              // Debug Settings
              debug: false
            });
          };
          </script>
        }
        result
      end

      def flash_uploader_html
        result = %Q{
          <div id="content">
            <form id="vzaar_upload" action="" method="post" enctype="multipart/form-data">
              <div class="fieldset flash" id="fsUploadProgress">
                <span class="legend">Upload Queue</span>
              </div>
              <span id="spanButtonPlaceHolder"></span>
            </form>
          </div>
        }
        result
      end

  end

end
