module Containment
  class Cgroup::CPU
    attr_reader :cgroup
    def initialize(cgroup)
      @cgroup = cgroup
    end

    def rt_period_us
    end

    def rt_runtime_us
    end

    def shares
    end
  end
end

# vim: et ts=2 sw=2 ai smarttab ft=ruby
