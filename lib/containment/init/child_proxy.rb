module Containment
  class Init
    class ChildProxy
      attr_reader :env, :command, :argv
      attr_reader :key, :pid, :status, :started, :ended

      #
      # Create a new child process proxy. This class contains only data, no behavior.
      # @param [Hash] environment, e.g. ENV.clone
      # @param [String] command to run, should be fully-qualified
      # @param [Array<String>,String] arguments to the command (will be vivified to array and/or flattened)
      #
      def initialize(env, command, argv)
        @env = env
        @command = command
        @argv = argv
        @status = nil
        @pid = nil
        @started = nil
        @ended = nil
      end

      #
      # Return all of the child's information in hash
      #
      def to_hash
        {
          :key     => @key,
          :env     => @env,
          :command => @command,
          :argv    => @argv,
          :status  => self.respond_to?(:status) ? status : @status,
          :pid     => @pid,
          :started => @started,
          :ended   => @ended,
          :uptime  => self.respond_to?(:uptime) ? uptime : @uptime,
        }
      end

      def info
        stub = ChildProxy.new '', '', ''
        stub.merge! self
        stub
      end

      protected

      #
      # Update internal state from another object, usually a ChildActor.
      #
      def merge!(real)
        @key     = real.key
        @env     = real.env
        @command = real.command
        @argv    = real.argv
        @status  = real.status
        @pid     = real.pid
        @started = real.started
        @ended   = real.ended
        @uptime  = real.uptime
      end
    end
  end
end

# vim: et ts=2 sw=2 ai smarttab ft=ruby
