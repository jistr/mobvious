module Mobvious
  # Class encapsulating Mobvious configuration.
  #
  # Set configuration options them via calling {Mobvious.config Mobvious.config}.
  class Config
    # Creates a new configuration with no strategies and default device type `:desktop`.
    def initialize()
      self.clear
    end

    # Resets a configuration to no strategies and default device type `:desktop`.
    def clear
      @strategies = []
      @default_device_type = :desktop
    end

    # Strategies used to determine device type from a request. They are evaluated
    # in the order they are inserted. Result of the first successful strategy
    # (returning something else than nil) is used.
    attr_accessor :strategies

    # Default device type is used when no strategy was successful (all return nil
    # or none is present).
    attr_accessor :default_device_type
  end
end
