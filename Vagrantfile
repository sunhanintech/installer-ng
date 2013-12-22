# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.hostname = "scalr-core-chef-berkshelf"

  config.vm.box = "opscode-ubuntu-12.04"
  config.vm.box_url = "http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_ubuntu-12.04_chef-provisionerless.box"

  config.vm.provider "virtualbox" do |v|
    v.memory = 1024
  end

  config.omnibus.chef_version = "11.8.2"
  config.vm.network :private_network, ip: "33.33.33.10"
  config.vm.boot_timeout = 120
  config.berkshelf.enabled = true

  config.vm.provision :chef_solo do |chef|
    chef.json = {
      :mysql => {
        :server_root_password => 'rootpass',
        :server_debian_password => 'debpass',
        :server_repl_password => 'replpass'
      }
    }

    chef.run_list = [
        "recipe[scalr-core::default]"
    ]
  end
end
