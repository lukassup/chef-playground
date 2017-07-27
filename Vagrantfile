# -*- mode: ruby -*-
# vi: set ft=ruby :

CHEF_SERVER_SCRIPT = <<EOF.freeze
echo '*** PROVISIONING CHEF SERVER ***'
yum update -y
yum install -y curl ntp
systemctl start ntpd
systemctl enable ntpd
rpm -Uvh /vagrant/chef-server-core-12.15.8-1.el7.x86_64.rpm
chef-server-ctl reconfigure
chef-server-ctl restart
until (curl -D - 'http://localhost:8000/_status') | grep '200 OK'; do sleep 3s; done
while (curl 'http://localhost:8000/_status') | grep 'fail'; do sleep 3s; done
chef-server-ctl user-create admin Test Admin admin@test.com password --filename admin.pem
chef-server-ctl org-create test "Automation Testing, Inc." --association_user admin --filename org-validator.pem
mkdir -p /vagrant/secrets
cp -f /home/vagrant/admin.pem /vagrant/secrets
echo '*** CHEF SERVER PROVISIONED ***'
EOF

CHEF_NODE_SCRIPT = <<EOF.freeze
echo '*** PROVISIONING CHEF NODE ***'
yum update -y
yum install -y ntp
systemctl start ntpd
systemctl enable ntpd
echo '*** CHEF NODE PROVISIONED ***'
EOF

Vagrant.configure('2') do |config|
  config.vm.box = 'centos/7'
  config.vm.provider :libvirt do |domain|
    domain.graphics_type = 'none'
    domain.graphics_ip = nil
    domain.graphics_port = nil
    domain.video_type = nil
    domain.video_vram = 0
    domain.memory = 512
    domain.cpus = 1
    domain.random model: 'random'
  end
  config.vm.provider :libvirt do |_, override|
    # NOTE: RHEL/CentOS does not know how to share directories using 9p yet so
    # you have to manually retrieve the key from /vagrant/secrets/admin.pem!
    # override.vm.synced_folder '.', '/vagrant', type: '9p', readonly: true
  end

  %w[chef-server node-1 node-2 node-3].each do |vm_name|
    config.vm.define vm_name do |machine|
      machine.vm.hostname = vm_name
      if Vagrant.has_plugin?('vagrant-cachier')
        config.cache.scope = :box
        # config.cache.synced_folder_opts = {
        #   type: :nfs,
        #   mount_options: ['rw', 'vers=3', 'tcp', 'nolock']
        # }
      end
    end
  end

  config.vm.define 'chef-server' do |machine|
    machine.vm.provider :libvirt do |domain|
      domain.memory = 4096
      domain.cpus = 2
    end
    machine.vm.provision 'shell', inline: CHEF_SERVER_SCRIPT.dup
  end

  %w[node-1 node-2 node-3].each do |vm_name|
    config.vm.define vm_name do |machine|
      machine.vm.provision 'shell', inline: CHEF_NODE_SCRIPT.dup
    end
  end
end
