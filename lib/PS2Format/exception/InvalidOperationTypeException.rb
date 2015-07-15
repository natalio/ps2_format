
module PS2Format
  class InvalidOperationTypeException < StandardError
    def initialize(data)
      super(data)
    end
  end
end