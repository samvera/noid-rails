[![Version](https://badge.fury.io/rb/active_fedora-noid.png)](http://badge.fury.io/rb/active_fedora-noid)
[![Apache 2.0 License](http://img.shields.io/badge/APACHE2-license-blue.svg)](./LICENSE)
[![Contribution Guidelines](http://img.shields.io/badge/CONTRIBUTING-Guidelines-blue.svg)](./CONTRIBUTING.md)
[![API Docs](http://img.shields.io/badge/API-docs-blue.svg)](http://rubydoc.info/gems/active_fedora-noid)
[![Build Status](https://travis-ci.org/projecthydra-labs/active_fedora-noid.png?branch=master)](https://travis-ci.org/projecthydra-labs/active_fedora-noid)
[![Dependency Status](https://gemnasium.com/projecthydra-labs/active_fedora-noid.png)](https://gemnasium.com/projecthydra-labs/active_fedora-noid)
[![Coverage Status](https://coveralls.io/repos/projecthydra-labs/active_fedora-noid/badge.svg)](https://coveralls.io/r/projecthydra-labs/active_fedora-noid)

# ActiveFedora::Noid

Override your ActiveFedora-based applications with opaque [Noid](https://wiki.ucop.edu/display/Curation/NOID)-based identifiers.

**This gem depends only upon ActiveFedora, not on Hydra or HydraHead**

# Table of Contents

  * [Installation](#installation)
  * [Usage](#usage)
    * [Minting and validating identifiers](#minting-and-validating-identifiers)
    * [ActiveFedora integration](#activefedora-integration)
    * [Overriding default behavior](#overriding-default-behavior)
      * [Minter state (for replayability)](#minter-state-for-replayability)
      * [Identifier template](#identifier-template)
      * [Custom minters](#custom-minters)
  * [Help](#help)
  * [Acknowledgments](#acknowledgments)

# Installation

Add this line to your application's Gemfile:

    gem 'active_fedora-noid'

And then execute:

    $ bundle install

Or install it yourself via:

    $ gem install active_fedora-noid

# Usage

## Minting and validating identifiers

Mint a new Noid:

```ruby
noid_service = ActiveFedora::Noid::Service.new
noid = noid_service.mint
```

This creates a Noid with the default identifier template, which you can override (see below).  Now that you have a service object with a template, you can also use it to validate identifiers to see if they conform to the template:

```ruby
noid_service.valid? 'xyz123foobar'
> false
```

## ActiveFedora integration

To get ActiveFedora to automatically call your Noid service whenever a new ActiveFedora object is saved, create a method on your model called `assign_id` and have it talk to your Noid service, e.g.:

```ruby
# app/models/my_object.rb
require 'active_fedora/noid'

class MyObject < ActiveFedora::Base
  # ...

  def assign_id
    noid_service.mint
  end

  # ...

  private

    def noid_service
      @noid_service ||= ActiveFedora::Noid::Service.new
    end
end
```

## Overriding default behavior

### Minter state (for replayability)

The default minter creates a Noid and dumps it to a statefile in the /tmp directory. You can override the location or name of this statefile as follows in e.g. `config/initializers/active_fedora-noid.rb`:

```ruby
require 'active_fedora/noid'

ActiveFedora::Noid.configure do |config|
  config.statefile = '/var/foo/bar'
end
```

### Identifier template

To override the default identifier pattern -- a nine-character string consisting of two alphanumeric digits, two numeric digits, two alphanumeric digits, two numeric digits, and a check digit -- put the following code in e.g. `config/initializers/active_fedora-noid.rb`:

```ruby
require 'active_fedora/noid'

ActiveFedora::Noid.configure do |config|
  config.template = '.ddddd'
end
```

For more information about the format of Noid patterns, see pages 8-10 of the [Noid documentation](https://wiki.ucop.edu/download/attachments/16744482/noid.pdf).

### Custom minters

If you don't want your minter's state to be persisted, you may also pass in your own minter.  First write up a minter class that looks like the following:

```ruby
class MyMinter
  def initialize(*args)
    # do something if you need initialization
  end

  def mint
    # spit out an identifier
  end

  def valid?(identifier)
    # return true/false if you care about ids conforming to templates
  end
end
```

Then inject an instance of your minter into ActiveFedora::Noid::Service:

```ruby
noid_service = ActiveFedora::Noid::Service.new(MyMinter.new)
```

And the service will delegate minting and validating to an instance of your customized minter class.

# Help

If you have questions or need help, please email [the Hydra community tech list](mailto:hydra-tech@googlegroups.com) or stop by [the Hydra community IRC channel](irc://irc.freenode.net/projecthydra).

# Acknowledgments

This software has been developed by and is brought to you by the Hydra community.  Learn more at the
[Project Hydra website](http://projecthydra.org)

![Project Hydra Logo](https://github.com/uvalib/libra-oa/blob/a6564a9e5c13b7873dc883367f5e307bf715d6cf/public/images/powered_by_hydra.png?raw=true)
