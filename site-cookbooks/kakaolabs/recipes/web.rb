app_name = node.app.name
app_dir = "/srv/#{app_name}/current"

# set up nginx
service "nginx" do
  action :nothing
end

if node.app.web.socket then
  hosts = (0..(node.app.web.processes - 1)).to_a.map do |x|
    port = 9000 + x
    "unix:///srv/#{app_name}/shared/socket/#{app_name}_#{port}.sock"
  end
  socket_option = "--socket /srv/#{app_name}/shared/socket/#{app_name}_90%(process_num)02d.sock --chmod-socket=666"
else
  hosts = (0..(node.app.web.processes - 1)).to_a.map do |x|
    port = 9000 + x
    "127.0.0.1:#{port}"
  end
  socket_option = "--socket :90%(process_num)02d"
end

bash "create folders" do
  code <<-EOH
  touch /srv/simpleprints/shared/deploy/version
  EOH
end

command = "#{app_dir}/venv/bin/newrelic-admin run-program #{app_dir}/venv/bin/uwsgi --ini #{app_dir}/uwsgi.ini --threads #{node.app.web.threads} --disable-logging --listen 4000 #{socket_option} --stats :99%(process_num)02d --touch-reload /srv/simpleprints/shared/version"

template "#{node.nginx.dir}/sites-available/#{app_name}" do
  source "nginx/#{app_name}.erb"
  owner "root"
  group "root"
  variables :hosts => hosts
end

nginx_site app_name do
  enable true
end


# create superviord web services
action = if File.exist?('/etc/supervisor.d/web.conf') then [ :disable, :enable ] else [ :enable ] end

supervisor_service "web" do
  directory app_dir
  command command
  user node.app.user
  stdout_logfile "/srv/#{app_name}/shared/logs/web.stdout.log"
  stderr_logfile "/srv/#{app_name}/shared/logs/web.stderr.log"
  startsecs 10
  stopsignal "QUIT"
  stopasgroup true
  killasgroup true
  process_name '%(program_name)s_%(process_num)02d'
  environment node.app.environment
  numprocs node.app.web.processes
  action action

  notifies :restart, "service[nginx]"
end

execute "start/restart web service" do
  command "supervisorctl reread web; supervisorctl update web"
end
