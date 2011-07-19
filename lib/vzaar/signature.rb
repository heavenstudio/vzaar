module Vzaar
  
  class Signature
    
    attr_accessor :xml, :acl, :bucket, :policy, :key, :aws_access_key, :guid, :signature,
      :success_action_redirect, :title, :profile

    def initialize(xml)
      @xml = xml
      doc = REXML::Document.new xml
      @acl = doc.elements['vzaar-api/acl'] ? doc.elements['vzaar-api/acl'].text : ''
      @bucket = doc.elements['vzaar-api/bucket'] ?
        doc.elements['vzaar-api/bucket'].text : ''
      @policy = doc.elements['vzaar-api/policy'] ?
        doc.elements['vzaar-api/policy'].text : ''
      @key = doc.elements['vzaar-api/key'] ?
        doc.elements['vzaar-api/key'].text : ''
      @aws_access_key = doc.elements['vzaar-api/accesskeyid'] ?
        doc.elements['vzaar-api/accesskeyid'].text : ''
      @guid = doc.elements['vzaar-api/guid'] ? 
        doc.elements['vzaar-api/guid'].text : ''
      @signature = doc.elements['vzaar-api/signature'] ?
        doc.elements['vzaar-api/signature'].text : ''
      @success_action_redirect = doc.elements['vzaar-api/success_action_redirect'] ?
        doc.elements['vzaar-api/success_action_redirect'].text : nil
      @title = doc.elements['vzaar-api/title'] ? '' : nil
      @profile = doc.elements['vzaar-api/profile'] ? '' : nil
    end

  end
end
