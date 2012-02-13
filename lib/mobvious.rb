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
  # An accessor for the global Mobvious configuration object.
  # See {Config} for configuration options.
  def self.config
    @config ||= Mobvious::Config.new
  end
end
