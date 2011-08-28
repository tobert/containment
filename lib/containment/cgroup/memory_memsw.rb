module Containment
  class Cgroup::Memory
    attr_reader :cgroup
    def initialize(cgroup)
      @cgroup = cgroup
    end

    def failcnt
    end

    def limit_in_bytes
    end

    def max_usage_in_bytes
    end

    def usage_in_bytes
    end
  end
end

# vim: et ts=2 sw=2 ai smarttab ft=ruby
