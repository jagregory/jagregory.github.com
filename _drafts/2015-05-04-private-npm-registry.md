---
layout: post
title: 'Sinopia: a private NPM registry'
---

Not all of our packages can be pushed to the public NPM repository. Proprietary code and uninteresting code we want to keep internal, but until recently the package distribution story for this code has been worse than open-sourcing it. You either modularise it and publish to the world, or you have a bad time.

<!-- more -->

> Or you modularise and share via git dependencies, which isn't a great solution. You lose versioning, all the pre-publish hook loveliness, and become quite limited by where our package is being used (no preprocessors for you!).

In the early days NPM wasn't designed with multiple registries in mind, so hosting your own internal one meant either proxying/mirroring the public registry or manually adding public packages to your private registry and using it for everything. Thanks to improvements in NPM and several open-source efforts, it's now much easier than that to host your own internal NPM registry.

NPM have recently [started offering private modules](https://www.npmjs.com/private-modules), which looks very interesting. There's also a pay-for [Enterprise option](http://npmjs.com/enterprise#pricing) from NPM which is worth thinking about once you scale.

If private cloud hosting isn't your thing, the host-your-own options are worth exploring. [Sinopia](https://www.npmjs.com/package/sinopia) is what we'll setup.

## What is Sinopia?

Sinopia is a simple NPM registry, which has zero dependencies (that means no CouchDB for those who've done this before); it has support for most day-to-day NPM features, such as [scopes](https://docs.npmjs.com/misc/scope), [command line publishing](https://docs.npmjs.com/cli/publish), and [authentication](https://docs.npmjs.com/cli/adduser). Sinopia is a good candidate for a low-to-medium utilised NPM registry, such as company private registries.

## Running Sinopia on your machine

If you just want to run Sinopia locally and aren't interested in how it works, you can:

    git clone https://github.com/jagregory/sinopia-ansible.git
    cd sinopia-ansible
    ansible-galaxy install -r requirements.txt
    vagrant up

Once this completes Sinopia will be available on port `4873`.

## Vagrant setup

Vagrant uses a Vagrantfile to define how your Virtual Machine (or machines) will be configured. You can run `vagrant init` to create a Vagrantfile. Once you have that file, we'll make some changes inside the config block.

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
config.vm.network "forwarded_port", guest: 4873, host: 4873
```

{% text %}

When Sinopia starts it will listen on port `4873` in the guest machine, but we need to forward that port to a port on our host. For convinience, we'll just use the same port on both.

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

## Ansible playbook

Our Vagrantfile delegates machine setup to Ansible, which is driven by a [Playbook](http://docs.ansible.com/playbooks.html). Our playbook is pretty simple, but it's worth having a look.

{% sidebyside %}
	.
	├── Vagrantfile
	├── hosts
	├── requirements.txt
	└── site.yml
{% text %}
Here's the directory structure we have for Ansible. There's very little to it.
{% endsidebyside %}

{% sidebyside %}
	---
	- name: Install Sinopia
	  hosts: all
	  sudo: True
	  roles:
	    - nodesource.node
	    - jagregory.sinopia
{% text %}
**site.yml**: For our Vagrantfile to run we need a site.yml Ansible playbook, which tells Ansible which roles our host is supposed to have.

In our site.yml we give the playbook a name, specify that it should run on all of our hosts (we only have one), that our commands should be run as sudo, and then we specify which roles our machine should have.
{% endsidebyside %}

**requirements.txt**: Ansible has a dependency management system/tool called [Ansible Galaxy](https://galaxy.ansible.com/) which is growing in popularity for sharing roles. We'll use Ansible Galaxy to download the roles we use for this machine, rather than copying them into our repository.

{% sidebyside %}
	nodesource.node
	jagregory.sinopia
{% text %}
Ansible Galaxy uses a requirements.txt to list which dependencies to install. We just have two, a NodeJS role and our Sinopia role.
{% endsidebyside %}

To install these dependencies you can run: `ansible-galaxy install -r requirements.txt`

{% sidebyside %}
	npm.jagregory.com
{% text %}
**hosts**: The last thing of interest is the Ansible inventory file, which declares the machines we're letting Ansible manage. In our case it's just one host in our inventory.
{% endsidebyside %}

## Sinopia in the Cloud

If you want to run a Sinopia instance in the cloud it's as easy as launching an instance in EC2 (or your preferred provider), adding it's public IP address to the inventory file and running Ansible.

	ansible-playbook site.yml -i hosts

This will run Ansible against all the hosts in our inventory (hosts file) and execute the site.yml playbook.

You can read more about running Sinopia [on their website](https://www.npmjs.com/package/sinopia).
