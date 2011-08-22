require 'containment/linux_constants'
require 'containment/linux_syscall'

# TODO: it might be best to have this fall back to regular fork()
# on non-linux platforms or linux kernels without NS support to
# make testing & using dependents on this module on those platforms
# easier

module Containment
  module NS

    # the syscall number for SYS_clone is platform-dependent and even
    # runtime-dependent (e.g. 32-bit ruby on 64-bit Linux needs to call
    # the 32-bit syscall, not 64bit) This cheeziness should be good
    # enough for now, but is nowhere near ideal.
    
    if RUBY_PLATFORM == "x86_64-linux"
      @@sys_clone_nr = Containment::Linux::ASM_X86_64::Unistd::NR_CLONE
    # TODO: I don't have a 32bit box handy, make sure this is right ...
    else
      @@sys_clone_nr = Containment::Linux::ASM_X86_32::Unistd::NR_CLONE
    end

    # namespace enabled fork()-ish function
    # pid = nsfork()
    #
    # to create a network namespace, add the CLONE_NEWNET flag
    # you will have to set up veth or whatever manually
    # pid = nsfork(Containment::Linux::Sched::CLONE_NEWNET)
    # 
    module_function
    def nsfork(extra_flags=0)
      clone_flags = extra_flags \
                  | Containment::Linux::Sched::CLONE_NEWNS \
                  | Containment::Linux::Sched::CLONE_NEWIPC \
                  | Containment::Linux::Sched::CLONE_NEWPID \
                  | Containment::Linux::Sched::CLONE_NEWUTS \
                  | Containment::Linux::ASM_Generic::Signal::SIGCHLD
      sys_clone(clone_flags)
    end

    # you probably don't want to call this
    # see nsfork() above - it could be handy if you want to dink with
    # totally custom sets of flags
    def sys_clone(flags)
      # see clone(2) for a description of SYS_clone
      Containment::Linux::syscall(@@sys_clone_nr, flags, 0)
    end

  end
end

# vim: et ts=2 sw=2 ai smarttab ft=ruby
