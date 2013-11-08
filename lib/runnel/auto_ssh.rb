module Runnel
  class AutoSsh
    attr_reader :id, :config
    alias_method :conf, :config

    def initialize(id, config)
      @id = id
      @config = config
    end

    def pp_description
      txt = "#{id} - #{conf[:name]}"
      txt += " (Running: #{pid})" if running?
      running? ? green(txt) : red(txt)
    end

    def running?
      if File.exists?(pid_file)
        if `ps #{pid} | grep autossh`.length == 0
          File.delete(pid_file)
          false
        else
          true
        end
      end
    end

    def start
      puts "Starting #{conf[:name]}"
      puts "AUTOSSH_PIDFILE=#{pid_file} autossh -M #{conf[:mport]} #{conf[:command]}"
      ENV['AUTOSSH_PIDFILE'] = pid_file
      `autossh -M #{conf[:mport]} #{conf[:command]}`
    end

    def kill
      if running?
        `kill #{pid}`
      else
        puts "Unable to find a running #{conf[:name]}"
      end
    end

    private

    def pid_file
      "#{PIDS_DIR}/#{id}"
    end

    def pid
      File.read(pid_file).chomp
    end

    def red(txt)
      "\033[31m#{txt}\033[0m"
    end

    def green(txt)
      "\033[32m#{txt}\033[0m"
    end
  end
end
