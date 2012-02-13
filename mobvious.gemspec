# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "mobvious/version"

Gem::Specification.new do |s|
  s.name        = "mobvious"
  s.version     = Mobvious::VERSION
  s.authors     = ["Jiří Stránský"]
  s.email       = ["jistr@jistr.com"]
  s.homepage    = "http://github.com/jistr/mobvious"
  s.summary     = %q{Rack middleware for choosing a version of an interface to render for given request}
  s.description = %q{Rack middleware for choosing a version of an interface to render for given request}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency "rack", ">= 1.2.0"
  s.add_runtime_dependency "mobileesp"


  # == DEVELOPMENT DEPENDENCIES ==
  # Smart irb
  s.add_development_dependency 'pry'

  # Specs
  s.add_development_dependency 'minitest'
  s.add_development_dependency 'mocha'
  s.add_development_dependency 'rack-test'

  # Running tests during development
  s.add_development_dependency 'guard'
  s.add_development_dependency 'guard-minitest'
  # Linux Guard watching
  s.add_development_dependency 'rb-inotify'
  # Linux Guard notifications
  s.add_development_dependency 'libnotify'

  # Pretty printed test output
  s.add_development_dependency 'turn'
end
