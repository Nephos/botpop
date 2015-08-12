#encoding: utf-8

require "test/unit"
$botpop_include_verbose = false
require_relative "../botpop"

class TestBotbot < Test::Unit::TestCase

  def test_binding_pry_existence
    assert(`grep -R 'binding\\.pry' *.rb plugins/*.rb`.empty?)
  end

  def test_classes_constants
    assert(Botpop.class == Class)
    assert(Botpop::ARGUMENTS)
    assert(Botpop::VERSION)
    assert(Botpop::CONFIG)
    assert(Botpop::TARGET)
    assert(Botpop::PluginInclusion.class == Module)
    assert(BotpopBuiltins.class == Module)
    assert(Botpop::Plugin.class == Class)
  end

end
