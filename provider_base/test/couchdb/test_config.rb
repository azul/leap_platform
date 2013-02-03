require 'minitest/autorun'
require 'yaml'

class TestConfig < MiniTest::Unit::TestCase

  def setup
    @config = YAML.load_file(ENV['CONFIG'])
  end

  def test_config
    assert_has_keys @config, 'couch', 'domain', 'ip_address', 'services'
  end

  def test_users
    users = @config['couch']['users']
    assert users
    assert_has_keys users, 'admin', 'ca_daemon', 'webapp'
    users.values.each do |user|
      assert_has_keys user, 'password', 'username'
    end
  end

  def assert_has_keys(hash, *expected_keys)
    expected_keys.each do |key|
      assert hash.keys.include?(key), "expected config setting #{key} is missing"
    end
  end
end
