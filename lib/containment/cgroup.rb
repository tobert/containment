module Containment
  class Cgroup
    attr_reader :name

    def initialize(cgroup_name)
      @name = cgroup_name
    end

    def tasks
      File.read(File.join($CGROUP_ROOT)
      raise "Stub! But this one is essential!"
    end

    def notify_on_release
      raise "Stub!"
    end

    def release_agent
      raise "Stub!"
    end
  end
end

# vim: et ts=2 sw=2 ai smarttab
