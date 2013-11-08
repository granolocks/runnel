require 'rubygems'
require 'yaml'
require File.expand_path('../runnel/auto_ssh.rb', __FILE__)
require File.expand_path('../runnel/version.rb', __FILE__)

module Runnel
  RUNNEL_DIR    = ENV['HOME']+"/.runnel"
  PIDS_DIR      = "#{RUNNEL_DIR}/pids"
  PIDS_FILES    = "#{PIDS_DIR}/*"
  TUNNEL_CONFIG = "#{RUNNEL_DIR}/tunnels.yml"
  TCONF_EXAMPLE = <<YAML
---
:socks_proxy:
  :name: My socks proxy for secure browsing on public WiFi
  :mport: 44488 #The autossh monitor port
  :command: -NfD 8080 mysecurebox.net
:mysql_proxy:
  :name: mySQL proxy for work
  :mport: 44490
  :command: -NfL 3306:localhost:3306 mysqlbox.org
YAML

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
    config.each_pair do |tunnel_id,config|
      list << AutoSsh.new(tunnel_id, config)
    end
    list
  end

  def self.kill(tunnel_id)
    create_from_tunnel_id(tunnel_id).kill
  end

  def self.start(tunnel_id)
    tunnel = create_from_tunnel_id(tunnel_id)
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

  def self.create_from_tunnel_id(tunnel_id)
    AutoSsh.new(tunnel_id, config[tunnel_id.to_sym])
  end
end
