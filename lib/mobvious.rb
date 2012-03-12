require "mobvious/version"

require "mobvious/config"
require "mobvious/manager"

# A library (Rack middleware) to detect device types (mobile, tablet, desktop etc.)
# from requests.
#
# See {Mobvious::Manager} for the actual Rack middleware.
#
# See {Mobvious::Config} for configuration options (and set them via calling
# {Mobvious.config Mobvious.config}).
#
# See {Mobvious::Strategies} for predefined strategies or roll out your own.
module Mobvious
  # A configuration method, evaluates the block in the context of the Mobvious.config object.
  def self.configure &block
    raise "Configure method needs to be passed a block." unless block_given?

    config.instance_eval &block
  end

  # An accessor for the global Mobvious configuration object.
  # See {Config} for configuration options.
  def self.config
    @config ||= Mobvious::Config.new
  end

  # An accessor for getting an instance of a strategy that is currently in use.
  # (Must be present in current `Mobvious.config.strategies`.)
  # @param class_name [String] a class name of the wanted strategy object
  def self.strategy(class_name)
    matching_strategies = self.config.strategies.select do
      |strategy| strategy.class.name.split('::').last == class_name
    end

    if matching_strategies.size == 1
      matching_strategies.first
    else
      matching_strategies
    end
  end


  module Strategies
    autoload :Cookie,    'mobvious/strategies/cookie'
    autoload :MobileESP, 'mobvious/strategies/mobileesp'
    autoload :URL,       'mobvious/strategies/url'
  end
end
