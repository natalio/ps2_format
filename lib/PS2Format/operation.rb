require 'citizenship'
require 'PS2Format/exception/InvalidAmountException'

module PS2Format
  class Operation < Record
    OPERATION_RECORD_TYPE = '2'

    TRANSFER_REFERENCE_FIELD_SIZE = 15
    AMOUNT_FIELD_SIZE = 13
    COMPANY_REFERENCE_FIELD_SIZE = 20

    def initialize(arg = nil)
      case arg
      when Hash, NilClass
        super({format:           FORMAT,
               record_type:      OPERATION_RECORD_TYPE,
               operation_type:   TRANSFER_OPCODE,
               account_status:   ACCOUNT_STATUS,
               record_status:    RECORD_STATUS,
               nib:              ''.rjust(21, '0'),
               amount:           ''.rjust(AMOUNT_FIELD_SIZE, '0'),
               company_reference: ''.rjust(COMPANY_REFERENCE_FIELD_SIZE, '0'),
               transfer_reference: ''.rjust(TRANSFER_REFERENCE_FIELD_SIZE, '0'),
               filler:           '00'})
        process_options(arg || {})
      when String
        super({format:           arg[0..2],
               record_type:      arg[3..3],
               operation_type:   arg[4..5],
               account_status:   arg[6..7],
               record_status:    arg[8..8],
               nib:              arg[9..29],
               amount:           arg[30..42],
               company_reference: arg[43..62],
               transfer_reference: arg[63..77],
               filler:           arg[78..79]})
      else
        raise ArgumentError, "String or Hash expected"
      end
    end

    def amount=(value)
      metadata.amount = String(value).rjust(AMOUNT_FIELD_SIZE, '0')
    end

    def amount
      metadata.amount.to_i
    end

    def transfer_reference=(ref)
      metadata.transfer_reference = Record.remove_accents(String(ref)).rjust(TRANSFER_REFERENCE_FIELD_SIZE, ' ')
    end

    def transfer_reference
      metadata.transfer_reference.lstrip
    end

    def company_reference=(ref)
      metadata.company_reference = Record.remove_accents(String(ref)).rjust(COMPANY_REFERENCE_FIELD_SIZE, ' ')
    end

    def company_reference
      metadata.company_reference.lstrip
    end

    def nib=(nib)
      metadata.nib = Record.pre_process_nib(nib)
    end

class << self

    def validate_options(options)
      raise PS2Format::InvalidOperationTypeException.new I18n.t("ps2.exceptions.invalid_operation_type") if options[:operation_type].nil?
      raise InvalidAmountException.new I18n.t("ps2.exceptions.invalid_amount") if !(options[:amount].is_a? Numeric) or options[:amount].size > 11 or options[:amount] <= 0
      raise InvalidReferenceException.new I18n.t("ps2.exceptions.invalid_reference") if options[:operation_type].to_i > 50 and options[:company_reference].nil?

      begin
        Citizenship.valid_nib!(options[:nib])
      rescue Citizenship::Error => e
        raise PS2Format::InvalidOperationTypeException.new e.message
      end
    end

end

    def validate(include_obj = false)
      add_error(:format, value: format) if format != FORMAT
      add_error(:record_type, should_be: OPERATION_RECORD_TYPE, is: record_type) if record_type != OPERATION_RECORD_TYPE
      add_error(:record_status, value: record_status) if record_status.size != 1
      add_error(:account_status, value: account_status) if account_status.size != 2
      add_error(:amount, amount: amount) if !(amount.is_a? Numeric) or amount <= 0 or amount.size > 11
      add_error(:line_size, component: 'Operation', size: data.length) if data.length != 80

      begin
        Citizenship.valid_nib!(nib)
      rescue Citizenship::Error => e
        add_error(:nib, error: e.message)
      end
    end

    private

    def process_options(opts)

      nib = opts.delete(:nib)
      amount = opts.delete(:amount)
      transfer_reference = opts.delete(:transfer_reference)
      company_reference = opts.delete(:company_reference)
      operation_type = opts.delete(:operation_type)
      account_status = opts.delete(:account_status)
      record_status = opts.delete(:record_status)

      self.nib = nib if nib
      self.amount = amount if amount
      self.transfer_reference = transfer_reference if transfer_reference
      self.company_reference = company_reference if company_reference
      self.operation_type = operation_type if operation_type
      self.account_status = account_status if account_status
      self.record_status = record_status if record_status
    end
  end
end