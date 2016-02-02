#====================================================================
# Disclaimer: This script is written as best effort and provides no
# warranty expressed or implied. Please contact the author(s) if you
# have questions about this script before running or modifying
#====================================================================
# See the puppet forum on http://http://developer.solidfire.com/

require 'net/http'
require 'uri'
require 'json'
require 'openssl'

class SolidfireApi
  VERSION = "8.0"

  attr_accessor :url, :redacted_url, :debug

  @debug = false

  def initialize(url)
    debug("#{self.class}::initialize -> #{url}")
    @url = URI.parse(url)
    raise ArgumentError, "Invalid scheme #{@url.scheme}. Must be https" \
                         unless @url.scheme == 'https'
    raise ArgumentError, "no user specified" unless @url.user
    raise ArgumentError, "no password specified" unless @url.password
    redacted_url = @url.dup
    redacted_url.password = "****" if redacted_url.password
    @redacted_url=redacted_url.to_s
    @url.path = @url.path + "/json-rpc/#{VERSION}"
  end

  def getVolumeByName(name)
    debug("#{self.class}::getVolumeByName: #{name}")
    volList = ListActiveVolumes()
    volList['volumes'].each do |vol|
      if vol['name'] == name
        return vol
      end
    end
    nil
  end

  def getVolumeByID(id)
    debug("#{self.class}::getVolumeByID: #{id}")
    volList = ListActiveVolumes({ 'startVolumeID' => id, \
                                  'limit' => 1 })
    volList['volumes'].each do |vol|
      if vol['volumeID'] == id
        return vol
      end
    end
    nil
  end

  def getVagByName(name)
    debug("#{self.class}::getVagByName: #{name}")
    vagList = ListVolumeAccessGroups()
    vagList['volumeAccessGroups'].each do |vag|
      if vag['name'] == name
        return vag
      end
    end
    nil
  end

  def getVagByID(id)
    debug("#{self.class}::getVagByID: #{id}")
    vagList = ListVolumeAccessGroups({ 'startVolumeAccessGroupID' => id, \
                                       'limit' => 1 })
    vagList['volumeAccessGroups'].each do |vag|
      if vag['volumeAccessGroupID'] == id
        return vag
      end
    end
    nil
  end

  def getSchedByName(name)
    debug("#{self.class}::getSchedByName: #{name}")
    schedList = ListSchedules()
    schedList['schedules'].each do |sched|
      if sched['scheduleName'] == name
        return sched
      end
    end
    nil
  end

  def method_missing(name, *args)
    post_body = { 'method' => name,
                  'params' => Hash[*args.flatten],
                  'id' => 'puppet-' + rand(999).to_s,
                }.to_json
    debug("#{self.class}::#{name}->post: #{post_body}")
    resp = JSON.parse( http_post_request(post_body) )
    if resp['error']
      if resp['error']['name'] == 'xUnknownAPIMethod'
        debug("#{self.class}::xUnknownAPIMethod")
        super
      else
        raise JSONRPCError, resp['error'] if resp['error']
      end
    else
      debug("#{self.class}::post_result: #{resp['result']}")
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

  def debug(msg)
    puts msg if @debug
  end

  class JSONRPCError < RuntimeError; end

end
