# Building A Router from Scratch with Debian 12

An Ansible playbook that builds a router from scratch on Debian 12 in one command.

This repo is the implementation of [my blog post](https://tongkl.com/building-a-router-from-scratch-part-1/).

## How to Run

Clone this repo and open in an IDE. Use global find and replace to substitute the following fields:

* `TIMEZONE_TO_BE_FILLED`: e.g. `America/Chicago`
* `WAN_PORT_TO_BE_FILLED`: the WAN port you want your router to use. e.g. `enp1s0`
* `LAN_PORTS_LIST`: the LAN ports you want you router to use. e.g. `enp2s0 enp3s0 enp4s0`
* `ULA_PREFIX_TO_BE_FILLED`: the ULA prefix you want to use in your LAN. e.g. `fd00::`. Do not put `/64` as it is in the config files already.
* Go to `roles/router/tasks/conf/interfaces`. Replace these commented lines with your LAN ports:
``` bash
  # TODO: replace the following with your LAN ports
  # up ip link set enp2s0 up
  # up ip link set enp3s0 up
  # up ip link set enp4s0 up
```
* Go to `inventory/group_vars/all/vars.yaml` and replace the user name with your preferred user name the router will use.
* By default the Pi-hole admin portal is on port `8765`. Search and replace to whatever port you like.

The Ansible configuration is now done.

Perform a fresh install of Debian 12 on your future router. Give the user sudo privilege. Configure the router to have the static IP `192.168.0.1` on one of the LAN interfaces so that you can connect to it via `ssh`. Plug the WAN cable in the WAN port and configure it to use DHCP so the machine has Internet access. Install `python3` and `openssh-server` on the machine.

``` bash
$ sudo apt install openssh-server python3
```

Copy the ssh keys of your Ansible host to the router. You are good to go. Just run Ansible and it will be done.

``` bash
$ ansible-playbook -i inventory/hosts playbooks/router/main.yaml -K
```
