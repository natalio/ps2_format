
module PS2Format
  class InvalidReferenceException < StandardError
    def initialize(data)
      super(data)
    end
  end
end