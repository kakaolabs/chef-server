include_recipe "nginx::source"

service "nginx" do
  action :nothing
end

template "nginx_status" do
  path "#{node['nginx']['dir']}/sites-available/nginx_status"
  source "nginx/nginx_status.erb"
  owner "root"
  group "root"
  mode 00644
  notifies :reload, "service[nginx]"
end

nginx_site "nginx_status"
