Code: [![Version](https://badge.fury.io/rb/noid-rails.png)](http://badge.fury.io/rb/noid-rails)
[![Build Status](https://travis-ci.org/samvera/noid-rails.png?branch=master)](https://travis-ci.org/samvera/noid-rails)
[![Coverage Status](https://coveralls.io/repos/github/samvera/noid-rails/badge.svg?branch=master)](https://coveralls.io/github/samvera/noid-rails?branch=master)
[![Code Climate](https://codeclimate.com/github/samvera/noid-rails/badges/gpa.svg)](https://codeclimate.com/github/samvera/noid-rails)

Docs: [![Documentation Status](https://inch-ci.org/github/samvera/noid-rails.svg?branch=master)](https://inch-ci.org/github/samvera/noid-rails)
[![API Docs](http://img.shields.io/badge/API-docs-blue.svg)](http://rubydoc.info/gems/noid-rails)
[![Contribution Guidelines](http://img.shields.io/badge/CONTRIBUTING-Guidelines-blue.svg)](./CONTRIBUTING.md)
[![Apache 2.0 License](http://img.shields.io/badge/APACHE2-license-blue.svg)](./LICENSE)

# Noid::Rails

Mint identifiers for models in your Rails-based application with opaque [Noid](https://wiki.ucop.edu/display/Curation/NOID)-based identifiers.

**This gem depends only upon Rails, not on ActiveFedora**

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

    gem 'noid-rails'

And then execute:

    $ bundle install

Or install it yourself via:

    $ gem install noid-rails

# Usage

## Minting and validating identifiers

Mint a new Noid:

```ruby
noid_service = Noid::Rails::Service.new
noid = noid_service.mint
```

This creates a Noid with the default identifier template, which you can override (see below).  Now that you have a service object with a template, you can also use it to validate identifiers to see if they conform to the template:

```ruby
noid_service.valid? 'xyz123foobar'
> false
```

## ActiveFedora integration

To get ActiveFedora to automatically call your Noid service whenever a new ActiveFedora object is saved, include the `Noid::Rails::Model`, e.g.:

```ruby
# app/models/my_object.rb
require 'noid-rails'

class MyObject < ActiveFedora::Base
  ## This overrides the default behavior, which is to ask Fedora for an id
  # @see ActiveFedora::Persistence.assign_id
  def assign_id
    service.mint
  end

  private

  def service
    @service ||= Noid::Rails::Service.new
  end
end
```

### Identifier/URI translation

As Noid::Rails overrides the default identifier minting strategy in ActiveFedora, you will need to let ActiveFedora know how to translate identifiers into URIs and vice versa so that identifiers are laid out in a sustainable way in Fedora.  Add the following to e.g. `config/initializers/active_fedora.rb`:

```ruby
baseparts = 2 + [(Noid::Rails::Config.template.gsub(/\.[rsz]/, '').length.to_f / 2).ceil, 4].min
ActiveFedora::Base.translate_uri_to_id = lambda do |uri|
                                           uri.to_s.sub(baseurl, '').split('/', baseparts).last
                                         end
ActiveFedora::Base.translate_id_to_uri = lambda do |id|
                                           "#{baseurl}/#{Noid::Rails.treeify(id)}"
                                         end
```

This will make sure your objects have Noid-like identifiers (e.g. `bb22bb22b`) that map to URIs in Fedora (e.g. `bb/22/bb/22/bb22bb22b`).

## Overriding default behavior

The default minter in Noid::Rails is the file-backed minter to preserve default behavior.

To better support multi-host production installations that expect a shared database but not necessarily a shared filesystem (e.g., between load-balanced Rails applications), we highly recommend swapping in the database-backed minter.

### Use database-based minter state

The database-based minter stores minter state information in your application's relational database. To use it, you'll first need to run the install generator:

```bash
$ rails generate active_fedora:noid:install
```

This will create the necessary database migrations.

Then run `rake db:migrate`

To start minting identifiers with the new minter, override the AF::Noid configuration in e.g. `config/initializers/noid-rails.rb`:

```ruby
require 'active_fedora/noid'

Noid::Rails.configure do |config|
  config.minter_class = Noid::Rails::Minter::Db
end
```

Using the database-backed minter can cause problems with your test suite, where it is often sensible to wipe out database rows between tests (which destroys the database-backed minter's state, which renders it unusable). To deal with this and still get the benefits of using the database-backed minter in development and production environments, you'll also want to add the following helper to your `spec/spec_helper.rb`:

```ruby
require 'active_fedora/noid/rspec'

RSpec.configure do |config|
  include Noid::Rails::RSpec

  config.before(:suite) { disable_production_minter! }
  config.after(:suite)  { enable_production_minter! }
end
```

If you switch to the new database-backed minter and want to include in that minter the state of your current file-backed minter, Noid::Rails 2.x provides a new rake task that will copy your minter's state from the filesystem to the database:

```bash
# For migrating minter state from a file to a database
$ rake noid:rails:migrate:file_to_database
# For migrating minter state from a database to a file
$ rake noid:rails:migrate:database_to_file
```

### Identifier template

To override the default identifier pattern -- a nine-character string consisting of two alphanumeric digits, two numeric digits, two alphanumeric digits, two numeric digits, and a check digit -- put the following code in e.g. `config/initializers/noid-rails.rb`:

```ruby
require 'noid-rails'

Noid::Rails.configure do |config|
  config.template = '.ddddd'
end
```

For more information about the format of Noid patterns, see pages 8-10 of the [Noid documentation](https://wiki.ucop.edu/download/attachments/16744482/noid.pdf).

### Custom minters

If you don't want your minter's state to be persisted, you may also write and configure your own minter.  First write up a minter class that looks like the following:

```ruby
class MyMinter < Noid::Rails::Minter::Base
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

Then add your new minter class to the Noid::Rails configuration (`config/initializers/noid-rails.rb`):

```ruby
require 'noid-rails'

Noid::Rails.configure do |config|
  config.minter_class = MyMinter
end
```

And the service will delegate minting and validating to an instance of your customized minter class.

# Help

If you have questions or need help, please email [the Samvera community tech list](mailto:samvera-tech@googlegroups.com) or stop by the #dev channel in [the Samvera community Slack team](https://wiki.duraspace.org/pages/viewpage.action?pageId=87460391#Getintouch!-Slack: [![Slack Status](http://slack.samvera.org/badge.svg)](http://slack.samvera.org/)

# Acknowledgments

This software has been developed by and is brought to you by the Samvera community.  Learn more at the
[Samvera website](http://samvera.org/).

![Samvera Logo](https://wiki.duraspace.org/download/thumbnails/87459292/samvera-fall-font2-200w.png?version=1&modificationDate=1498550535816&api=v2)
