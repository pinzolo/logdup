# Logdup

[![Build Status](https://secure.travis-ci.org/pinzolo/logdup.png)](http://travis-ci.org/pinzolo/logdup)
[![Coverage Status](https://coveralls.io/repos/pinzolo/logdup/badge.png)](https://coveralls.io/r/pinzolo/logdup)

`Logdup` duplicates logs partially.  
This extends `Logger` that is a built-in library of Ruby.

## Installation

Add this line to your application's Gemfile:

    gem 'logdup'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install logdup

## Usage

#### code

```ruby
logger = Logger.new("base.log")
logger.info("aaa")
logger.dup_to("other.log") do
  logger.info("bbb")
end
logger.info("ccc")
```

#### result image

    $ cat base.log
    aaa
    bbb
    ccc

    $ cat other.log
    bbb

## Supported ruby versions

* 1.9.3
* 2.0.0
* 2.1.0

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
