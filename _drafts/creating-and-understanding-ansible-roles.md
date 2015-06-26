---
layout: post
title: 'Exploring an Ansible role'
---

> I recently put together an [Ansible role](https://docs.ansible.com/playbooks_roles.html) for the [Sinopia private NPM registry](https://github.com/rlidwka/sinopia). You can find it on Ansible Galaxy [over here](https://galaxy.ansible.com/list#/roles/3603) and the source is available on Github: [jagregory/sinopia-ansible](https://github.com/jagregory/sinopia-ansible). I figured this would be a good opportunity, whilst it's still fresh in my mind, to write a basic overview of creating an Ansible role from scratch.

<!-- more -->

There are a few high-level concepts in Ansible which are useful to define as you'll hear them a lot.

  * **Playbooks** are a list of roles which will be run against a machine or set of machines. Playbooks are usually specialised or private, e.g. you would have a playbook for configuring your application stack.
  * An **Inventory** is a list of hosts or machines which you can run your playbooks against. These can be grouped by purpose, or just be a list of hosts. Inventories like playbooks are usually specialised and private.
  * A **Role** is a set of **tasks**, **handlers**, **templates**, and **files** which will be run against your machine. Roles are reusable and shared via Ansible Galaxy or in source form.

We're going to create a **role**, which is a reusable unit in Ansible and can be distributed via Ansible Galaxy (or in source form).
