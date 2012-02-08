require "mobvious/version"

require "mobvious/config"
require "mobvious/manager"

module Mobvious
  def self.config
    @config ||= Mobvious::Config.new
  end
end
