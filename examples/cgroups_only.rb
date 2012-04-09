#!/usr/bin/env ruby

$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'containment/cgroup'

root_cg = Containment::Cgroup.new("root", "/cgroup")
root_tasks = root_cg.tasks
root_children = root_cg.children

puts "The root CG has #{root_tasks.count} tasks assigned to it."
puts "The root CG has #{root_children.count} children: #{root_children.join(', ')}"
puts "Notify on release is #{root_cg.notify_on_release}."

exit 0
