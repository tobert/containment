require 'containment/ns'

puts "Parent pid is #{Process.pid}"

pid = Containment::NS.nsfork(0)
if pid == 0 then
    puts "Process.pid thinks the pid is #{Process.pid}, but that's a lie!"
    begin
        puts "the child process really is #{Containment::NS.getpid}"
    rescue => wtf
        puts "getpid failed: #{wtf}"
    end
else
    puts "child pid is #{pid}"
end

exit 0
