#!/usr/bin/env bash
set -e
set -o pipefail

TOKEN=`curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"` \
&& curl -H "X-aws-ec2-metadata-token: $TOKEN" -v http://169.254.169.254/latest/user-data

sudo wget https://releases.hashicorp.com/vault-ssh-helper/0.2.0/vault-ssh-helper_0.2.0_linux_amd64.zip
sudo apt-get install zip unzip
sudo unzip -q vault-ssh-helper_0.2.0_linux_amd64.zip -d /usr/local/bin
sudo chmod 0755 /usr/local/bin/vault-ssh-helper
sudo chown root:root /usr/local/bin/vault-ssh-helper
sudo mkdir /etc/vault-ssh-helper.d/

sudo su 
sudo cat <<EOF > /etc/vault-ssh-helper.d/config.hcl
vault_addr = "https://public-vault-cluster.vault.d46ab3cb-eed2-4a64-b324-51e12e2418eb.aws.hashicorp.cloud:8200"
tls_skip_verify = false
ca_cert = "<PEM_ENCODED_CA_CERT>"
ssh_mount_point = "ssh"
namespace = "admin"
allowed_roles = "*"
EOF

sudo cp /etc/pam.d/sshd /etc/pam.d/sshd.orig

cat <<EOF > /etc/pam.d/sshd
auth requisite pam_exec.so quiet expose_authtok log=/var/log/vault-ssh.log /usr/local/bin/vault-ssh-helper -dev -config=/etc/vault-ssh-helper.d/config.hcl
auth optional pam_unix.so not_set_pass use_first_pass nodelay
EOF

sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.orig

cat <<EOF > /etc/ssh/sshd_config
ChallengeResponseAuthentication yes
UsePAM yes
PasswordAuthentication no
EOF

exit 

sudo systemctl restart sshd

vault-ssh-helper -verify-only -dev -config /etc/vault-ssh-helper.d/config.hcl

REMOTE_HOST_IP="${aws_eip.mock_splunk.public_ip}"

vault login -method=userpass username=ryan password=training

vault write ssh/creds/otp_key_role ip=$REMOTE_HOST_IP
