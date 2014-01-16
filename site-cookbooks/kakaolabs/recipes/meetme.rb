# install meetme plugin
directory "/var/log/newrelic" do
  owner "newrelic"
  group "newrelic"
end

python_pip "newrelic-plugin-agent" do
  action :install
end

node.meetme.plugins.each do |plugin_name|
  python_pip "newrelic_plugin_agent[#{plugin_name}]" do
    action :upgrade
  end
end

uwsgi_ports = (0..(node.app.web.processes - 1)).to_a.map do |x|
  9900 + x
end

template "/etc/newrelic/newrelic_plugin_agent.cfg" do
  source "meetme/newrelic_plugin_agent.cfg.erb"
  variables :uwsgi_ports => uwsgi_ports
end

template "/etc/init.d/newrelic_plugin_agent" do
  source "meetme/newrelic_plugin_agent.erb"
  mode 0755
end

service "newrelic_plugin_agent" do
  action [:enable, :restart]
end
