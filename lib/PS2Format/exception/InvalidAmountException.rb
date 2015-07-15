
module PS2Format
  class InvalidAmountException < StandardError
    def initialize(data)
      super(data)
    end
  end
end