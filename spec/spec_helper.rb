require 'minitest/spec'
require 'minitest/autorun'
begin; require 'turn'; rescue LoadError; end
require 'mocha'
require 'rack/test'
require 'mobvious'

module Mobvious
  class CookieParser
    attr_reader :cookies

    def initialize(cookie_header_content)
      @cookies = {}
      return unless cookie_header_content

      cookie_header_content.split("\n").each do |cookie_string|
        cookie_parts = cookie_string.split(';')

        name, cookie_value = cookie_parts.first.split('=')
        cookie = { 'value' => cookie_value }

        cookie_parts[1..-1].each do |cookie_part|
          key, value = cookie_part.split('=')
          cookie[key.strip] = value
        end
        @cookies[name.strip] = cookie
      end
    end

    def [](*args)
      @cookies[*args]
    end
  end
end
