#!/usr/bin/env ruby
#encoding: utf-8

class Botpop

  module PluginInclusion

    def self.plugin_error_failure! e, f
      STDERR.puts "Error during loading the file #{f}".red
      STDERR.puts "#{e.class}: #{e.message}".red.bold
      STDERR.puts "---- Trace ----"
      STDERR.puts e.backtrace.join("\n").black.bold
      exit 1
    end

    def self.plugin_include! f
      begin
        if $botpop_include_verbose != false
          puts "Loading plugin file ... " + f.green + " ... " + require_relative(f).to_s
        else
          require_relative(f)
        end
      rescue => e
        plugin_error_failure! e, f
      end
    end

    # THEN INCLUDE THE PLUGINS (STATE MAY BE DEFINED BY THE PREVIOUS CONFIG)
    def self.plugins_include! arguments
      Dir[File.expand_path '*.rb', arguments.plugin_directory].each do |f|
        if !arguments.disable_plugins.include? f
          plugin_include! f
        end
      end
    end

  end

end
