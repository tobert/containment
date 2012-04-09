# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "containment/version"
 
Gem::Specification.new do |gem|
  gem.name        = "containment"
  gem.version     = Containment::VERSION
  gem.authors     = ["Al Tobey"]
  gem.email       = ["tobert@gmail.com"]
  gem.homepage    = "https://github.com/tobert/containment"
  gem.summary     = %q{Linux process containers}
  gem.description = %q{
  Linux has had lightweight process containers in the upstream kernel
  for a few years now. This lets you place additional constraints on
  processes over and above what the standard Unix/POSIX tools implement.
  It's a lot like LXC, but works directly against libc & the kernel.
  }

  #gem.rubyforge_project = "containment`"

  gem.add_dependency "ffi"

  gem.add_development_dependency "rake"
  gem.add_development_dependency "minitest"

  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.require_paths = ["lib"]
end

# vim: et ts=2 sw=2 ai smarttab

