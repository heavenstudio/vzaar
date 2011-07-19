class VzaarUploaderGenerator < Rails::Generator::Base

  def manifest
    record do |m|

      # Views
      m.directory 'app/views/vzaar'
      m.file 'views/uploader.html.erb', 'app/views/vzaar/index.html.erb'

      # Resources
      m.directory 'public/flash/vzaar'
      m.directory 'public/images/vzaar'
      m.directory 'public/javascripts/vzaar'
      m.directory 'public/stylesheets/vzaar'
      m.file 'flash/swfupload.swf', 'public/flash/vzaar/swfupload.swf'
      m.file 'flash/swfupload_fp9.swf', 'public/flash/vzaar/swfupload_fp9.swf'
      m.file 'images/cancelbutton.gif', 'public/images/vzaar/cancelbutton.gif'
      m.file 'javascripts/fileprogress.js', 'public/javascripts/vzaar/fileprogress.js'
      m.file 'javascripts/handlers.js', 'public/javascripts/vzaar/handlers.js'
      m.file 'javascripts/swfupload.js', 'public/javascripts/vzaar/swfupload.js'
      m.file 'javascripts/json_parse.js', 'public/javascripts/vzaar/json_parse.js'
      m.file 'javascripts/swfupload.queue.js',
        'public/javascripts/vzaar/swfupload.queue.js'
      m.file 'stylesheets/swfupload.css', 'public/stylesheets/vzaar/swfupload.css'

      # Routes
      gen_routes
      
    end
  end

  def gen_routes
    sentinel = 'ActionController::Routing::Routes.draw do |map|'
    gsub_file 'config/routes.rb', /(#{Regexp.escape(sentinel)})/mi do |match|
      "#{match}\n\n" +
        "  map.vzaar_uploader '/vzaar/', :controller => 'vzaar', " + 
          ":action => 'index'\n" +
        "  map.vzaar_signature '/vzaar/signature/', :controller => 'vzaar', " +
          ":action => 'signature'\n" +
        "  map.vzaar_process_video '/vzaar/process_video/', :controller => 'vzaar', " +
          ":action => 'process_video'\n"
  end 

  end 

  def gsub_file(relative_destination, regexp, *args, &block)
    path = destination_path(relative_destination)
    content = File.read(path).gsub(regexp, *args, &block)
    File.open(path, 'wb') { |file| file.write(content) }
  end 

end
