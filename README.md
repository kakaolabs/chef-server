# This repository is for setup server

NOTE: in this document, we use some notation
+ `$>` if a command line start with `$>`, it means this command was
run in local machine
+ `(vagrant)>` it means command was run in vagrant machine


## 1. Install development environment (in OSX)

We use [chef](http://www.opscode.com/chef/) to write boostrap script.

Chef is great tool to write script for configruation management

+ Install ruby. We should using RVM to install ruby
Please checkout [rvm website](https://rvm.io) for more information
ruby is needed to run `chef`

```
curl -L https://get.rvm.io | bash -s stable
```

+ Install [VirtualBox](https://www.virtualbox.org/)
Please look at this page https://www.virtualbox.org/wiki/Downloads


+ Install [vagrant](http://www.vagrantup.com/) - vagrant was used to create and
configure lightweight, reproducible, and portable development environments.

Vagrant can be installed via `gem` (`pip`-liked tool for `ruby`).
But vagrant gem is not updated, to get lastest vagrant, we need to download it
from the vagrant site http://downloads.vagrantup.com/

+ After install `vagrant`, we need to add base box to our local machine.
We used `debian`

```
$> vagrant box add debian7_64 https://dl.dropboxusercontent.com/u/86066173/debian-wheezy.box
```

## 2. Prepare machine to run chef

+ Run the machine
In current folder (folder of `boostrap-server` repository), turn up the virtual machine

```
$> vagrant up
```

This command load `Vagrantfile` in current folder and read configruation
variable to start our new machine based on `debian7_64` machine

New machine will have 2 cores and 1GB RAM memory with IP is `192.22.88.101`

+ Set up root account in vagrant machine

NOTE: in this document, we use some notation
    * `$>` if a command line start with `$>`, it means this command was
run in local machine
    * `(vagrant)>` it means command was run in vagrant machine


```
# ssh to vagrant machine
# alternate way is use `vagrant ssh` but I found use ssh is faster
$> ssh vagrant@192.22.88.101 -i ~/.vagrant.d/insecure_private_key

# in vagrant machine, go to root user
(vagrant)> sudo su
# copy .ssh folder of vagrant user to root user so we can ssh directly to root
(vagrant)> cp -r /home/vagrant/.ssh /root
# finish set up in vagrant machine
(vagrant)> exit

```

## 3. Using chef and knife to set up machine

+ Set up `chef` and `knife` in our machine

```
# install all neccessary gems
$> bundle install

# prepare vagrant machine with knife solo tool
# this command can use with EC2 machine too, just change root@192.22.88.101
# with EC2 user and IP
$> knife solo prepare root@192.22.88.101 -i ~/.vagrant.d/insecure_private_key
```

+ Finally, set up vagrant machine

```
# this command install every packages and software need to run our simpleprints
# app. This will took a long time, you should server yourself cup of coffee :P
$> knife solo cook root@192.22.88.101 -i ~/.vagrant.d/insecure_private_key -V
```

## 4. Flow to use `vagrant` and `knife` to set up machine

+ Install `vagrant-vbox-snapshot` for saving vagrant snapshot

```
$> vagrant plugin vagrant-vbox-snapshot
```

This plugin allow us to create a snapshot of vagrant machine before we run our
`knife` command. If `knife` command failed, we could rollback vagrant machine
to state before it, fix the scripts in `site-cookbooks` folder and `knife`
again.

This flow can do until we get the correct configuration

