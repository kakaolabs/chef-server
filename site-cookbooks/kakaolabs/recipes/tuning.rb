# Tunning linux machine

# create .ssh folder
directory "/root/.ssh" do
  action :create
end

# copy file
file_paths = [
  "etc/sysctl.conf",
  "etc/security/limits.conf",
  "etc/pam.d/common-session",
  "root/.ssh/id_rsa",
  "root/.ssh/id_rsa.pub",
  "root/.ssh/known_hosts"
]

file_paths.each do |file_path|
  cookbook_file "/#{file_path}" do
    source file_path
  end
end

# reload sysclt
bash "reload sysctl" do
  code <<-EOH
  sysctl -p
  EOH
end

# set file permisson
file "/root/.ssh/id_rsa" do
  mode 0600
end
