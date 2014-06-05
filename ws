#!/usr/bin/env ruby
require 'thor'

# Script to setup workspaces for different projects. I should eventually
# convert this to use Docker containers, but for now it will start and stop
# local services.
#
class Ws < Thor
  include Thor::Actions

  # Set the default destination_root
  def self.start(given_args = ARGV, config = {})
    config[:destination_root] = File.join(Dir.home, '.ws')
    super given_args, config
  end

  def self.source_root
    File.dirname(__FILE__)
  end

  # Ensure the destination source is craeted
  def initialize(*args)
    super(*args)
    unless File.exists?(destination_root)
      say "Creating workspace directory #{destination_root}", :red
      Dir.mkdir(destination_root)
    end
  end

  no_commands do
    def workspaces
      Dir.entries(destination_root)
        .map { |f| /(.*)\.sh$/.match(f) ? $1 : nil }
        .compact
    end

    def with_workspace(workspace, &block)
      workspace_file = File.join(destination_root, "#{workspace}.sh")

      if File.exists?(workspace_file)
        yield workspace_file
      else
        say "Workspace #{ws} doesn't exist", :red
        exit(1)
      end
    end
  end

  desc "list", "lists knows workspaces"
  def list
    workspaces.each { |ws| puts "  #{ws}" }
  end

  desc "create WORKSPACE", "create new WORKSPACE"
  def create(workspace)
    dest = "#{workspace}.sh"
    copy_file "workspace_template.sh", dest
    gsub_file dest, /_{workspace}_/, workspace, verbose: false
    chmod dest, "+x", verbose: false
    invoke :edit
  end

  desc "edit WORKSPACE", "edit existing WORKSPACE"
  def edit(ws)
    with_workspace(ws) do |workspace|
      run "#{ENV['EDITOR'] || 'vim'} #{workspace}", verbose: false
    end
  end

  desc "start WORKSPACE", "starts the WORKSPACE for project"
  def start(ws)
    with_workspace(ws) do |workspace|
      run "#{workspace} start", verbose: false
    end
  end

  desc "stop WORKSPACE", "stops the WORKSPACE for a project"
  def stop(ws)
    with_workspace(ws) do |workspace|
      run "#{workspace} stop", verbose: false
    end
  end

end


Ws.start
