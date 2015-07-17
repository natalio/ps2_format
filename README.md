# PS2

[![Gem Version](https://badge.fury.io/rb/PS2Format.svg)](http://badge.fury.io/rb/PS2Format)
[![Build Status](https://travis-ci.org/runtimerevolution/ps2_format.svg?branch=master)](https://travis-ci.org/runtimerevolution/ps2_format)
[![Code Climate](https://codeclimate.com/github/runtimerevolution/ps2_format/badges/gpa.svg)](https://codeclimate.com/github/runtimerevolution/ps2_format)
[![Dependency Status](https://gemnasium.com/runtimerevolution/ps2_format.svg)](https://gemnasium.com/runtimerevolution/ps2_format)
[![security](https://hakiri.io/github/runtimerevolution/ps2_format/master.svg)](https://hakiri.io/github/runtimerevolution/ps2_format/master)
[![Coverage Status](https://coveralls.io/repos/runtimerevolution/ps2_format/badge.svg)](https://coveralls.io/r/runtimerevolution/ps2_format)

## Installation

Add this line to your Rails application's Gemfile:

    gem 'PS2Format'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install PS2Format

and use it standalone.

## Getting started

PS2 files are the standard way to communicate financial transfers, in batch, to a bank in Portugal. 

They can be used for many purposes, such as processing salaries, receiving payments (e.g. water, eletricity, monthly subscriptions), amongst others.

This format is generally supported, currently, by all major banks in Portugal. Due to the SEPA rollout, PS2 will be deprecated and obsolete in the future; see [Banco de Portugal FAQ](http://www.bportugal.pt/pt-pt/pagamentos/sepa/perguntasfrequentes/genericas/Paginas/Genericas.aspx).


### PS2 File format

The PS2 file format is composed of three parts: Header, Operations and Footer.

The Header includes fields related with the origin, such as ordering NIB (bank account number), processing date, ordering reference and operation type.
The operations field is composed by multiple entries, one per operation. Each one includes the account NIB, amount and operation type.
The footer holds information related with the quantity of operations in the file and serves as a checksum.

More details of the PS2 file layout can be found in this [unofficial link](https://corp.millenniumbcp.pt/pt/private/Documents/Layout_PS2_3.pdf).

### PS2format gem

The ps2format gem provides a simple API to create, read, and validate PS2 files. Note that the actual sending and receiving of files to/from a bank isn't in the scope of the gem, since most banks don't implement an API to do it. But most business Internet banking systems in Portugal allow the upload of these files.

This gem validates portuguese NIBs using Runtime Revolution's [citizenship gem](http://github.com/runtimerevolution/citizenship).



## Usage

A batch transfer can be created like:

    $ batch = PS2Format::BatchTransfer.new(ordering_nib: "123456789012345678901", operation_type: PS2::OperationType.expense[:water])
    $ batch = PS2Format::BatchTransfer.new(ordering_nib: "123456789012345678901", operation_type: PS2::OperationType.expense[:payroll])

default values will be provided for the remainder required fields:

- Processing date : Current date
- Account status : "00"
- Record status: "0"


Operations can be added to the file, where we must supply the amount, the NIB and company reference (if required):

    $ batch.add_operation(amount: 100, nib: "111111111100000000001" , operation_type: PS2Format::OperationType.expense[:water])
    $ batch.add_operation(amount: 30, nib: "111111111100000000001" , operation_type: PS2Format::OperationType.income[:quota], company_reference: "Antonio Manuel", transfer_reference: "XPTO", processing_date: Date.today)

To check if the batch is valid we do:

    $ batch.valid?

We can then persist the PS2 to a file

    $ batch.save("bank_file.ps2")
or to a stream

    $ batch.marshall File.new("bank_file.ps2", "w")

We can also read an existing PS2 from a file...

    $ batch = PS2Format::BatchTransfer.read("bank_file.ps2")
or from a stream

    $ batch = PS2Format::BatchTransfer.unmarshall File.open("bank_file.ps2", "r")

### Operation types

There can be two types of operations: income and expense.

The types of service can be used like

    $ PS2::OperationType.expense[:water]
    $ PS2::OperationType.income[:electricity]
Full list available [here](https://github.com/runtimerevolution/ps2_format/blob/master/lib/PS2Format/operation_type.rb)

### Exceptions

Whenever a new PS2Format instance is created, exceptions may be raised:

- InvalidOperationTypeException
- InvalidNIBException

When adding operations to the file you can choose between:

- add_operation!, which may raise exceptions for the required fields when constructing the operation or
- add_operation, which returns the errors produced



## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License
Copyright © 2015 [Runtime Revolution](http://www.runtime-revolution.com), released under the MIT license.

## About Runtime Revolution

![Runtime Revolution](http://webpublishing.s3.amazonaws.com/runtime_small_logo.png)

PS2Format is maintained by [Runtime Revolution](http://www.runtime-revolution.com).
See our [other projects](https://github.com/runtimerevolution/) and check out our [blog](http://www.runtime-revolution.com/runtime/blog) for the latest updates.
