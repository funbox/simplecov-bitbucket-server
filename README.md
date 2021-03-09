# SimpleCov to Bitbucket Server

[![Gem Version](https://img.shields.io/gem/v/simplecov-bitbucket-server.svg)](https://rubygems.org/gems/simplecov-bitbucket-server)
[![Travis CI](https://img.shields.io/travis/com/funbox/simplecov-bitbucket-server.svg)](https://travis-ci.com/github/funbox/simplecov-bitbucket-server)
[![Coveralls](https://img.shields.io/coveralls/funbox/simplecov-bitbucket-server.svg)](https://coveralls.io/github/funbox/simplecov-bitbucket-server)

A [SimpleCov](https://rubygems.org/gems/simplecov) formatter that uploads coverage data to a Bitbucket Server instance via [Code Coverage](https://marketplace.atlassian.com/apps/1218271/code-coverage-for-bitbucket-server) plugin.

## Installation

```ruby
# Gemfile

group :test do
  gem 'simplecov-bitbucket-server', '~> 1.0'
end


# spec/spec_helper.rb

require 'simplecov/formatter/bitbucket_server'

SimpleCov.formatter = SimpleCov::Formatter::BitbucketServer.new('https://your.bitbucket.host')
```

## Usage

Run your test suite as usual. At the end SimpleCov will run the formatter. The formatter will post data to the server.

### Commit SHA

Coverage data is uploaded for a certain commit. This commit is the tip of the branch from which the pull request is created. The formatter takes the commit SHA from an environment variable called `GIT_COMMIT` (set by Jenkins).

If you need to pass the commit SHA from some other source, pass it as the second argument to the formatter's constructor. For example:

```ruby
commit = ENV['TRAVIS_COMMIT']

SimpleCov.formatter = SimpleCov::Formatter::BitbucketServer.new('https://your.bitbucket.host', commit)
```

[![Sponsored by FunBox](https://funbox.ru/badges/sponsored_by_funbox_centered.svg)](https://funbox.ru)
