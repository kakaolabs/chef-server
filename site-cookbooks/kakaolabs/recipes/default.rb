include_recipe "python"
include_recipe "supervisor"

# install essential packages
essential_packages = [
  "sysstat",
  "htop",
  "libmysqlclient-dev",
  "libmemcached-dev",
  "libevent-dev",
  "libjpeg-dev",
  "libfreetype6-dev",
  "python-imaging",
  "zlib1g-dev",
  "libjpeg8-dev",
  "ghostscript"]

essential_packages.each do |name|
  apt_package name do
    action :install
  end
end

# fix bug for PIL
bash "fix bug for PIL library" do
  code <<-EOH
  ln -s /usr/lib/x86_64-linux-gnu/libz.so /usr/lib/libz.so
  ln -s /usr/lib/x86_64-linux-gnu/libjpeg.so /usr/lib/libjpeg.so
  ln -s /usr/lib/x86_64-linux-gnu/libfreetype.so /usr/lib/libfreetype.so
  EOH

  not_if { File.exist?('/usr/lib/libz.so') }
end

# create user
begin
  user node.app.user do
    system true
    action :create
  end
rescue
end

# create pip cached
bash "create pip cached" do
  code <<-EOH
  mkdir -p /tmp/pip/cached
  echo "export PIP_DOWNLOAD_CACHE=/tmp/pip/cached" >> /root/.bashrc
  EOH
end


# create application folder
app_name = node.app.name
app_dir = "/srv/#{app_name}"

# create folders
bash "create folders" do
  code <<-EOH
  mkdir -p #{app_dir}
  mkdir -p #{app_dir}/shared
  mkdir -p #{app_dir}/releases
  mkdir -p #{app_dir}/base
  cd #{app_dir}/base && git init --bare

  export COMMIT=`git ls-remote #{node.app.repo_url} master | awk '{print $1}'`
  mkdir -p #{app_dir}/releases/$COMMIT
  git clone #{node.app.repo_url} #{app_dir}/releases/$COMMIT

  rm -rf /srv/simpleprints/current
  ln -s #{app_dir}/releases/$COMMIT /srv/simpleprints/current

  chown -R #{node.app.user} #{app_dir}
  EOH
end

directories = [ "logs", "socket", "celeryd", "deploy" ]
directories.each do |directory_name|
  directory "#{app_dir}/shared/#{directory_name}" do
    owner node.app.user
    action :create
  end
end

# create version file
file "#{app_dir}/version" do
  owner node.app.user
  action :create
end

# install virtual environment
python_virtualenv "#{app_dir}/current/venv" do
  owner node.app.user
  action :create
end

bash "install packages" do
  code <<-EOH
  . #{app_dir}/current/venv/bin/activate
  #{app_dir}/current/venv/bin/pip install -r #{app_dir}/current/requirements.txt
  EOH
end
