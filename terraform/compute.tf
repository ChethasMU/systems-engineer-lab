data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

data "aws_iam_instance_profile" "lab" {
  name = "lab-ec2-profile"
}

resource "aws_security_group" "app" {
  name        = "tf-app-sg"
  description = "github-api on 8080 from my IP only"
  vpc_id      = aws_vpc.main.id
}

resource "aws_vpc_security_group_ingress_rule" "app_8080" {
  security_group_id = aws_security_group.app.id
  cidr_ipv4         = var.my_ip_cidr
  from_port         = 8080
  to_port           = 8080
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "all_out" {
  security_group_id = aws_security_group.app.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_instance" "app" {
  ami                    = data.aws_ami.al2023.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.this["public-a"].id
  vpc_security_group_ids = [aws_security_group.app.id]
  iam_instance_profile   = data.aws_iam_instance_profile.lab.name

  user_data = <<-EOF
    #!/bin/bash
    set -euxo pipefail
    dnf install -y docker git
    systemctl enable --now docker
    git clone https://github.com/ChethasMU/systems-engineer-lab.git /opt/lab
    cd /opt/lab/github-api
    docker build -t github-api .
    docker run -d --restart unless-stopped -p 8080:8080 --name api github-api
  EOF

  user_data_replace_on_change = true

  tags = { Name = "tf-github-api" }
}