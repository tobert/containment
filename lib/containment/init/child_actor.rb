module Containment
  class Init
    module ChildActor
      #
      # Create a new process. A "grandchild" process, if you will.
      # @return [Fixnum] pid
      #
      def spawn
        raise "spawn() can only be called once" if @pid
        
        @stdin_r, @stdin    = IO.pipe
        @stdout,  @stdout_w = IO.pipe
        @stderr,  @stderr_w = IO.pipe

        @started = Time.now

        # BUG / TODO: why is this hanging!??!?
        STDERR.puts "about to: [#{@command} #{@argv.join(' ')}] with env #{@env.inspect}"
        @pid = Kernel.spawn(@env, @command, *@argv,
          :in  => @stdin_r,
          :out => @stdout_w,
          :err => @stderr_w,
        )
        STDERR.puts "spawned pid #{@pid}"

        # TODO: set up forwarding of io handles of child to the parent proxy over @console_w with a prefix

        @stdin_r.close
        @stdout_w.close
        @stderr_w.close

        @key = [(@started.to_f * 1_000_000).round, @pid].pack('QQ').unpack('H*')
        @pid
      end

      #
      # Call waitpid on the process, return the response. Called with WNOHANG by default.
      # @param [Fixnum] optional flags to Process.waitpid2 (e.g. 0)
      # @return [Fixnum] pid
      #
      def waitpid(flags=Process::WNOHANG)
        raise "cannot call waitpid() before spawn()" unless @pid

        pid, @status = Process.waitpid2(@pid, flags)

        if @status and pid == @pid
          @ended = Time.now
        end

        pid
      end

      #
      # Kill the child process with the given signal. Defaults to SIGQUIT.
      # @param [Fixnum] signal
      #
      def kill(sig=DEFAULT_SIGNAL)
        raise "cannot call kill() before spawn()" unless @pid
        Process.kill sig, @pid
      end

      def uptime
        if @ended
          @uptime = @ended - @started
        elsif @started
          @uptime = Time.now - @started
        else
          raise "cannot call uptime() before spawn()"
        end
      end

      #
      # Make a full copy of the child's state in a ChildData object.
      # @return [Containment::Init::ChildProxy] info
      #
      def info
        info = ChildProxy.new @env, @command, @argv
        info.from_hash self.to_hash
        info
      end
    end
  end
end

# vim: et ts=2 sw=2 ai smarttab ft=ruby
