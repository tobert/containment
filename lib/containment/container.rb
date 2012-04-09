require 'containment/cgroup'
require 'containment/ns'
require 'containment/init'
require 'containment/init/child_proxy'

module Containment
  class Container
    attr_reader :cgroup, :root, :nsflags, :init, :child

    def initialize(cgroup, root="/", nsflags=0)
      @cgroup = Cgroup.new cgroup
      @root = root
      @nsflags = nsflags
      @init = Init.new

      pid = Containment.nsfork @nsflags
      STDERR.puts "forked(#{$$} -> #{pid})!"
      if pid == 0
        @init.actor!
        @init.run
        abort "this must never return!"
      else
        @cgroup.attach pid
        @init.proxy!
      end
    end

    def spawn(env, command, args)
      @child = Init::ChildProxy.new(env, command, args)
      @init.spawn @child
    end

    def shutdown
      @init.shutdown
    end
  end
end
