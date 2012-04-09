module Containment
  class Init
    module ChildSupProxy
      def spawn(child)
        push @p2c_w, [:spawn, child, nil]
        pull @c2p_r
      end

      def kill(sig=DEFAULT_SIGNAL, child)
        push @p2c_w, [:kill, child, sig]
        pull @c2p_r
      end

      def reap
        push @p2c_w, [:reap, nil, nil]
        pull @c2p_r
      end

      def status(child)
        push @p2c_w, [:status, child, nil]
        pull @c2p_r
      end

      def shutdown
        push @p2c_w, [:exit, nil, nil]
        @p2c_w.close
        @c2p_r.close
      end
    end
  end
end

# vim: et ts=2 sw=2 ai smarttab ft=ruby
