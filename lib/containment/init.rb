require 'containment/init/child_actor'
require 'containment/init/child_proxy'
require 'containment/init/child_sup_actor'
require 'containment/init/child_sup_proxy'

module Containment
  #
  # An 'init' to run inside the container and all the bits needed to
  # control that init from outside.
  #
  # | root namespace & cgroup        | child namespace & cgroup    |
  # |--------------------------------|-----------------------------|
  # |                                |                             |
  # | <container> -> <init><proxy> --|--> <actor>.spawn            |
  # |                         |      |       /      \              |
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
    end

    #
    # push a ruby object to the other side of the pipe, should work from either side, on the appropriate pipe
    # @param [IO] pipe to write to
    # @param [Object] ruby object to serialize with Marshal
    #
    def push(io, data)
      # TEMPORARY debugging code ...
      case io
      when @p2c_r ; puts(">IO(#{Containment::Syscall.getpid}): p2c_r")
      when @p2c_w ; puts(">IO(#{Containment::Syscall.getpid}): p2c_w")
      when @c2p_r ; puts(">IO(#{Containment::Syscall.getpid}): c2p_r")
      when @c2p_w ; puts(">IO(#{Containment::Syscall.getpid}): c2p_w")
      end

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
      # TEMPORARY debugging code ...
      case io
      when @p2c_r ; puts("<IO(#{Containment::Syscall.getpid}): p2c_r")
      when @p2c_w ; puts("<IO(#{Containment::Syscall.getpid}): p2c_w")
      when @c2p_r ; puts("<IO(#{Containment::Syscall.getpid}): c2p_r")
      when @c2p_w ; puts("<IO(#{Containment::Syscall.getpid}): c2p_w")
      end
      lenbytes = io.read LEN_BYTES

      # TEMPORARY: trying to debug why the second call to pull() from the top
      # process always fails on eof ...
      if lenbytes.nil?
        raise "Impossibly closed!" if io.closed?
        raise "Impossible EOF!" if io.eof?
      end

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

    def output?
      Kernel.select [@console_r], [], [], 0
    end

    def proxy!
      @c2p_w.close
      @p2c_r.close
      @console_w.close
      STDERR.puts "Created ChildSupProxy"
      self.extend ChildSupProxy
      push @p2c_w, {:startup => true}
    end

    def actor!
      @c2p_r.close
      @p2c_w.close
      @console_r.close
      STDERR.puts "Created ChildSupActor"
      self.extend ChildSupActor
      pull @p2c_r
    end
  end
end

# vim: et ts=2 sw=2 ai smarttab ft=ruby
