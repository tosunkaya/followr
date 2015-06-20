# Check Vagrant version
Vagrant.require_version ">= 1.7.0"

# Auto-install missing plugins
%w(triggers exec hostmanager cachier).select do |plugin| 
  !Vagrant.has_plugin?("vagrant-#{plugin}") and system "vagrant plugin install vagrant-#{plugin}" 
end.empty? or exec "vagrant #{ARGV.join ' '}"

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/trusty64"

  # Package cache, to speed up rebuilds
  config.cache.scope = :box
  config.cache.enable :apt_lists
  config.cache.enable :apt

  domain = File.basename(File.expand_path(File.dirname(__FILE__))) + ".dev"

  # Host management
  config.hostmanager.enabled = true
  config.hostmanager.manage_host = true
  config.hostmanager.ignore_private_ip = false
  config.hostmanager.include_offline = true
  config.vm.hostname = domain
  config.hostmanager.aliases = %W[www.#{domain}]

  # Provisioning
  config.vm.provision "system", 
      type: "shell", 
      path: "provision/system.sh", 
      keep_color: true, 
      args: [ domain, '/vagrant']

  config.vm.provision "application",
      type: "shell", 
      path: "provision/application.sh", 
      keep_color: true,    
      privileged: false, 
      run: "always", 
      args: [ domain, '/vagrant']

  # Network configuration
  config.vm.network "private_network", type: "dhcp"
  config.hostmanager.ip_resolver = proc do |vm, resolving_vm|
    hostname = (vm.ssh_info && vm.ssh_info[:host])
    if hostname
      `vagrant ssh -c "/sbin/ifconfig eth1" | grep "inet addr" | tail -n 1 | egrep -o "[0-9\.]+" | head -n 1 2>&1`.split("\n").first[/(\d+\.\d+\.\d+\.\d+)/, 1]
    end
  end

  # Memory & CPU
  config.vm.provider "virtualbox" do |v|
    v.memory = 2048
    v.cpus = 2
    v.customize [ "guestproperty", "set", :id, "/VirtualBox/GuestAdd/VBoxService/--timesync-set-threshold", 10000 ]
  end

  # Start foreman on vagrant up
  config.trigger.after :up do
    info "Starting or reattaching to application server..."
    system "vagrant ssh -c 'cd /vagrant && (pgrep -x screen > /dev/null && screen -R -D || (screen bash -c \"while :; do foreman start -e .env,.env.development; echo; echo \\\"Process terminated with code $?. Press ENTER to restart, Ctrl-C to exit\\\"; read; done\"))'"
    info "Application server stopped or session detached."
    warn "To restart or reattach please type 'vagrant up' again, to stop the VM 'vagrant halt'."
  end

  # Exec commands in the right environment
  config.exec.commands %w(rails rspec rake), prepend: 'foreman run -e .env,.env.development bundle exec'
  config.exec.commands %w(bundle), prepend: 'foreman run -e .env,.env.development'

end
