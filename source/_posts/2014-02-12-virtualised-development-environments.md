---
layout: post
title: My ever evolving development virutalisation situation
date: 2014-02-12 23:15
comments: true
type: post
published: true
---

Over the past few years I've moved closer and closer to virtualising my entire development environment. It started with developing for Windows whilst using a Mac, continued when I refused to sully my machine with some godforsaken Oracle product, and has now reached completion with the arrival of a new laptop and an unwillingness to install RVM again.

<!-- more -->

The first attempt used [Vagrant](http://www.vagrantup.com/) to create a simple Virtual Machine which acted as a surrogate development environment. All my current project's development dependencies would be installed on the box, and I'd SSH into it to start servers or run tests etc...

```ruby
Vagrant.configure '2' do |config|
  config.vm.box = 'CentOS-6.4-x86_64-v20130731'
  config.vm.provision :chef_solo do |chef|
    chef.run_list = [
      'recipe[java]',
      'recipe[nodejs::install_from_package]',
      'recipe[postgresql]',
      'recipe[rvm::system]',
    ]
  end
end
```

It had its perks such as developing on an OS which would be used for the production servers and the obvious protecting my host machine from project specific software; nevertheless, doing everything on the VM itself quickly became painful. LiveReload? *No.* Customised Sublime Text? *Nope.* Photoshop? *No way.*

Vagrant's [`synched_folder`](http://docs.vagrantup.com/v2/synced-folders/basic_usage.html) feature allows you to share a directory from your host and expose it in the VMs file system, acting much like a regular symlink. By adding this I had my source code on my host system and could use my native editors all while still executing the code within the VM. The best of both worlds.
    
    config.vm.synced_folder "/Users/jagregory/dev/myclient", "/home/vagrant/workspace"


Another optimisation was using [`forward_agent`](http://docs.vagrantup.com/v2/vagrantfile/ssh_settings.html), which forwards the VM's SSH via your host ssh-agent. You can use your ssh keys from your host box within the VM without doing any `cp ~/.ssh` nastiness. This means I can push and pull with git whether I'm inside or outside my VM. It doesn't sound all that amazing until you've failed at running `git pull` for the tenth time from within your VM.

    config.ssh.forward_agent = true

Other than that, all this is really doing is spinning up a VM and installing all the dependencies. The up side is those dependencies are no longer on my host, so I can just bin the VM when I leave a client.

I liked the idea of working in a more ever-so-slightly more production like environment too. This stuck with me.

## It grows

What I didn't like about that setup was I still had my database installed right next to my app. That's nothing like how it would be running when deployed, so why should it be like that in development?

And so my Vagrantfile grew.

```ruby
Vagrant.configure '2' do |config|
  config.vm.box = 'CentOS-6.4-x86_64-v20130731'
  config.ssh.forward_agent = true
  config.vm.synced_folder "/Users/jagregory/dev/myclient", "/home/vagrant/workspace"

  config.vm.define 'app' do |vm|
    vm.provision :chef_solo do |chef|
      chef.run_list = [
        'recipe[java]',
        'recipe[nodejs::install_from_package]',
        'recipe[rvm::system]',
      ]
    end
  end

  config.vm.define 'db' do |vm|
    vm.provision :chef_solo do |chef|
      chef.run_list = [
        'recipe[postgresql]',
      ]
    end
  end
end
```

And then there were two. I had a VM for my app and a VM for the database. My development environment had acquired some of the qualities of "real" environments through the forced separation of app and database. This had the added benefit of pushing some considerations of service resolution and dealing with different environments into development space-and-time.

And then it grew again.

```ruby
config.vm.define 'smtp-stub' do |vm|
  vm.provision :chef_solo do |chef|
    chef.run_list = [
      'recipe[java]',
    ]
  end
end
```

And again.

```ruby
config.vm.define 'admin-app' do |vm|
  vm.provision :chef_solo do |chef|
    chef.run_list = [
      'recipe[nodejs::install_from_package]',
    ]
  end
end
```

And again.

```ruby
config.vm.define 'reverse-proxy' do |vm|
  vm.provision :chef_solo do |chef|
    chef.run_list = [
      'recipe[nginx]',
    ]
  end
end
```

My virtualised development environment was now complete. The Vagrantfile resembles a production-like environment--warts and all--whilst maintaining the ability to develop on it. Separate VMs for each application, configured only with the languages and tools needed for that particular application. Services were localised which had only existed as shared resources, and others split out when they'd been lumped in with the main application for convenience. Other hidden bits of infrastructure started making their way into VMs too, such as the mysterious `reverse-proxy` box which had never made an appearance in development until now. The Chef cookbooks which were creating these development VMs were also now being used to provision our other "real" environments, and vice-versa.

This is by no means a simple setup, it has a lot of moving parts, and its more complex to maintain; but guess what? That's because the app has a lot of moving parts and is quite complex!

It's nice to not live in isolated developer-la-la-land for a change. I thoroughly encourage you to experiment with this setup, especially if you're developing on a OSX or Windows machine. As a developer setup it's closer to a realistic deployment environment than I've had before. I can encounter and fix infrastructure related issues way before changes hit an end-to-end build, and it forces you to understand how your application will be deployed and run. Dev meet Ops, Ops meet Dev.

It's also quite cathartic to delete a VM when I'm done with a project. Not seeing the Java Updater pop-up ever again isn't too bad either.
