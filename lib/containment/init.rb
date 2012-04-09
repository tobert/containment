require 'containment/init/child_actor'
require 'containment/init/child_proxy'
require 'containment/init/child_sup_actor'
require 'containment/init/child_sup_proxy'

module Containment
  class Init
    LEN_PACK = 'L'
    LEN_BYTES = [1].pack(LEN_PACK).bytesize
    DEFAULT_SIGNAL = Signal.list["QUIT"]
      
      def initialize(*args)
        @p2c_r, @p2c_w = IO.pipe
        @c2p_r, @c2p_w = IO.pipe
        @console_r, @console_w = IO.pipe
      end

      def push(io, data)
        packet = Marshal.dump data
        lenbytes = [packet.bytesize].pack(LEN_PACK)
        io.print lenbytes << packet
        io.flush
        Thread.pass
      end

      def pull(io)
        lenbytes = io.read LEN_BYTES
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
        @c2p_w.close
        @p2c_r.close
        STDERR.puts "Created ChildSupProxy"
        self.extend ChildSupProxy
        push @p2c_w, {:startup => true}
      end

      def actor!
        @c2p_r.close
        @p2c_w.close
        STDERR.puts "Created ChildSupActor"
        self.extend ChildSupActor
        pull @p2c_r
      end
  end
end

# vim: et ts=2 sw=2 ai smarttab ft=ruby
