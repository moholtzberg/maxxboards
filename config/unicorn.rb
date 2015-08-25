env = ENV["RAILS_ENV"] || "development"

worker_processes 4

listen "/tmp/maxxboards.socket", backlog: 64

preload_app true

timeout 30

pid "/tmp/unicorn.maxxboards.pid"

if env == "production"
  working_directory "/home/spree/maxxboards/current"
  shared_path = "/home/spree/maxxboards/shared"
  stderr_path "#{shared_path}/log/unicorn.stderr.log"
  stdout_path "#{shared_path}/log/unicorn.stdout.log"
end

before_fork do |server, worker|
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.connection.disconnect!
  end

  old_pid = "/tmp/unicorn.maxxboards.pid.oldbin"
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
    end
  end
end

after_fork do |server, worker|
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.establish_connection
  end
end
