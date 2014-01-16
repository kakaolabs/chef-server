if node.platform == "debian"
  bash "set node name" do
    user "root"

    code <<-EOH
    echo "#{node.app.hostname}" > /etc/hostname
    echo "127.0.0.1 #{node.app.hostname}" > /etc/hosts
    /etc/init.d/hostname.sh start
    EOH
  end

  %w(git vim).each do |package_name|
    apt_package package_name do
      action :install
    end
  end

  git "/opt/dotfile" do
    repository "git://github.com/kiennt/dotfile.git"
    reference "master"
    action :sync

    not_if { File.exist?('/otp/dotfile') }
  end

  bash "install dotfile" do
    user "root"

    code <<-EOH
    cd /opt/dotfile
    ./install.sh
    EOH

    not_if { File.exist?('/otp/dotfile') }
  end

end
