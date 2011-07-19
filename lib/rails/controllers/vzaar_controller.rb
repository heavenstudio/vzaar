class VzaarController < ApplicationController
  before_filter :connect_to_vzaar

  def index
    respond_to do |format|
      format.html
    end
  end

  def process_video
    guid = params[:guid]
    title = params[:filename]
    Vzaar.connection.process_video :guid => guid, :title => title,
      :description => 'some description',
      :profile => '1' 
    render :nothing => true
  end 

  def signature
    signature = Vzaar.connection.signature :flash_request => true
    json_signature = {}
    json_signature[:AWSAccessKeyId] = signature.aws_access_key
    json_signature[:key] = signature.key
    json_signature[:acl] = signature.acl
    json_signature[:policy] = signature.policy
    json_signature[:signature] = signature.signature
    json_signature[:success_action_status] = '201'
    json_signature['content-type'] = 'binary/octet-stream'
    json_signature[:guid] = signature.guid
    respond_to do |format|
      format.json do
        render :json => json_signature.to_json
      end 
    end 
  end 

  def connect_to_vzaar
    Vzaar.connect! :login => 'login', :application_token => 'token', :server_name => "defaults to vzaar.com"
  end
end
