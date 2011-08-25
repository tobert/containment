# -*- encoding: utf-8 -*-

$:.push File.expand_path("../lib", __FILE__)

require "containment/version"
 
Gem::Specification.new do |s|
  s.name        = "containment"
  s.version     = containment::VERSION
  s.authors     = ["Al Tobey"]
  s.email       = ["tobert@gmail.com"]
  s.homepage    = "https://github.com/tobert/containment"
  s.summary     = %q{Linux process containers}
  s.description = %q{
  Linux has had lightweight process containers in the upstream kernel
  for a few years now. This lets you place additional constraints on
  processes over and above what the standard Unix/POSIX tools implement.
  }

  #s.rubyforge_project = "containment`"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end

# vim: et ts=2 sw=2 ai smarttab

