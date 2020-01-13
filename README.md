# Docker Birmingham January 2020 - Building Docker images for multiple architectures

This repo has the slides and some brief instructions for the [Jan 2020 Docker meetup](https://www.meetup.com/Docker-Birmingham/events/drrkmrybccblb/) I spoke at.   

The slides are available [here](Docker Birmingham January 2020.pdf).

## Getting Started

This repo contains a simple hello world Go application to demonstrate the compiler architecture and a number of environments to demonstrate buiuld and runtime configuration.

To get everything running you'll need:

### Build / Compile

* Docker for Desktop
* Vagrant & Virtualbox (or another compatible provider)
* Instructions for installing buildx plugin

### Running on Arm but don't have a board?

* An AWS accout
* Terraform

## Setup

Clone this repo first and `cd` into it.

### Docker for Desktop

Install / update to the latest and enable the experimental features. See the Docker getting started pages for more details [here](https://docs.docker.com/docker-for-mac/).

### Vagrant

This will install and setup an ubuntu instance with docker and the buildx plugin installed along with the QEMU emulation bindings to build non-host architectures.  The VM is configure to need 2vCPUs and 2G RAM.

* [Install Vagrant](https://www.vagrantup.com/intro/getting-started/install.html)
* `cd` into the `vagrant` folder.
* `vagrant up` will download the VM and run the scripts to install docker etc.  This could take a few mins depending upon your connection.
* `vagrant ssh` to get a terminal in the vm to run the commands in a "real" linux OS.
* `vagrant destroy` when you're finished working and don't need the VM anymore.

At the time of writing the head of `homebrew` installs incompatible versions of vagrant and virtualbox (Vagrant 2.2.6 & Virtualbox 6.1).  Until Vagrant have tested and released support for this combination the best bet for getting it working is to follow [this](https://github.com/oracle/vagrant-boxes/issues/178).

### Terraform

AWS have Arm64 architecture VMs available and should you not have access to a physical device, this can be a handy way of experimenting or even reducing your compute costs for [Wireguard](https://www.wireguard.com/) and other lower level appliance requirements!  If you've not done this before then it's probably best to run through the [docs for AWS](https://aws.amazon.com/premiumsupport/knowledge-center/create-and-activate-aws-account/) as there's not scope for running through it here.

The terraform template is located in the [/terraform](terraform/) folder.

## Running the builds

The [hello-world](hello-world) application to demonstrate the buildx capability as described in the slides, but as a quick summary:

```
docker buildx create --name mybuilder
docker buildx use mybuilder
docker buildx inspect --bootstrap
docker buildx build --load --platform linux/arm64 -t hello-world .
```  

## Authors

* **Matt Todd** - *Slides, Presentation & infra* - [mattjtodd](https://github.com/mattjtodd)

## License

This project is licensed under the Apache 2.0 License - see the [LICENSE.md](LICENSE.md) file for details
