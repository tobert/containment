require 'containment/ns'

pid = Containment::NS::nsfork(0)
if pid != nil then
    puts "child pid is #{pid}"
end

exit 0
