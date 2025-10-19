# SSH Key Pair
resource "aws_key_pair" "deployer" {
  key_name   = "${var.environment_id}-key"
  public_key = file("${path.module}/id_rsa.pub")
}

# Latest Ubuntu AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# EC2 Instance - Web Tier
resource "aws_instance" "web" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.web_instance_type
  subnet_id              = aws_subnet.public[0].id
  vpc_security_group_ids = [aws_security_group.web.id]
  key_name               = aws_key_pair.deployer.key_name

  user_data = <<-EOF
              #!/bin/bash
              curl -fsSL https://deb.nodesource.com/setup_22.x | sudo bash - 
              apt-get update
              apt-get install -y nginx nodejs
              systemctl enable nginx
              systemctl start nginx
              echo "<h1>Web Server - ${var.environment_id}</h1><p>Environment: ${var.environment_id}</p>" > /var/www/html/index.html
              EOF

  tags = {
    Name        = "${var.environment_id}-web-server"
    Environment = var.environment_id
    Tier        = "web"
  }

  depends_on = [aws_internet_gateway.main]
}

# EC2 Instance - App Tier
resource "aws_instance" "app" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.app_instance_type
  subnet_id              = aws_subnet.private[0].id
  vpc_security_group_ids = [aws_security_group.app.id]
  key_name               = aws_key_pair.deployer.key_name

  user_data = <<-EOF
              #!/bin/bash
              curl -fsSL https://deb.nodesource.com/setup_22.x | sudo bash - 
              apt-get update
              apt-get install -y nodejs postgresql-client
              npm install -g pm2
              EOF

  tags = {
    Name        = "${var.environment_id}-app-server"
    Environment = var.environment_id
    Tier        = "app"
  }
  
  depends_on = [aws_nat_gateway.main, aws_db_instance.postgres]
}