namespace :resque do
  task :setup => :environment

  desc "Start a FIFO Resque worker"
  task "fifo-worker" => [ :preload, :setup ] do
    require 'resque'
    require 'resque/fifo/queue'

    prefix = ENV['PREFIX'] || 'fifo'
    worker = Resque::Plugins::Fifo::Worker.new
    worker.prepare
    worker.log "Starting worker #{self}"
    worker.work(ENV['INTERVAL'] || 5) # interval, will block
  end

  desc "Start multiple FIFO Resque workers. Should only be used in dev mode."
  task "fifo-workers" do
    threads = []

    if ENV['COUNT'].to_i < 1
      abort "set COUNT env var, e.g. $ COUNT=2 rake resque:workers"
    end

    ENV['COUNT'].to_i.times do
      threads << Thread.new do
        system "rake resque:fifo-worker"
      end
    end

    threads.each { |thread| thread.join }
  end
end
