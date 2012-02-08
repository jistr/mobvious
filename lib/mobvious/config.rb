module Mobvious
  class Config
    def initialize()
      @strategies = []
      @default_device_type = :desktop
    end

    attr_reader   :strategies
    attr_accessor :default_device_type
  end
end
