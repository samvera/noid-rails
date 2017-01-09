Code: [![Version](https://badge.fury.io/rb/active_fedora-noid.png)](http://badge.fury.io/rb/active_fedora-noid)
[![Build Status](https://travis-ci.org/projecthydra/active_fedora-noid.png?branch=master)](https://travis-ci.org/projecthydra/active_fedora-noid)
[![Coverage Status](https://coveralls.io/repos/github/projecthydra/active_fedora-noid/badge.svg?branch=master)](https://coveralls.io/github/projecthydra/active_fedora-noid?branch=master)
[![Code Climate](https://codeclimate.com/github/projecthydra/active_fedora-noid/badges/gpa.svg)](https://codeclimate.com/github/projecthydra/active_fedora-noid)
[![Dependency Status](https://gemnasium.com/projecthydra/active_fedora-noid.png)](https://gemnasium.com/projecthydra/active_fedora-noid)

Docs: [![Documentation Status](https://inch-ci.org/github/projecthydra/active_fedora-noid.svg?branch=master)](https://inch-ci.org/github/projecthydra/active_fedora-noid)
[![API Docs](http://img.shields.io/badge/API-docs-blue.svg)](http://rubydoc.info/gems/active_fedora-noid)
[![Contribution Guidelines](http://img.shields.io/badge/CONTRIBUTING-Guidelines-blue.svg)](./CONTRIBUTING.md)
[![Apache 2.0 License](http://img.shields.io/badge/APACHE2-license-blue.svg)](./LICENSE)

# ActiveFedora::Noid

Override your ActiveFedora-based applications with opaque [Noid](https://wiki.ucop.edu/display/Curation/NOID)-based identifiers.

**This gem depends only upon ActiveFedora, not on Hydra or HydraHead**

# Table of Contents

  * [Installation](#installation)
  * [Usage](#usage)
    * [Minting and validating identifiers](#minting-and-validating-identifiers)
    * [ActiveFedora integration](#activefedora-integration)
      * [Identifier/URI translation](#identifieruri-translation)
    * [Overriding default behavior](#overriding-default-behavior)
      * [Use database-based minter state](#use-database-based-minter-state)
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

### Identifier/URI translation

As ActiveFedora::Noid overrides the default identifier minting strategy in ActiveFedora, you will need to let ActiveFedora know how to translate identifiers into URIs and vice versa so that identifiers are laid out in a sustainable way in Fedora.  Add the following to e.g. `config/initializers/active_fedora.rb`:

```ruby
ActiveFedora::Base.translate_uri_to_id = ActiveFedora::Noid.config.translate_uri_to_id
ActiveFedora::Base.translate_id_to_uri = ActiveFedora::Noid.config.translate_id_to_uri
```

This will make sure your objects have Noid-like identifiers (e.g. `bb22bb22b`) that map to URIs in Fedora (e.g. `bb/22/bb/22/bb22bb22b`).

## Overriding default behavior

The default minter in ActiveFedora::Noid 2.x is the file-backed minter to preserve default behavior.

To better support multi-host production installations that expect a shared database but not necessarily a shared filesystem (e.g., between load-balanced Rails applications), we highly recommend swapping in the database-backed minter.

### Use database-based minter state

The database-based minter stores minter state information in your application's relational database. To use it, you'll first need to run the install generator:

```bash
$ rails generate active_fedora:noid:install
```

This will create the necessary database tables and seed the database minter. To start minting identifiers with the new minter, override the AF::Noid configuration in e.g. `config/initializers/active_fedora-noid.rb`:

```ruby
require 'active_fedora/noid'

ActiveFedora::Noid.configure do |config|
  config.minter_class = ActiveFedora::Noid::Minter::Db
end
```

Using the database-backed minter can cause problems with your test suite, where it is often sensible to wipe out database rows between tests (which destroys the database-backed minter's state, which renders it unusable). To deal with this and still get the benefits of using the database-backed minter in development and production environments, you'll also want to add the following helper to your `spec/spec_helper.rb`:

```ruby
require 'active_fedora/noid/rspec'

RSpec.configure do |config|
  include ActiveFedora::Noid::RSpec

  config.before(:suite) { disable_production_minter! }
  config.after(:suite)  { enable_production_minter! }
end
```

If you switch to the new database-backed minter and want to include in that minter the state of your current file-backed minter, AF::Noid 2.x provides a new rake task that will copy your minter's state from the filesystem to the database:

```bash
# For migrating minter state from a file to a database
$ rake active_fedora:noid:migrate:file_to_database
# For migrating minter state from a database to a file
$ rake active_fedora:noid:migrate:database_to_file
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

If you don't want your minter's state to be persisted, you may also write and configure your own minter.  First write up a minter class that looks like the following:

```ruby
class MyMinter < ActiveFedora::Noid::Minter::Base
  def valid?(identifier)
    # return true/false if you care about ids conforming to templates
  end

  def read
    # return current minter state
  end

  def write!(state)
    # write a passed-in minter state
  end

  protected

  def next_id
    # return the next identifier from the minter
  end
end
```

Then add your new minter class to the ActiveFedora::Noid configuration (`config/initializers/active_fedora-noid.rb`):

```ruby
require 'active_fedora/noid'

ActiveFedora::Noid.configure do |config|
  config.minter_class = MyMinter
end
```

And the service will delegate minting and validating to an instance of your customized minter class.

# Help

If you have questions or need help, please email [the Hydra community tech list](mailto:hydra-tech@googlegroups.com) or stop by the #dev channel in [the Hydra community Slack team](https://wiki.duraspace.org/pages/viewpage.action?pageId=43910187#Getintouch!-Slack): [![Slack Status](http://slack.projecthydra.org/badge.svg)](http://slack.projecthydra.org/)

# Acknowledgments

This software has been developed by and is brought to you by the Hydra community.  Learn more at the
[Project Hydra website](http://projecthydra.org/).

![Project Hydra Logo](http://sufia.io/assets/images/hydra_logo.png)
