[f5]
${public_ip}

[f5:vars]
ansible_connection=ssh
ansible_user=${admin_username}
ansible_ssh_pass=${admin_password}