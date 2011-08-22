require 'containment/cgroup'

root_cg = Containment::Cgroup.new("/")
root_tasks = root_cg.tasks
root_children = root_cg.children

puts "The root CG has #{root_tasks.count} tasks assigned to it."
puts "The root CG has #{root_children.count} children."

exit 0
