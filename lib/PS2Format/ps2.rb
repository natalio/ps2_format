require 'forwardable'

module PS2Format
  class BatchTransfer
    extend Forwardable

    def_delegators :@header, :operation_type, :ordering_nib
    attr_accessor :header, :operations

    def initialize(opts = {})
      @header = Header.new(opts)
      @operations = []
      process_options(opts)
    end

    def ordering_nib=(nib)
      @header.ordering_nib = Record.pre_process_nib(nib)
    end

    def reference=(ref)
      @header.reference = String(ref).rjust(Header::REFERENCE_FIELD_SIZE, ' ')
    end

    def reference
      @header.reference.lstrip
    end

    def processing_date
      Record.str_to_date(@header.processing_date)
    end

    def processing_date=(date)
      @header.processing_date = Record.date_to_str(date)
    end

    def add_operation!(options = {})
      Operation.validate_options(options)
      @operations << Operation.new(options)
    end

    def add_operation(options = {})
      oper = Operation.new(options)
      @operations << oper
      oper.validate
      oper.errors
    end

    def total_amount
      @operations.map(&:amount).reduce(0, &:+)
    end

    def income_amount
      @operations.map { |op|
        if op.operation_type.to_i >= 50 then op.amount.to_i else 0 end
      }.reduce(0, &:+)
    end

    def expense_amount
      @operations.map { |op|
        if op.operation_type.to_i < 50 then op.amount.to_i else 0 end
      }.reduce(0, &:+)
    end

    def footer
      Footer.new(self)
    end

    def valid?
      validate
      errors.empty?
    end

    def invalid?
      not(valid?)
    end

    def validate
      oper_errors = @operations.each do |o|
        o.validate
      end

      @header.validate

      footer.validate
    end

    def data
      to_a.map(&:to_s).join("\n")
    end

    def errors
      @header.errors + operation_errors + footer.errors
    end

    def structured_errors
      { header: @header.errors, operations: structured_operation_errors, footer: footer.errors }
    end

    def operation_errors
      @operations.map(&:errors).reject(&:empty?)
    end

    def structured_operation_errors
      error_hash = {}
      @operations.each do |op|
        error_hash[op] = op.errors unless op.errors.empty?
      end
      error_hash
    end

    def save(file_name)
      stream = File.new(file_name, "w")
      validate
      if errors.empty?
        marshall stream
        stream.close
      else
        errors
      end
    end

    def marshall(stream)
      stream << to_s
    end

    def to_s
      data
    end

class << self
    def read(file_name)
      stream = File.new(file_name,'r')
      file = unmarshall stream
      stream.close
      file
    end

    def unmarshall(stream)
      lines = stream.readlines

      header = Header.new(lines[0])

      operations = lines[1..-2].reduce([]) { |array, line| array << Operation.new(line) }

      ps2 = PS2Format::BatchTransfer.new
      ps2.header = header
      ps2.operations = operations
      #NOTICE: Footer is built on the fly! This should not happen for unmarshalling

      ps2
    end
end

    private
    def process_options(opts)
      nib = opts.delete(:ordering_nib)
      date = opts.delete(:processing_date)
      ref = opts.delete(:reference)

      self.ordering_nib = nib if nib
      self.processing_date = date if date
      self.reference = ref if ref
    end

    def to_a
      [@header.data, @operations.map(&:data), footer.data].flatten
    end

  end
end