require 'containment/linux_constants'

# This is gross and disgusting. libffi support is stubbed out and not
# implemented.

module Containment
  module Linux
    @syscall_func = lambda { raise "could not syscall - platform probably isn't supported" }

    #  Libc_so is used to for DL.dlopen
    #  @syscall_getpid is used to test syscall()
    #  @syscall_func is the backend function

    # cribbed from ruby-1.9.2-p290/test/fiddle/helper.rb
    case [0].pack('L!').size

      # 32-bit untested AFAIK
      when 4
        if File.exists?("/lib32/libc.so.6")
          Libc_so = "/lib32/libc.so.6"
        end

        # from /usr/include/asm/unistd_32.h
        @syscall_getpid = 20

      # 64-bit - all of my machines & vm's are currently x86_64
      when 8
        if File.exists?("/lib64/libc.so.6")
          Libc_so = "/lib64/libc.so.6"
        end

        # from /usr/include/asm/unistd_32.h
        @syscall_getpid = 39

      # fall back to best-guess & asm-generic which probably
      # doesn't work anywhere :(
      else
        Libc_so = "/lib/libc.so.6"

        # from /usr/include/asm-generic/unistd.h
        @syscall_getpid = 172
    end

    # detect a method for making syscalls
    # first try Kernel.syscall (ruby <= 1.8)
    begin
      Kernel.syscall(@syscall_getpid)
      @syscall_func = lambda {|syscall, flags|
        Kernel.syscall(syscall, flags)
      }
    rescue NotImplementedError => wtfbbq
      # now try fiddle (ruby >= 1.9.2??)
      begin
        require 'dl'
        require 'fiddle'
        libc = DL.dlopen(Libc_so)
        int = Fiddle::TYPE_INT
        @syscall_func = Fiddle::Function.new(libc['syscall'], [int, int], int)

      rescue
        # and finally, libffi - should work everywhere, even jruby??
        begin
          require 'libffi'
          raise "BUG: Fell back to libffi succesfully, but support is not implemented yet!"
        rescue
          raise "Could not load an interface for making syscalls. Tried Kernel.syscall, fiddle, and libffi."
        end
      end
    end


    # this is a limited interface to syscall() that doesn't have
    # to mess around with varargs
    module_function
    def syscall(nr, flags)
      @syscall_func.call(nr, flags)
    end

    begin
      pid = Containment::Linux::syscall(@syscall_getpid, 0) 
      #puts pid
    rescue
      raise "Containment::Linux::syscall() failed at bootstrap testing. Is your platform supported?"
    end

  end
end

# vim: et ts=2 sw=2 ai smarttab ft=ruby
