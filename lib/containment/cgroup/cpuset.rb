module Containment
  class Cgroup::CPUSet
    attr_reader :cgroup
    def initialize(cgroup)
      @cgroup = cgroup
    end

    def cpu_exclusive
    end

    def cpus
    end

    def mem_exclusive
    end

    def mem_hardwall
    end

    def memory_migrate
    end

    def memory_pressure
    end

    def memory_pressure_enabled
    end

    def memory_spread_page
    end

    def memory_spread_slab
    end

    def mems
    end

    def sched_load_balance
    end

    def sched_relax_domain_level
    end
  end
end

# vim: et ts=2 sw=2 ai smarttab ft=ruby
