bash "create log folder" do
  code <<-EOH
  mkdir -p /tmp/var/log/nginx
  EOH
end

cron "remove temporary files" do
  minute "0"
  command "find /tmp -type f -maxdepth 1 -mmin +120 | xargs rm -rf && echo `date` >> /cron.job"
end

cron "move nginx logs to tmp folder" do
  hour "0"
  command "mv /var/log/nginx/access.post.log /tmp/var/log/nginx/access.post.log.`date +'%s'` && mv /var/log/nginx/error.log /tmp/var/log/nginx/error.log.`date +'%s'` && kill -USR1 `cat /var/run/nginx.pid`"
end
