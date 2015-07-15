
module PS2Format
  class InvalidNIBException < StandardError
    def initialize(data)
      super(data)
    end
  end
end