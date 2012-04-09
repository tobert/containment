require 'containment/constants'
require 'ffi'

module Containment
  module Syscall
    extend FFI::Library

    ffi_lib [FFI::CURRENT_PROCESS, 'c']

    attach_variable :errno, :int

    # only set up a 2-argument version, works fine for both of my use cases
    attach_function :sys_syscall, :syscall, [:long, :ulong, :ulong], :long
    
    def self.sys_clone(flags)
      rc = sys_syscall(Containment::ASM::Unistd::NR_clone, flags, 0)
      if rc < 0
        raise "sys_clone() failed."
      end
      rc
    end

    def self.getpid
      rc = sys_syscall(Containment::ASM::Unistd::NR_getpid, 0, 0)
    end
  end
end

# vim: et ts=2 sw=2 ai smarttab ft=ruby
