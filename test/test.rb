#encoding: utf-8

require 'pry'
require "test/unit"

class TestBotbot < Test::Unit::TestCase

  def test_binding_pry_existence
    assert(`grep -R 'binding\\.pry' *.rb plugins/*.rb`.empty?)
  end

end
