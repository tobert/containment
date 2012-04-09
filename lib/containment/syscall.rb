require 'containment/linux_constants'

# This is gross and disgusting. libffi support is stubbed out and not
# implemented.
# The syscall() that's exposed only supports 3-arg sys_clone() since
# that's all I need and doing full vararg & copy_(to|from)_user would
# be pretty duanting.
#
# It happens to work for getpid too, which is quite handy since Ruby
# caches Process.pid which is totally wrong for clone.

module Containment
  module Linux
    @syscall_func = lambda { |a,b,c| raise "could not syscall - platform probably isn't supported" }

    #  @libc_so is used to for DL.dlopen
    #  @syscall_getpid is used to test syscall()
    #  @syscall_func is the backend function

    # cribbed from ruby-1.9.2-p290/test/fiddle/helper.rb
    case [0].pack('L!').size

      # 32-bit untested AFAIK
      when 4
        if File.exists?("/lib32/libc.so.6")
          @libc_so = "/lib32/libc.so.6"
        end

        # used for testing at end of module init
        @syscall_getpid = Containment::Linux::ASM_X86_32::Unistd::NR_getpid

      # 64-bit - all of my machines & vm's are currently x86_64
      when 8
        if File.exists?("/lib64/libc.so.6")
          @libc_so = "/lib64/libc.so.6"
        end

        # used for testing at end of module init
        @syscall_getpid = Containment::Linux::ASM_X86_64::Unistd::NR_getpid

      # fall back the usual dir/symlink, probably works most of the time
      else
        @libc_so = "/lib/libc.so.6"
    end

    # detect a method for making syscalls
    # first try Kernel.syscall (ruby <= 1.8)
    begin
      Kernel.syscall(@syscall_getpid)
      @syscall_func = lambda {|syscall, arg0, arg1|
        Kernel.syscall(syscall, arg0, arg1)
      }
    rescue NotImplementedError => wtfbbq
      # now try fiddle (ruby >= 1.9.2??)
      begin
        require 'dl'
        require 'fiddle'

        # from linux/arch/x86/include/asm/syscalls.h:
        # long sys_clone(unsigned long, unsigned long, void __user *,
        #            void __user *, struct pt_regs *);
        # the last two fields aren't used - the man page says it's ok
        # to set the first void* to 0 to not set a stack
        libc = DL.dlopen(@libc_so)
        @syscall_func = Fiddle::Function.new(
          libc['syscall'],
          [
            Fiddle::TYPE_LONG,
            Fiddle::TYPE_LONG,
            Fiddle::TYPE_VOIDP
          ],
          Fiddle::TYPE_LONG
        )
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
    def syscall(nr, arg0, arg1)
      @syscall_func.call(nr, arg0, arg1)
    end

    begin
      pid = Containment::Linux::syscall(@syscall_getpid, 0, 0)
      #puts pid # uncomment for a quick test
    rescue
      raise "Containment::Linux::syscall() failed at bootstrap testing. Is your platform supported?"
    end

  end
end

# vim: et ts=2 sw=2 ai smarttab ft=ruby
