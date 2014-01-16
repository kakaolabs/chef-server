include_recipe "rabbitmq"
include_recipe "rabbitmq::virtualhost_management"
include_recipe "rabbitmq::user_management"
include_recipe "rabbitmq::plugin_management"

template "/etc/rabbitmq/rabbitmq.config" do
  source "rabbitmq/rabbitmq.conf.erb"
  notifies :restart, "service[rabbitmq-server]"
end
