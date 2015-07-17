require 'test/unit'
require 'ps2_format'

require 'simplecov'
require 'coveralls'
Coveralls.wear!

#setup simplecov
SimpleCov.start


class Ps2Test < Test::Unit::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    @ps2 = PS2Format::BatchTransfer.new(ordering_nib: "003503730000539151280", operation_type: PS2Format::OperationType.expense[:water])
    @ps2.add_operation(amount: 30, nib: "003503730000539151280" , operation_type: PS2Format::OperationType.income[:quota], company_reference: "Antonio Manuel", transfer_reference: "XPTO", processing_date: Date.today)
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  def test_create
    assert @ps2.operation_type == PS2Format::OperationType.expense[:water]
    assert_true @ps2.ordering_nib.eql? "003503730000539151280".rjust(21, '0')
  end

  def test_add_operation
    assert @ps2.operations.size == 1
  end

  def test_validate
    assert_true @ps2.header.valid?
    assert_true @ps2.footer.valid?
    assert_true @ps2.valid?
  end

  def test_amount_1
    assert @ps2.total_amount == 30
    assert @ps2.expense_amount == 0
    assert @ps2.income_amount == 30
  end

  def test_amount_2
    @ps2.add_operation(amount: 123, nib: "003503730000539151280", operation_type: PS2Format::OperationType.expense[:electricity])
    assert @ps2.total_amount == 153
    assert @ps2.expense_amount == 123
    assert @ps2.income_amount == 30
  end

  def test_valid_2
    assert_true @ps2.valid?
  end

  def test_errors
    assert @ps2.errors.size == 0
  end

  def test_marshall_unmarshall
    io = File.new("test/marshall", "w")
    assert_true File.zero? "test/marshall"
    @ps2.marshall io
    io.close
    assert_true File.exist? "test/marshall"
    assert_true((PS2Format::BatchTransfer.unmarshall File.open("test/marshall", "r")).valid?)
    File.delete "test/marshall"
  end

  def test_read_save
    @ps2.save "test/marshall"
    assert_empty(@ps2.errors)
    ps2 = PS2Format::BatchTransfer.read "test/marshall"
    assert_true(ps2.valid?)
    File.delete "test/marshall"
  end

  def test_invalid_operation
    begin
      PS2Format::BatchTransfer.new(ordering_nib: "003503730000539151280", operation_type: PS2Format::OperationType.expense[:coal])
    rescue PS2Format::InvalidOperationTypeException => e
    end

    assert_true(e.is_a? PS2Format::InvalidOperationTypeException)
  end

  def test_invalid_nib
    begin
      PS2Format::BatchTransfer.new(ordering_nib: "003503730000623151280", operation_type: PS2Format::OperationType.expense[:water])
    rescue PS2Format::InvalidNIBException => e
    end

    assert_true(e.is_a? PS2Format::InvalidNIBException)
  end

  def test_invalid_company_ref
    begin
      PS2Format::BatchTransfer.new(ordering_nib: "003503730000539151280", operation_type: PS2Format::OperationType.expense[:water])
      @ps2.add_operation!(amount: 30, nib: "003503730000539151280" , operation_type: PS2Format::OperationType.income[:quota])
    rescue PS2Format::InvalidReferenceException => e
    end

    assert_true(e.is_a? PS2Format::InvalidReferenceException)
  end


end
