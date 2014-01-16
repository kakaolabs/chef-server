include_recipe "redis::install_from_release"

# create redis user
group "redis" do
  system true
  action :create
end

user "redis" do
  system true
  group "redis"
  action :create
end

# create directory for redis
directories = [ node.redis.data_dir, node.redis.log_dir, node.redis.conf_dir ]
directories.each do |directory_path|
  directory directory_path do
    user "redis"
    group "redis"
    recursive true
    action :create
  end
end

# set up redis config file
template "#{node[:redis][:conf_dir]}/redis.conf" do
  source        "redis/redis.conf.erb"
  mode          "0644"
  variables     :redis => node[:redis], :redis_server => node[:redis][:server]
end


# set up redis for upstart
template "/etc/init.d/redis" do
  source        "redis/redis.init.erb"
  mode          "0755"
  variables     :redis => node[:redis]
end


service "redis" do
  supports :status => true, :restart => true
  action [ :enable, :restart ]
end
