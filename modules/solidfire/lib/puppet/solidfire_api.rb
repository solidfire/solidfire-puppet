require 'net/http'
require 'uri'
require 'json'
require 'openssl'

class SolidfireApi

  attr_accessor :url, :redacted_url

  def initialize(url)
    Puppet.debug("#{self.class}::initialize -> #{url}")
    @url = URI.parse(url)
    raise ArgumentError, "Invalid scheme #{@url.scheme}. Must be https" \
                         unless @url.scheme == 'https'
    raise ArgumentError, "no user specified" unless @url.user
    raise ArgumentError, "no password specified" unless @url.password
    redacted_url = @url.dup
    redacted_url.password = "****" if redacted_url.password
    @redacted_url=redacted_url.to_s
    @url.path = @url.path + "json-rpc/7.0"
  end

  def getVolumeByName(name)
    Puppet.debug("#{self.class}::getVolumeByName: #{name}")
    volList = ListActiveVolumes()
    volList['volumes'].each do |vol|
      if vol['name'] == name then
        return vol
      end
    end
    nil
  end

  def getVolumeByID(id)
    Puppet.debug("#{self.class}::getVolumeByID: #{id}")
    volList = ListActiveVolumes({ 'startVolumeID' => id, \
                                  'limit' => 1 })
    volList['volumes'].each do |vol|
      if vol['volumeID'] == id then
        return vol
      end
    end
    nil
  end

  def method_missing(name, *args)
    post_body = { 'method' => name,
                  'params' => Hash[*args.flatten],
                  'id' => 'puppet-' + rand(999).to_s,
                }.to_json
    Puppet.debug("#{self.class}::#{name}->post: #{post_body}")
    resp = JSON.parse( http_post_request(post_body) )
    if resp['error']
      if resp['error']['name'] == 'xUnknownAPIMethod'
        Puppet.debug("#{self.class}::xUnknownAPIMethod")
        super
      else
        raise JSONRPCError, resp['error'] if resp['error']
      end
    else
      Puppet.debug("#{self.class}::post_result: #{resp['result']}")
      resp['result']
    end
  end

  def http_post_request(post_body)
    http = Net::HTTP.new(@url.host, @url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Post.new(@url.request_uri)
    request.basic_auth(@url.user, @url.password)
    request.content_type = 'application/json'
    request.body = post_body
    http.request(request).body
  end

  class JSONRPCError < RuntimeError; end

end
