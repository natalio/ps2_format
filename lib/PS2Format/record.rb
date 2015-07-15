#coding: utf-8
require 'ostruct'
require 'delegate'
require 'I18n'

module PS2Format
  # Compoents (Header, Operation and Footer) are validatable
  # and delegate method calls to an OpenStruct containing
  # the component's metadata
  #
  class Record < SimpleDelegator
    alias :metadata :__getobj__

    FORMAT = 'ps2'
    TRANSFER_OPCODE = '12'
    ACCOUNT_STATUS = '00'
    RECORD_STATUS = '0'
    REFERENCE_FIELD_SIZE = 20

    #The error list
    attr_reader :errors

    def initialize(metadata)
      super(OpenStruct.new(metadata))
      @errors = []
    end

    # Validates the component
    # Inheriting classes must implement #validate and use
    # Componenet#add_error if errors found
    def valid?
      @errors.clear
      validate
      @errors.empty?
    end

    def invalid?
      not(valid?)
    end

    def format
      metadata.format
    end

    def ordering_nib
      metadata.ordering_nib
    end

    def operation_type
      metadata.operation_type
    end

    def operation_type=(operation_type)
      metadata.operation_type = operation_type
    end

    def date=(date)
      if date.is_a? Date
        metadata.date = date_to_str(date)
      end

      if date.is_a? String
        metadata.date = date
      end
    end

    def account_status
      metadata.account_status
    end

    def account_status=(status)
      metadata.account_status = status
    end

    def record_status
      metadata.record_status 
    end

    def record_status=(status)
      metadata.record_status = status
    end

    #Raw component data
    def data
      metadata.marshal_dump.values.map(&:to_s).reduce('', :<<)
    end

    protected
    def add_error(key, values = {})
      error(key, 'ps2.errors', values)
    end

    def add_account_status_error(key, values = {})
      error("status_#{key}", 'ps2.account_statuses', values)
    end

    def add_status_error(key, values = {})
      error("status_#{key}", 'ps2.statuses', values)
    end

    def error(key, scope, values = {})
      @errors << I18n.t(key.to_sym, values.merge(scope: scope))
    end

    def self.date_to_str(date)
      date.strftime('%Y%m%d')
    end

    def self.str_to_date(str)
      Date.strptime(str, '%Y%m%d')
    end

    def self.valid_date?(str)
      str_to_date(str)
      true
    rescue ArgumentError
      false
    end

    def self.pre_process_nib(nib)
      String(nib).delete(' ')
                 .delete('-')
                 .delete('.')
                 .rjust(21, '0')
    end

    def self.remove_accents(text)
      text = text.to_s
      text = text.gsub(/[á|à|ã|â|ä]/, 'a').gsub(/(é|è|ê|ë)/, 'e').gsub(/(í|ì|î|ï)/, 'i').gsub(/(ó|ò|õ|ô|ö)/, 'o').gsub(/(ú|ù|û|ü)/, 'u')
      text = text.gsub(/(Á|À|Ã|Â|Ä)/, 'A').gsub(/(É|È|Ê|Ë)/, 'E').gsub(/(Í|Ì|Î|Ï)/, 'I').gsub(/(Ó|Ò|Õ|Ô|Ö)/, 'O').gsub(/(Ú|Ù|Û|Ü)/, 'U')
      text = text.gsub(/ñ/, 'n').gsub(/Ñ/, 'N')
      text = text.gsub(/ç/, 'c').gsub(/Ç/, 'C')
      text
    end

    private

    def ensure_options(options)

      raise PS2Format::InvalidOperationTypeException.new I18n.t("ps2.exceptions.invalid_operation_type") if operation_type.nil?
      raise PS2Format::InvalidNIBException.new I18n.t("ps2.exceptions.invalid_nib") if ordering_nib.nil? or ordering_nib.size != 19

    end

  end
end