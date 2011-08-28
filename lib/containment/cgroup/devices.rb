module Containment
  class Cgroup::Devices
    attr_reader :cgroup
    def initialize(cgroup)
      @cgroup = cgroup
    end

    def allow
    end

    def deny
    end

    def list
    end
  end
end

# vim: et ts=2 sw=2 ai smarttab ft=ruby
