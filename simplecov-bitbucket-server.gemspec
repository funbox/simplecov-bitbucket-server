require_relative 'lib/simplecov/formatter/bitbucket_server'

Gem::Specification.new do |gem|
  gem.name = 'simplecov-bitbucket-server'
  gem.version = SimpleCov::Formatter::BitbucketServer::VERSION
  gem.summary = 'Uploads test coverage data to Bitbucket Server via Code Coverage plugin'
  gem.homepage = 'https://github.com/funbox/simplecov-bitbucket-server'
  gem.author = 'Ilya Vassilevsky <i.vasilevskiy@fun-box.ru>'
  gem.license = 'MIT'

  gem.files = Dir.glob('lib/**/*.rb')

  gem.add_development_dependency 'simplecov'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'webmock'
  gem.add_development_dependency 'pry'
end
