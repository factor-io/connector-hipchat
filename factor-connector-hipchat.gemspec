# encoding: UTF-8
$LOAD_PATH.push File.expand_path('../lib', __FILE__)

Gem::Specification.new do |s|
  s.name          = 'factor-connector-hipchat'
  s.version       = '0.0.3'
  s.platform      = Gem::Platform::RUBY
  s.authors       = ['Maciej Skierkowski']
  s.email         = ['maciej@factor.io']
  s.homepage      = 'https://factor.io'
  s.summary       = 'Hipchat Factor.io Connector'
  s.files         = ['lib/factor/connector/hipchat.rb']
  
  s.require_paths = ['lib']

  s.add_runtime_dependency 'httparty', '~> 0.13.3'
  s.add_runtime_dependency 'factor-connector-api', '~> 0.0.14'

  s.add_development_dependency 'codeclimate-test-reporter', '~> 0.4.5'
  s.add_development_dependency 'rspec', '~> 3.1.0'
  s.add_development_dependency 'rake', '~> 10.4.2'
end
