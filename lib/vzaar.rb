# == Vzaar API gem
# The Vzaar API provides means to access and manage resources on http://vzaar.com
#
# See README file for installation details.
#
# Author:: Mariusz Lusiak <mailto:mariusz@applicake.com>

require 'rubygems'
require 'httpclient'
require 'logger'
require 'oauth/consumer'
require 'rexml/document'
require 'vzaar/account_type'
require 'vzaar/base'
require 'vzaar/errors'
require 'vzaar/user'
require 'vzaar/signature'
require 'vzaar/video'
require 'vzaar/video_details'

module Vzaar

  VZAAR_LIVE_SERVER = 'vzaar.com'

  HTTP_GET = 'GET'
  HTTP_POST = 'POST'
  HTTP_DELETE = 'DELETE'
  HTTP_PUT = 'PUT'

  HTTP_OK = "200"
  HTTP_CREATED = "201"

  HTTP_FORBIDDEN = "403"
  HTTP_NOT_FOUND = "404"

  HTTP_BAD_GATEWAY = "502"

  class << self

    attr_accessor :connection

    @connection = nil

    # Use the method to create global connection to vzaar.
    #
    # Usage:
    # * Vzaar.connect! :login => 'Your vzaar login', :application_token => 'Your vzaar application token', :server => 'The vzaar server (vzaar.com by default)'
    def connect!(options = {})
      @connection = Base.new options
    end

    # Enables Rails specifc views and controllers used by vzaar uploader.
    def enable_uploader
      return if ActionView::Base.instance_methods.include? 'vzaar_basic_uploader'
      require 'rails/views/view_helpers'
      require 'active_support'
      require 'active_support/dependencies'
      ActionView::Base.send :include, Vzaar::ViewHelpers
      controllers_path = "#{File.dirname(__FILE__)}/rails/controllers"
      ActiveSupport::Dependencies.autoload_paths << controllers_path
    end

  end
  
end

if defined?(Rails) and defined?(ActionController) and defined?(ActiveSupport)
  Vzaar.enable_uploader
end
