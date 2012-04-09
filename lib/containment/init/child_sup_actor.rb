module Containment
  class Init
    #
    # This is the "init" process inside the container. It gets commands marshaled over
    # a unix pipe and responds over another one.
    # This is meant to be an extension to ChildSupProxy inside the "init" process.
    #
    # TODO: add signal handlers
    #
    module ChildSupActor
      #
      # Run the infinite init process.
      #
      def run
        @children = {}

        $stdout.reopen(@console_w)
        $stderr.reopen(@console_w)
        
        @running = true
        while @running
          action, subject, params = pull @p2c_r

          STDERR.puts "Got command: #{action}, subject, params = pull @p2c_r"

          if subject.kind_of?(String) and @children.has_key?(subject)
            subject = @children[subject]
          end

          result = case action
            when :spawn
              subject.extend ChildActor
              subject.spawn
              @children[subject.key] = subject
              subject.info
            when :status
              @children[subject.key].waitpid
              @children[subject.key].info
            when :kill
              result = @children[subject.key].kill params
              Thread.pass # force a context switch
              @children[subject.key].info
            when :reap
              reap
            when :exit
              @running = false
              break
          end # case action

          push @c2p_w, result
        end

        @p2c_r.close
        @c2p_w.close
      end

      #
      # Check the status of all (known) children.
      # @return [Array<ChildProxy>] list of child info
      #
      def reap
        out = []
        @children.each do |key,child|
          pid = child.waitpid
          out << child.info

          # dead or missing processes, forget about them
          if pid == -1 or pid == child.pid
            @children.delete(key)
          end
        end
        out
      end

      #
      # Kill the process with the provided signal (default SIGQUIT).
      # @param [Fixnum,String] signal to send
      # @param [String] key for the process
      #
      def kill(sig=DEFAULT_SIGNAL, key)
        @children[key].kill sig
      end
    end
  end
end

# vim: et ts=2 sw=2 ai smarttab ft=ruby
