# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)

Gem::Specification.new do |s|
  s.name        = "installer-ng"
  s.version     = '0.0.1'
  s.authors     = ['Scalr, Inc.']
  s.email       = ['thomas@scalr.com']
  s.homepage    = "https://github.com/scalr/installer-ng"
  s.summary     = %q{Scalr installer}
  s.description = %q{Scalr installer}

  s.rubyforge_project = "installer-ng"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']
end
