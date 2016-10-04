require_relative './client'

worker_processes Integer(ENV['WEB_CONCURRENCY'] || 3)
timeout 150
preload_app true

before_fork do |_server, _worker|
  Signal.trap 'TERM' do
    puts 'Unicorn master intercepting TERM and sending myself QUIT instead'
    Process.kill 'QUIT', Process.pid
  end

  Client.disconnect
end

after_fork do |_server, _worker|
  Signal.trap 'TERM' do
    puts 'Unicorn worker intercepting TERM and doing nothing. ' \
         'Wait for master to send QUIT'
  end
  Client.establish_connection
end
