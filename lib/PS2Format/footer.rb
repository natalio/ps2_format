module PS2Format
  class Footer < Record
    FOOTER_RECORD_TYPE = '9'

    def initialize(ps2)
      @ps2 = ps2
      super({format:           FORMAT,
             record_type:      FOOTER_RECORD_TYPE,
             operation_type:   TRANSFER_OPCODE,
             filler1:          '00',
             record_status:    RECORD_STATUS,
             filler2:          ''.rjust(6, '0'),
             num_operations:   @ps2.operations.size.to_s.rjust(14, '0'),
             total_amount:     @ps2.total_amount.to_s.rjust(13, '0'),
             filler3:          ''.rjust(38, '0')})
      process_options({operation_type: @ps2.operation_type})
    end

    def total_amount
      metadata.total_amount.to_i
    end

    def num_operations
      metadata.num_operations.to_i
    end

    def validate
      add_error(:format, value: format) if format != FORMAT
      add_error(:record_type, should_be: FOOTER_RECORD_TYPE, is: record_type) if record_type != FOOTER_RECORD_TYPE
      add_error(:record_status, value: record_status) if record_status.size != 1
      add_error :num_operations, num_operations: num_operations if num_operations != @ps2.operations.size
      add_error :total_amount, total_amount: total_amount if total_amount != @ps2.total_amount
      add_error :line_size, component: 'Footer', size: data.length if data.length != 80
    end

    private

    def process_options(opts)
      operation_type = opts.delete(:operation_type)

      self.operation_type = operation_type if operation_type
    end
  end
end