require File.join([File.dirname(__FILE__),"lib","dockerize-ruby","version.rb"])

Gem::Specification.new do |s|
  s.name        = 'dockerize-ruby'
  s.version     = DockerizeRuby::VERSION
  s.executables << 'dockerize-ruby'
  s.summary     = "A ruby gem for dockerize your app!"
  s.description =
    "Dockerize, bootstrap and develop any ruby app in a faster way."
  s.authors     = ["Luilver Garces"]
  s.email       = 'luilver@gmail.com'
  s.files       = ["lib/dockerize-ruby.rb"]
  s.homepage    =
    'https://github.com/luilver/dockerize-ruby'
  s.license       = 'Apache-2.0'

  s.add_development_dependency 'rake'
  s.add_development_dependency 'minitest'

  s.add_runtime_dependency 'gli'
end
