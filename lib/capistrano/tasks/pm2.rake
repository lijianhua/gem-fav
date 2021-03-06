# encoding: utf-8

require 'json'

namespace :pm2 do

  def app_status
    within fetch(:dist_path) do
      ps = JSON.parse(capture :pm2, :jlist, fetch(:app_command))
      if ps.empty?
        return nil
      else
        # status: online, errored, stopped
        return ps[0]["pm2_env"]["status"]
      end
    end
  end

  def restart_app
    within fetch(:dist_path) do
      execute 'NODE_ENV=production', :pm2, :restart, fetch(:app_command)
    end
  end

  def start_app
    within fetch(:dist_path) do
      execute 'NODE_ENV=production', :pm2, :start, fetch(:app_command)
    end
  end

  desc 'Restart app gracefully'
  task :restart do
    on roles(:app) do
      execute :pm2, :delete, fetch(:application)
      case app_status
      when nil
        info 'App is not registerd'
        start_app
      when 'stopped'
        info 'App is stopped'
        restart_app
      when 'errored'
        info 'App has errored'
        restart_app
      when 'online'
        info 'App is online'
        restart_app
      end
    end
  end

end
