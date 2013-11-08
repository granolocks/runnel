require 'rubygems'
require 'yaml'
require File.expand_path('../runnel/auto_ssh.rb', __FILE__)
require File.expand_path('../runnel/version.rb', __FILE__)

module Runnel
  RUNNEL_DIR    = ENV['HOME']+"/.runnel"
  PIDS_DIR      = "#{RUNNEL_DIR}/pids"
  PIDS_FILES    = "#{PIDS_DIR}/*"
  TUNNEL_CONFIG = "#{RUNNEL_DIR}/tunnels.yml"

  def self.config
    YAML.load_file(TUNNEL_CONFIG)
  end

  def self.setup
    puts "mkdir -p #{RUNNEL_DIR} #{PIDS_DIR}"
    `mkdir -p #{RUNNEL_DIR} #{PIDS_DIR}`
    unless File.exists?(TUNNEL_CONFIG)
      puts "Populating an example config"
      File.open(TUNNEL_CONFIG, 'w').puts(TCONF_EXAMPLE)
    end
    puts "Now just update #{TUNNEL_CONFIG}"
  end

  def self.all
    list = []
    config.each_pair do |k,v|
      list << AutoSsh.new(k, v)
    end
    list
  end

  def self.kill(tid)
    create_from_tunnel_id(tid).kill
  end

  def self.start(tid)
    tunnel = create_from_tunnel_id(tid)
    tunnel.start
  end

  def self.start_all
    self.all.each do |t|
      t.start unless t.running?
    end
  end

  def self.kill_all
    self.all.each do |t|
      t.kill if t.running?
    end
  end

  def self.create_from_tunnel_id(tid)
    AutoSsh.new(tid, config[tid.to_sym])
  end
end
