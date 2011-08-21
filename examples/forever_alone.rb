#!/bin/env ruby
#
# ruby -I./lib examples/forever_alone.rb

require 'containment'

container = Containment.new("forever_alone")

container.system("ps -ef")

# vim: et ts=2 sw=2 ai smarttab
