module Containment
  module Util
    # simple wrapper to clean up reading proc/cgroup/sysfs files
    def slurp(filepath)
      File.open(filepath, "r") do |f|
        val = f.gets.chomp
        yield val
      end
    end

    # slurp with conversion to integers
    def slurp_int(filepath)
      File.open(filepath, "r") do |f|
        val = f.gets.chomp
        yield val.to_i
      end
    end

    # it's one line in shell, so make it one line here too
    def echo(line, filepath)
      File.open(filepath, "w") do |f|
        f.puts line
      end
    end
  end
end
# vim: et ts=2 sw=2 ai smarttab ft=ruby
