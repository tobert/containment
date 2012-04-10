#!/usr/bin/env ruby

$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'containment/container'

ct = Containment::Container.new "test1"
ct.spawn({"PATH" => "/bin"}, "/bin/cat", ['/proc/mounts'])
ct.reap
ct.shutdown
sleep 1
