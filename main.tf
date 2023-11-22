# Create a VPC
resource "aws_vpc" "project_vpc" {
  cidr_block = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "project_vpc"
  }
}

# Create a public subnet in us-east-2a
resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.project_vpc.id
  cidr_block        = var.subnet_cidr_block
  availability_zone = "us-east-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public_subnet"
  }
}

# Create an internet gateway and attach it to the VPC
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.project_vpc.id

  tags = {
    Name = "project_vpc_igw"
  }
}

# Create a route table and add routes
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.project_vpc.id

  # Route targeting the internet gateway for external traffic
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
    # Route targeting local network
  route {
    cidr_block = var.vpc_cidr_block
    gateway_id = "local"
  }

  tags = {
    Name = "public_route_table"
  }
}

# Associate the route table with the public subnet
resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_main_route_table_association" "main" {
  vpc_id         = aws_vpc.project_vpc.id
  route_table_id = aws_route_table.public_route_table.id
}

# Create an EC2 instance to manage configurations in us-east-2a
resource "aws_instance" "Master" {
  ami           = var.ami_id
  instance_type = var.instance_type 
  key_name      = var.key_name
  subnet_id     = aws_subnet.public_subnet.id

  # Security group configuration allowing SSH access
  security_groups = ["${aws_security_group.allow_ssh_http_https.id}"]

  tags = {
    Name = "Master"
  }
}

# Create EC2 instances "Workers" in us-east-2a
resource "aws_instance" "Worker" {
  count         = var.instance_count
  ami           = var.ami_id
  instance_type = var.instance_type 
  key_name      = var.key_name
  subnet_id     = aws_subnet.public_subnet.id

  # Security group configuration allowing SSH access
  security_groups = ["${aws_security_group.allow_ssh_http_https.id}"]

  tags = {
    Name = "Worker-${count.index + 1}"
  }
}

resource "aws_security_group" "allow_ssh_http_https" {
  name        = "allow-ssh-http-https"
  description = "Allow SSH, HTTP, and HTTPS inbound traffic and all outbound traffic"
  
  vpc_id = aws_vpc.project_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
    egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # Indicates all protocols
    cidr_blocks = ["0.0.0.0/0"]
  }
}