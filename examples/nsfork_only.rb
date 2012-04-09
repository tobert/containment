#!/usr/bin/env ruby

$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'containment/ns'

puts "Parent pid is #{Process.pid}"

pid = Containment.nsfork(0)
if pid == 0 then
    puts "Process.pid thinks the pid is #{Process.pid}, but that's a lie!"
    begin
        puts "the child process really is #{Containment::Syscall.getpid}"
    rescue => wtf
        puts "getpid failed: #{wtf}"
    end
else
    puts "child pid is #{pid}"
    exit 0
end

exit 0
