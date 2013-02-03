require 'minitest/autorun'
require 'yaml'
require 'net/https'
require 'json'

class TestConnection < MiniTest::Unit::TestCase

  def setup
    @config = YAML.load_file(ENV['CONFIG'])
    @domain = @config['domain']['full']
    @http = Net::HTTP.new(@domain, 6984)
    @http.use_ssl = true
    @http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  end

  def test_couch_version
    request = Net::HTTP::Get.new("https://#{@domain}:6984")
    response = @http.request(request)
    greeting = JSON.parse(response.body)
    assert_equal ["couchdb", "version"], greeting.keys.sort
  end


end
