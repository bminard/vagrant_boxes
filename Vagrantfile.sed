/^end/i \
\ \ config.ssh.private_key_path = \"../../credentials/vagrant_ssh_key\" \
\ \ config.vm.hostname = \"localhost.localdomain\" \
\ \ config.vm.network \"private_network\", type: \"dhcp\" \
\ \ config.vm.network :forwarded_port, guest: 80, host: 8080
\ \ config.vm.synced_folder \"../..\", \"/vagrant\",
\ \ \ \ mount_options: [\"dmode=777,fmode=666\"],
s/^config\./  &/
