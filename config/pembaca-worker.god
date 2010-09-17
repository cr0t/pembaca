rails_env   = ENV['RAILS_ENV']  || "production"
rails_root  = ENV['RAILS_ROOT'] || "/var/www/com.summercode.pembaca/current"
rake_cmd    = "/opt/ruby-enterprise-1.8.7-2010.02/bin/rake"
home_env    = "/home/cr0t"
queues_env  = "convert,clean"
num_workers = rails_env == 'production' ? 2 : 2

num_workers.times do |num|
  God.watch do |w|
    w.name     = "resque-#{num}"
    w.group    = "resque"
    w.interval = 30.seconds
    w.start    = "cd #{rails_root} && /usr/bin/env HOME=#{home_env} QUEUE=#{queues_env} RAILS_ENV=#{rails_env} #{rake_cmd} -f #{rails_root}/Rakefile environment resque:work"

    w.uid = "cr0t"
    w.gid = "cr0t"

    # retart if memory gets too high
    w.transition(:up, :restart) do |on|
      on.condition(:memory_usage) do |c|
        c.above = 150.megabytes
        c.times = 2
      end
    end

    # determine the state on startup
    w.transition(:init, { true => :up, false => :start }) do |on|
      on.condition(:process_running) do |c|
        c.running = true
      end
    end

    # determine when process has finished starting
    w.transition([:start, :restart], :up) do |on|
      on.condition(:process_running) do |c|
        c.running = true
        c.interval = 5.seconds
      end

      # failsafe
      on.condition(:tries) do |c|
        c.times = 5
        c.transition = :start
        c.interval = 5.seconds
      end
    end

    # start if process is not running
    w.transition(:up, :start) do |on|
      on.condition(:process_running) do |c|
        c.running = false
      end
    end
  end
end