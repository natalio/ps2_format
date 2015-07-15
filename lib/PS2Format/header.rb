require 'date'
require 'citizenship'
require 'PS2Format/exception/InvalidOperationTypeException'
require 'PS2Format/exception/InvalidNIBException'

module PS2Format
  class Header < Record
    HEADER_RECORD_TYPE = '1'
    COIN = 'EUR'
    FILLER_SIZE = 19

    def initialize(arg = nil)
      case arg
      when Hash, NilClass
        super({format:          FORMAT,
               record_type:     HEADER_RECORD_TYPE,
               operation_type:  TRANSFER_OPCODE,
               account_status:  ACCOUNT_STATUS,
               record_status:   RECORD_STATUS,
               ordering_nib:    ''.rjust(21, '0'),
               coin:            COIN,
               processing_date: Record.date_to_str(Date.today),
               reference:       ''.rjust(REFERENCE_FIELD_SIZE, '0'),
               filler:          ''.rjust(FILLER_SIZE, '0')}.merge(arg || {}))
        process_options(arg || {})
      when String
        super({format:          arg[0..2],
               record_type:     arg[3..3],
               operation_type:  arg[4..5],
               account_status:  arg[6..7],
               record_status:   arg[8..8],
               ordering_nib:    arg[9..29],
               coin:            arg[30..32],
               processing_date: arg[33..40],
               reference:       arg[41..60],
               filler:          arg[61..79]})
      else
        raise ArgumentError, "String or Hash expected"
      end
    end

    def reference=(ref)
      metadata.reference = Record.remove_accents(String(ref)).rjust(REFERENCE_FIELD_SIZE, '0')
    end

    def reference
      metadata.reference.lstrip
    end

    def ordering_nib=(ordering_nib)
      metadata.ordering_nib = Record.pre_process_nib(ordering_nib)
    end

    def validate
      add_error(:format, value: format) if format != FORMAT
      add_error(:record_type, should_be: HEADER_RECORD_TYPE, is: record_type) if record_type != HEADER_RECORD_TYPE
      add_error(:record_status, value: record_status) if record_status.size != 1
      add_error(:account_status, value: account_status) if account_status.size != 2
      add_error(:coin, coin: coin) if coin != COIN
      add_error(:date, date: processing_date) unless Record.valid_date?(processing_date)
      add_error(:reference, size: reference.size) if reference.size != REFERENCE_FIELD_SIZE
      add_error(:filler) if filler.size != 19 or filler.to_i != 0
      add_error(:line_size, component: 'Header', size: data.length) if data.length != 80

      begin
        Citizenship.valid_nib!(ordering_nib)
      rescue Citizenship::Error => e
        add_error(:nib, error: e.message)
      end
    end

    private

    def process_options(opts)

      if !opts.empty?
        raise PS2Format::InvalidOperationTypeException.new I18n.t("ps2.exceptions.invalid_operation_type") if opts.delete(:operation_type).nil?
        begin
          Citizenship.valid_nib!(opts.delete(:ordering_nib))
          ordering_nib = opts.delete(:ordering_nib)
        rescue Citizenship::Error => e
          raise PS2Format::InvalidNIBException.new e.message
        end
      end

      ref = opts.delete(:reference)
      operation_type = opts.delete(:operation_type)
      date = opts.delete(:date)
      account_status = opts.delete(:account_status)
      record_status = opts.delete(:record_status)

      self.ordering_nib = ordering_nib if ordering_nib
      self.reference = ref if ref
      self.operation_type = operation_type if operation_type
      self.date = date if date
      self.account_status = account_status if account_status
      self.record_status = record_status if record_status
    end
  end
end