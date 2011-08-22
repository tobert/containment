module Containment
  class Cgroup
    attr_reader :name
    attr_reader :path

    def initialize(cgroup_name)
      @name = cgroup_name
      @path = File.join('/cgroup', @name)

      if not Dir.exists?(@path)
        Dir.mkdir(@path)
      end
    end

    # Attaches the +pid+ specified to the cgroup.
    def attach_pid(pid)
      File.open(File.join(@path, 'tasks'), "w") do |tasks|
        tasks.puts(pid)
      end
    end

    # Returns a list of pids attached to the cgroup.
    def tasks
      task_list = []
      File.open(File.join(@path, 'tasks'), "r") do |t|
        while (task = t.gets)
          task.chomp!
          task_list.push task
        end
      end
      return task_list
    end

    # Returns a list of child cgroups.
    def children
      children = []
      Dir.open(@path) do |file|
        next if file.start_with?(".")

        cpath = File.join(@path, file)

        if File.ftype(cpath) == "directory" then
          cg = Containment::Cgroup.new(cpath)
          children.push(cg)
        end
      end
    end

    def notify_on_release
      raise "Stub!"
    end

    def release_agent
      raise "Stub!"
    end

    def cgroup_clone_children
      raise "Stub!"
    end

    def cgroup_event_control
      raise "Stub!"
    end

    def cgroup_procs
      raise "Stub!"
    end

  end
end

# vim: et ts=2 sw=2 ai smarttab
