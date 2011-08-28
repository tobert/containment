module Containment
  class Cgroup::BlkIO::Throttle
    attr_reader :cgroup
    def initialize(cgroup)
      @cgroup = cgroup
    end

    def io_service_bytes
    end

    def io_serviced
    end

    def read_bps_device
    end

    def read_iops_device
    end

    def write_bps_device
    end

    def write_iops_device
    end
  end
end

# vim: et ts=2 sw=2 ai smarttab ft=ruby
