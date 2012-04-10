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

      # temporary, dangerous
      # will reimplement this with an ffi binding to the mknod function
      # and run it inside the container before dropping privileges
      %w[/dev/null /dev/zero /dev/console].each do |dev|
        unless File.exists? File.join(@root, dev)
          system "cp -a #{dev} #{File.join(@root, dev)}"
        end
      end

      pid = Containment.nsfork @nsflags
      if pid == 0
        STDERR.puts "(child) nsforked(#{$$} -> #{pid})!"
        Dir.chroot @root
        @init.actor!
        @init.run
        abort "this must never return!"
      elsif pid
        STDERR.puts "(parent) nsforked(#{$$} -> #{pid})!"
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
