require 'containment/cgroup'

module Containment
  class BlkIO
    attr_reader :cgroup

    def initialize(cgroup)
      @cgroup = cgroup
    end

    #File.read(File.join(@cgroup.path, "blkio.io_merged")).chomp
    def io_merged
    end

    def io_queued
    end

    def io_service_bytes
    end

    def io_service_time
    end

    def reset_stats
    end

    def sectors
    end

    def throttle
      #Containment::Cgroup::BlkIO::Throttle.new(@cgroup)
    end

    def weight
    end

    def weight_device
    end
  end
end

# vim: et ts=2 sw=2 ai smarttab ft=ruby
