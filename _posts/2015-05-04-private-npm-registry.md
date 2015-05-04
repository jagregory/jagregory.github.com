---
layout: post
title: 'Sinopia: a private NPM registry in Vagrant'
---

Not all of our packages can be pushed to the public NPM repository. Proprietary code and uninteresting code we want to keep internal, but until recently the package distribution story for this code has been worse than open-sourcing it. You either modularise it and publish to the world, or you have a bad time.

<!-- more -->

> Or you modularise and share via git dependencies, which isn't a great solution. You lose versioning, all the pre-publish hook loveliness, and become quite limited by where our package is being used (no preprocessors for you!).

In the early days NPM wasn't designed with multiple registries in mind, so hosting your own internal one meant either proxying/mirroring the public registry or manually adding public packages to your private registry and using it for everything. Thanks to improvements in NPM and several open-source efforts, it's now much easier than that to host your own internal NPM registry.

NPM have recently [started offering private modules](https://www.npmjs.com/private-modules), which looks very interesting. There's also a pay-for [Enterprise option](http://npmjs.com/enterprise#pricing) from NPM which is worth thinking about once you scale.

If private cloud hosting isn't your thing, the host-your-own options are worth exploring. [Sinopia](https://www.npmjs.com/package/sinopia) is what we'll setup.

## Running Sinopia in Vagrant

To get a Sinopia Virtual Machine running locally there's a few tools you need to have installed. Install [Vagrant](https://www.vagrantup.com) and [VirtualBox](https://www.virtualbox.org), and we'll later be using [Ansible](http://www.ansible.com/) to configure our machine so you should get that installed too.

Vagrant uses a Vagrantfile to define how your Virtual Machine (or machines) will be configured. You can run `vagrant init` to create a Vagrantfile. Once you have that file, we'll make some changes inside the config block.

To follow along, you can [download the complete Vagrantfile](/downloads/sinopia/Vagrantfile).

{% sidebyside %}
```ruby
config.vm.box = "ubuntu-14.04-amd64-vbox"
config.vm.box_url = "https://oss-binaries.phusionpassenger.com/vagrant/boxes/latest/ubuntu-14.04-amd64-vbox.box"
```

{% text %}

The Ubuntu boxes provided by the Phusion team are a good set of boxes to start from. We're using their 14.04 TLS box.

{% endsidebyside %}

{% sidebyside %}
```ruby
config.vm.network "forwarded_port", guest: 80, host: 4873
```

{% text %}

When Sinopia starts it will listen on port `4873` in the guest machine, but we need to forward that port to a port on our host. For convinience, we'll just use the same port on both.

{% endsidebyside %}

{% sidebyside %}
```ruby
config.vm.synced_folder "sinopia_data/", "/var/sinopia", mount_options: %W{dmode=777 fmode=666}
```

{% text %}

We also want to sync the Sinopia data directory (`/var/sinopia`) to our host, so we can destroy the Virtual Machine without losing all of our registry content.

{% endsidebyside %}

{% sidebyside %}
```ruby
config.vm.provision "ansible" do |ansible|
  ansible.playbook = "site.yml"
end
```

{% text %}

Finally, Vagrant will run Ansible on the Virtual Machine. Ansible will download and configure Sinopia using the [sinopia-ansible](https://github.com/jagregory/sinopia-ansible) role.

{% endsidebyside %}

Once you've saved the changes to your Vagrant file, you can run: `vagrant up`

You'll see the Ansible output fly by and eventually it will complete. At this point you can point your browser at [http://localhost:4873](http://localhost:4873) to be greeted by Sinopia.
