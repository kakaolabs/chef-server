bash "install bundle" do
  code <<-EOH
  gem install bundle
  EOH

  not_if { File.exist?('/usr/bin/bundle') }
end

bash "install newrelic rpm" do
  code <<-EOH
  echo "deb http://apt.newrelic.com/debian/ newrelic non-free" >> /etc/apt/sources.list
  wget -O- https://download.newrelic.com/548C16BF.gpg | apt-key add -
  apt-get update
  apt-get install newrelic-sysmond
  nrsysmond-config --set license_key=#{node.app.environment.NEW_RELIC_LICENSE_KEY}
  EOH

  not_if { File.exist?("/etc/init.d/newrelic-sysmond") }
end

service "newrelic-sysmond" do
  action [:enable, :start]
end


# install newrelic plugin

# nginx plugin
bash "install newrelic_nginx_agent" do
  code <<-EOH
  cd /opt
  wget http://nginx.com/download/newrelic/newrelic_nginx_agent.tar.gz
  tar xvf newrelic_nginx_agent.tar.gz
  rm -rf newrelic_nginx_agent.tar.gz
  chown newrelic newrelic_nginx_agent
  cd /opt/newrelic_nginx_agent
  bundle install
  EOH
end

template "/opt/newrelic_nginx_agent/config/newrelic_plugin.yml" do
  source "newrelic/newrelic_nginx_plugin.yml.erb"
end

template "/etc/init.d/newrelic_nginx_agent" do
  source "newrelic/newrelic_nginx_agent.erb"
  mode 0755
end

service "newrelic_nginx_agent" do
  action [:enable, :start]
end
