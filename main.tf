provider "aws" {
  region = "eu-west-2"
  profile = "ethereum-network"
}

provider "tls" {}

data "aws_caller_identity" "current" {}

output "account_id" {
  description = "The AWS account ID"
  value       = data.aws_caller_identity.current.account_id
}

output "private_key_pem" {
  value = tls_private_key.eth_ssh_key.private_key_pem
  sensitive = true
}

output "public_ip" {
  value = aws_instance.ethereum_node.public_ip
}


resource "tls_private_key" "eth_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}


resource "local_file" "private_key" {
  content  = tls_private_key.eth_ssh_key.private_key_pem
  filename = "${path.module}/private_key.pem"
}

resource "aws_security_group" "ethereum_sg" {
  name        = "ethereum_security_group"
  description = "Allow Ethereum and SSH inbound traffic"

  # SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Adjust this to specific IPs or ranges for better security
  }

  # Ethereum P2P
  ingress {
    from_port   = 30303
    to_port     = 30303
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 30303
    to_port     = 30303
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Ethereum HTTP-RPC (Be very careful with this one)
  ingress {
    from_port   = 8545
    to_port     = 8545
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Restrict this to specific IPs for better security
  }

  ingress {
    from_port   = 8551
    to_port     = 8551
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Restrict this to specific IPs for better security
  }

  # Ethereum WebSocket-RPC (Again, be careful)
  # ingress {
  #   from_port   = 8546
  #   to_port     = 8546
  #   protocol    = "tcp"
  #   cidr_blocks = ["YOUR_KNOWN_IP/32"] # Restrict this to specific IPs for better security
  # }

  # Default egress rule to allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_instance" "ethereum_node" {
  ami             = "ami-0eb260c4d5475b901" # This is a standard Ubuntu 22.04 LTS AMI in eu-west-2
  instance_type   = "t2.micro"
  key_name        = tls_private_key.eth_ssh_key.private_key_pem 
  security_groups = [aws_security_group.ethereum_sg.name]

  tags = {
    Name = "ethereum-network"
  }

    provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y software-properties-common",
      "sudo add-apt-repository -y ppa:ethereum/ethereum",
      "sudo apt-get update",
      "sudo apt-get install -y ethereum",

      "mkdir ~/myethprivatenet",
      "echo '${file(var.genesis_file_path)}' > ~/myethprivatenet/genesis.json",
      "echo '${file(var.password_file_path)}' > ~/myethprivatenet/password",
      "geth --datadir ~/myethprivatenet/mydata init ~/myethprivatenet/genesis.json",
      "echo '${file(var.keystore_file_path)}' > ~/myethprivatenet/mydata/keystore/${var.keystore_file_name}",

      "sudo touch /etc/systemd/system/ethnode.service",
      "echo '${file(var.service_file_path)}' | sudo tee /etc/systemd/system/ethnode.service",
      "sudo sed -i 's/<Your Public IP>/${self.public_ip}/g' /etc/systemd/system/ethnode.service",
      "sudo systemctl daemon-reload",
      "sudo systemctl unmask ethnode",
      "sudo systemctl enable ethnode",
      "sudo systemctl start ethnode",
      "sleep 10",
      "tail -n 40 ~/myethprivatenet/geth.log"
    ]



    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.ssh_private_key_path)
      host        = self.public_ip
      timeout     = "3m" # Wait up to 5 minutes for connection
    }
  }
}


