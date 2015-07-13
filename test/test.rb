#encoding: utf-8

require "test/unit"
$botpop_include_verbose = false
require_relative "../botpop"

class TestBotbot < Test::Unit::TestCase

  def test_binding_pry_existence
    assert(`grep -R 'binding\\.pry' *.rb plugins/*.rb`.empty?)
  end

end
