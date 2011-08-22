require 'containment/ns'

puts "Parent pid is #{Process.pid}"

pid = Containment::NS::nsfork(0)
if pid == 0 then
    puts "child process thinks its pid is #{Process.pid}"
else
    puts "child pid is #{pid}"
end

exit 0
