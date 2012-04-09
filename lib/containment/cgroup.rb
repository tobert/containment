module Containment 
  class Cgroup
    attr_reader :name, :path

    def initialize(name, path)
      @name = name
      @path = path

      if not File.directory?(@path)
        Dir.mkdir(@path)
      end
    end

    # Attaches the +pid+ and its threads specified to the cgroup.
    def attach(pid)
      # all of a process's threads are in /proc/<pid>/task/<number>
      Dir.open("/proc/#{pid}/task").each do |task|
        File.open(File.join(@path, 'tasks'), "w") do |f|
          f.puts(pid)
        end
      end
    end

    def children
      out = []
      Dir.open(@path).each do |file|
        next if file == '.' or file == '..'
        path = File.join(@path, file)
        if File.readable? File.join(path, 'tasks')
          out << path
        end
      end
      out
    end

    #
    # The majority of the useful bits of cgroups (and proc/sys for that matter) use simple single values
    # except for where the kernel devs felt like trolling poor tools people like me.
    # This method_missing tries to cover most of the common stuff and must be overridden for things that
    # need more parsing.
    #
    def method_missing(method, *args)
      name = method.to_s.sub(/=/, '')
      path = File.join(@path, name)

      # cgroup filenames with dots in them get translated into snake case, e.g.
      # blkio.weight -> cg.blkio_weight = 100
      snakename = name.gsub("_", ".")
      snake = File.join(@path, snakename)
      if File.exists?(snake) and not File.exists?(path)
        path = snake
      end

      if File.directory? path
        return Cgroup.new name, path
      end

      unless File.exists? path
        raise "No such method: #{method}. Tried to access '#{path}'"
      end
      
      if method.to_s.end_with?('=')
        raise "#{path} is not writable" unless File.writable? path
        File.open(path, "w") do |fd|
          args.each do |a| fd.puts a end
        end
      end

      raise "#{path} is not readable" unless File.readable? path
      value = File.read(path).chomp

      # single-entry file with a single number
      if value =~ /\A\d+\Z/
        value.to_i
      # multi-line files
      elsif value =~ /\n/
        items = value.split(/\n+/)

        # key = value or key[key] = value files
        # e.g. blkio.time = { '8:11' => 1234 }
        # e.g. blkio.throttle.io_serviced = { '8:0' => { 'Read' => 1234 } }
        if items.any? { |i| i =~ /\s+/ }
          out = {}
          items.each do |line|
            parts = line.chomp.split(/\s+/)
            if parts.count == 2
              out[parts[0]] = parts[1]
            elsif parts.count == 3
              out[parts[0]][parts[1]] = parts[2]
            else
              raise "list is too big and unsupported"
            end
          end
          out
        # it's just a flat list of values, try to convert numbers to fixnum and return
        else
          items.map { |i| i.=~(/\A\d+\Z/) ? i.to_i : i }
        end
      # return the data unmolested
      else
        value
      end
    end
  end
end

# vim: et ts=2 sw=2 ai smarttab
