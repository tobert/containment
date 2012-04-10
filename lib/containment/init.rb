require 'containment/init/init_actor'
require 'containment/init/init_proxy'
require 'containment/init/child_actor'
require 'containment/init/child_proxy'

module Containment
  #
  # An 'init' to run inside the container and all the bits needed to
  # control that init from outside.
  #
  # | root namespace & cgroup        | child namespace & cgroup    |
  # |--------------------------------|-----------------------------|
  # | <container>                    |                             |
  # |      <init>---><init  proxy> --|--> <init actor>.spawn       |
  # |                         |      |       /           /         |
  # |                <child proxy> <-|-------     <child process>  |
  # |________________________________|_____________________________|
  #
  class Init
    LEN_PACK = 'L'
    LEN_BYTES = [1].pack(LEN_PACK).bytesize
    DEFAULT_SIGNAL = Signal.list["QUIT"]
      
    #
    # Setup basic resources.
    #
    def initialize
      @p2c_r, @p2c_w = IO.pipe
      @c2p_r, @c2p_w = IO.pipe
      @console_r, @console_w = IO.pipe
      @console_thread = nil
    end

    #
    # push a ruby object to the other side of the pipe, should work from either side, on the appropriate pipe
    # @param [IO] pipe to write to
    # @param [Object] ruby object to serialize with Marshal
    #
    def push(io, data)
      packet = Marshal.dump data
      lenbytes = [packet.bytesize].pack(LEN_PACK)
      io.write lenbytes
      io.write packet
      io.flush
      Thread.pass
    end

    #
    # receive a ruby object from the other side of the pipe
    # @param [IO] pipe to read from
    # @return [Object] deserialized data
    #
    def pull(io)
      lenbytes = io.read LEN_BYTES

      # this showed up in early testing ...
      raise "BUG! - read from a pipe should never EOF" if lenbytes.nil?

      cmdlen = lenbytes.unpack(LEN_PACK)[0]
      packet = io.read cmdlen
      if packet.bytesize == cmdlen
        STDERR.puts "Pulled: #{Marshal.load(packet).inspect}"
        Marshal.load packet
      else
        raise "Corrupt/truncated packet!: #{packet.inspect}"
      end
    end

    def proxy!
      @p2c_r.close
      @c2p_w.close
      @console_w.close
      STDERR.puts "Created InitProxy"
      self.extend InitProxy

      @console_thread = Thread.new do
        @console_r.each_line do |line|
          STDERR.print line
        end
      end
      push @p2c_w, {:startup => true}
    end

    def actor!
      @p2c_w.close
      @c2p_r.close
      @console_r.close
      STDERR.puts "Created InitActor"
      self.extend InitActor
      pull @p2c_r
    end
  end
end

# vim: et ts=2 sw=2 ai smarttab ft=ruby
