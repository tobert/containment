module Containment
  class Cgroup::Memory
    attr_reader :cgroup
    def initialize(cgroup)
      @cgroup = cgroup
    end

    def failcnt
    end

    def force_empty
    end

    def limit_in_bytes
    end

    def max_usage_in_bytes
    end

    def memsw
      Containment::Cgroup::Memory::MemSw.new(@cgroup)
    end

    def move_charge_at_immigrate
    end

    def oom_control
    end

    def soft_limit_in_bytes
    end

    def stat
    end

    def swappiness
    end

    def usage_in_bytes
    end

    def use_hierarchy
    end

  end
end

# vim: et ts=2 sw=2 ai smarttab ft=ruby
