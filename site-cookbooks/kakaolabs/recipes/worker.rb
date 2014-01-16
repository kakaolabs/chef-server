app_name = node[:app][:name]
app_dir = "/srv/#{app_name}/current"

# create superviord worker services
command = "#{app_dir}/venv/bin/newrelic-admin run-program #{app_dir}/venv/bin/python #{app_dir}/StoryTree/manage.py celeryd -E -B --loglevel=INFO --schedule=/srv/#{app_name}/shared/celeryd/celerybeat-schedule.db"
action = if File.exist?('/etc/supervisor.d/worker.conf') then [ :disable, :enable ] else [ :enable ] end

supervisor_service "worker" do
  directory app_dir
  command command
  user node.app.user
  stdout_logfile "/tmp/#{app_name}/logs/worker.stdout.log"
  stderr_logfile "/tmp/#{app_name}//logs/worker.stderr.log"
  startsecs 10
  stopsignal "TERM"
  stopwaitsecs 600
  stopasgroup true
  killasgroup true
  process_name '%(program_name)s_%(process_num)02d'
  environment node[:app][:environment]
  numprocs node[:app][:worker][:processes]
  action action
end

execute "start/restart worker service" do
  command "supervisorctl reread worker; supervisorctl update worker"
end
