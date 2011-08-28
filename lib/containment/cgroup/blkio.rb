require 'containment/cgroup'
require 'containment/util'

module Containment
  class BlkIO
    include Containment::Util # import slurp*, echo
    attr_reader :cgroup

    def initialize(cgroup)
      @cgroup = cgroup
    end

    def io_merged
      raise "Stub!"
    end

    def io_queued
      raise "Stub!"
    end

    def io_service_bytes
      raise "Stub!"
    end

    def io_service_time
      raise "Stub!"
    end

    def reset_stats
      raise "Stub!"
    end

    def sectors
      raise "Stub!"
    end

    def throttle
      #Containment::Cgroup::BlkIO::Throttle.new(@cgroup)
    end

    def weight(weight_in)
      path = File.join(@cgroup.path, 'blkio.weight')

      # set the weight
      if weight_in != nil
        echo weight_in path
      end

      out = slurp_int path
      if weight_in != nil and out != weight_in
        raise "failed to set blkio.weight from #{out} to desired value of #{weight_in}"
      end
      return out
    end

    def weight_device
    end
  end
end

# vim: et ts=2 sw=2 ai smarttab ft=ruby
