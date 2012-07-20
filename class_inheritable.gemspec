# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "class_inheritable/version"

Gem::Specification.new do |s|
  s.name        = "class_inheritable"
  s.version     = ClassInheritable::VERSION
  s.authors     = ["JayTeeSr"]
  s.email       = ["jaytee_sr_at_his-service_dot_net"]
  s.homepage    = "https://github.com/JayTeeSF/class_inheritable"
  s.summary     = %q{Duplicate Rails old class_inheritable_array sans base-class monkey-patching}
  s.description = %q{Duplicate Rails old class_inheritable_array sans base-class monkey-patching}
  s.rubyforge_project = "class_inheritable"
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.bindir        = 'bin'
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_development_dependency "rspec", "~> 2.11.0"
end
