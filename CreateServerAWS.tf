provider "aws" {
  region = "eu-central-1"
}
resource "aws_instance" "my_ubuntu" {
  ami                    = "ami-015c25ad8763b2f11"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.my_vpn.id]

  user_data = <<EOF
#!/bin/bash
sudo -i
apt update && sudo apt -y install ca-certificates wget net-tools gnupg
wget -qO - https://as-repository.openvpn.net/as-repo-public.gpg | apt-key add -
echo "deb http://as-repository.openvpn.net/as/debian focal main">/etc/apt/sources.list.d/openvpn-as-repo.list
apt update && apt -y install openvpn-as
exit
EOF

  tags = {
    Name = "OpenVPN"
  }
}
resource "aws_security_group" "my_vpn" {
  name        = "VPN Security Group"
  description = "Test for SG"

  dynamic "ingress" {
    for_each = ["22", "80", "443", "943"]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]

    }

  }

  ingress {
    from_port   = 1194
    to_port     = 1194
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]

  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
