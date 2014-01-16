#!/usr/bin/env sh
export ROOT_REMOTE_MACHINE=root@192.22.88.101
export VAGRANT_REMOTE_MACHINE=vagrant@192.22.88.101

sync_chef() {
    ssh $ROOT_REMOTE_MACHINE -i ~/.vagrant.d/insecure_private_key "/usr/bin/chef-solo -c /vagrant/chef-solo/solo.rb -j /vagrant/chef-solo/nodes/vagrant.json"
}

ssh_login() {
    ssh $ROOT_REMOTE_MACHINE -i ~/.vagrant.d/insecure_private_key
}

init_vagrant() {
    scp -i ~/.vagrant.d/insecure_private_key keys/* $VAGRANT_REMOTE_MACHINE:~/.ssh/
}

fix_locale() {
    ssh $ROOT_REMOTE_MACHINE -i ~/.vagrant.d/insecure_private_key "echo en_US.UTF-8 UTF-8 > /etc/locale.gen;locale-gen"
}

case "$1" in
    ssh)
        ssh_login
        ;;
    chef)
        knife solo cook $ROOT_REMOTE_MACHINE -i ~/.vagrant.d/insecure_private_key -V
        ;;
    init)
        echo "Init private key for vagrant"
        init_vagrant
        ;;
    locale)
        fix_locale
        ;;
    *)
        echo "run {chef|ssh|init}"
        ;;
esac
