$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'raven/version'

Gem::Specification.new do |gem|
  gem.name = "sentry-raven"
  gem.authors = ["Sentry Team"]
  gem.description = gem.summary = "A gem that provides a client interface for the Sentry error logger"
  gem.email = "accounts@sentry.io"
  gem.license = 'Apache-2.0'
  gem.homepage = "https://github.com/getsentry/raven-ruby"

  gem.version = Raven::VERSION
  gem.platform = Gem::Platform::RUBY
  gem.required_ruby_version = '>= 2.3'
  gem.extra_rdoc_files = ["README.md", "LICENSE"]
  gem.files = `git ls-files | grep -Ev '^(spec|benchmarks|examples)'`.split("\n")
  gem.bindir = "exe"
  gem.executables = "raven"

  gem.add_dependency "faraday", ">= 0.9"

  gem.post_install_message = <<~EOS
    `sentry-raven` is deprecated! Please migrate to `sentry-ruby`

    See https://docs.sentry.io/platforms/ruby/migration for the migration guide.

  EOS
end
