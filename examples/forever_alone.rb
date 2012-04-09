#!/usr/bin/env ruby

$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'containment'

cg = Containment::Cgroup.new(:forever_alone)

cg.system("ps -ef")

# vim: et ts=2 sw=2 ai smarttab
