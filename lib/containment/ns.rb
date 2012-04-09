require 'containment/constants'
require 'containment/syscall'

module Containment
  # namespace enabled fork()-ish function
  # pid = nsfork()
  #
  # to create a network namespace, add the CLONE_NEWNET flag
  # you will have to set up veth or whatever manually
  # pid = nsfork(Containment::Linux::Sched::CLONE_NEWNET)
  # 
  def self.nsfork(extra_flags=0)
    clone_flags = extra_flags \
                | Containment::Linux::Sched::CLONE_NEWNS \
                | Containment::Linux::Sched::CLONE_NEWIPC \
                | Containment::Linux::Sched::CLONE_NEWPID \
                | Containment::Linux::Sched::CLONE_NEWUTS \
                | Signal.list["CHLD"]

    Containment::Syscall.sys_clone(clone_flags)
  end
end

# vim: et ts=2 sw=2 ai smarttab ft=ruby
