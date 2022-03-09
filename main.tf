#Create a VPC
resource "aws_vpc" "KPMG_VPC" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"

  tags = {
    Name = "KPMG_VPC"
  }
}

#Create Two Public Subnets

#Public Subnet 01
resource "aws_subnet" "KPMG_Pub_SN_01" {
  vpc_id     = aws_vpc.KPMG_VPC.id
  cidr_block = var.sub_cidr_1
  availability_zone = var.az_1

  tags = {
    Name = "KPMG_Pub_SN_01"
  }
}
#Public 02
resource "aws_subnet" "KPMG_Pub_SN_02" {
  vpc_id     = aws_vpc.KPMG_VPC.id
  cidr_block = var.sub_cidr_2
  availability_zone = var.az_2

  tags = {
    Name = "KPMG_Pub_SN_02"
  }
}

#Create Two Private Subnets

#Private 01
resource "aws_subnet" "KPMG_Pri_SN_01" {
  vpc_id     = aws_vpc.KPMG_VPC.id
  cidr_block = var.sub_cidr_3
  availability_zone = var.az_1

  tags = {
    Name = "KPMG_Pri_SN_01"
  }
}
#Private 02
resource "aws_subnet" "KPMG_Pri_SN_02" {
  vpc_id     = aws_vpc.KPMG_VPC.id
  cidr_block = var.sub_cidr_4
  availability_zone = var.az_2

  tags = {
    Name = "KPMG_Pri_SN_02"
  }
}

#Create a Internet Gateway
resource "aws_internet_gateway" "KPMG_IGW" {
  vpc_id = aws_vpc.KPMG_VPC.id

  tags = {
    Name = "KPMG_IGW"
  }
}
#Create EIP for Nat Gateway
resource "aws_eip" "KPMG_EIP" {
  vpc       = true
}

#Create a NAT Gateway
 resource "aws_nat_gateway" "KPMG_NAT" {
  allocation_id = aws_eip.KPMG_EIP.id
  subnet_id     = aws_subnet.KPMG_Pub_SN_01.id

  tags = {
    Name = "KPMG_NAT"
  }
}
#Create a Public Route Table
resource "aws_route_table" "KPMG_Pub_RT" {
  vpc_id = aws_vpc.KPMG_VPC.id
  route {
    cidr_block = var.all_cidr
    gateway_id = aws_internet_gateway.KPMG_IGW.id
  }
    tags = {
    Name = "KPMG_Pub_RT"
  }
}

#Create a Private Route Table
resource "aws_route_table" "KPMG_Prv_RT" {
  vpc_id = aws_vpc.KPMG_VPC.id

  route {
    cidr_block = var.all_cidr
    nat_gateway_id = aws_nat_gateway.KPMG_NAT.id
  }

    tags = {
    Name = "KPMG_Prv_RT"
  }
}
#Associate Pub SN to Pub RT
resource "aws_route_table_association" "KPMG_Pub_Ass_1" {
  subnet_id      = aws_subnet.KPMG_Pub_SN_01.id
  route_table_id = aws_route_table.KPMG_Pub_RT.id
}
resource "aws_route_table_association" "KPMG_Pub_Ass_2" {
  subnet_id      = aws_subnet.KPMG_Pub_SN_02.id
  route_table_id = aws_route_table.KPMG_Pub_RT.id
}
#Associate Prv SN to Prv RT
resource "aws_route_table_association" "KPMG_Prv_Ass_1" {
  subnet_id      = aws_subnet.KPMG_Pri_SN_01.id
  route_table_id = aws_route_table.KPMG_Prv_RT.id
}
resource "aws_route_table_association" "KPMG_Prv_Ass_2" {
  subnet_id      = aws_subnet.KPMG_Pri_SN_02.id
  route_table_id = aws_route_table.KPMG_Prv_RT.id
}

# Create a Bastion Host Security Groups
resource "aws_security_group" "KPMG_BASTION_SG" {
  name        = "KPMG_BASTION_SG"
  description = "Security groups for bastion host"
  vpc_id      = aws_vpc.KPMG_VPC.id
  ingress {
    description      = "SSH from VPC"
    from_port        = var.port_ssh
    to_port          = var.port_ssh
    protocol         = "tcp"
    cidr_blocks      = [var.my_ip]  # only from my ip
  }
    ingress {
    description      = "HTTP from VPC"
    from_port        = var.port_http
    to_port          = var.port_http
    protocol         = "tcp"
    cidr_blocks      = [var.my_ip] # only from my ip
  }
      ingress {
    description      = "Proxy from VPC"
    from_port        = var.port_proxy
    to_port          = var.port_proxy
    protocol         = "tcp"
    cidr_blocks      = [var.my_ip] # only from my ip
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = [var.all_cidr]
  }

  tags = {
    Name = "KPMG_BASTION_SG"
  }
}

# Create a Web Security Group 
 resource "aws_security_group" "KPMG_WBS_SG" {
  name        = "KPMG_WBS_SG"
  description = "Allow inbound traffic from http"
  vpc_id      = aws_vpc.KPMG_VPC.id

    ingress {
    description      = "Allow inbound traffic from ssh"
    from_port        = var.port_ssh
    to_port          = var.port_ssh
    protocol         = "tcp"
    cidr_blocks      = [var.sub_cidr_1] # from bastion host
}

ingress {
    description      = "Allow inbound traffic from http"
    from_port        = var.port_http
    to_port          = var.port_http
    protocol         = "tcp"
    cidr_blocks      = [var.sub_cidr_1] # from bastion host
}

ingress {
    description      = "Allow inbound traffic from mysql"
    from_port        = var.port_mysql
    to_port          = var.port_mysql
    protocol         = "tcp"
    cidr_blocks      = [var.sub_cidr_1] # from bastion host
}
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
}
  tags = {
    Name = "KPMG_WBS_SG"
  }
}

# Create a Database Security Group for all Server
 resource "aws_security_group" "KPMG_DB_SG" {
  name        = "KPMG_DB_SG"
  description = "Allow inbound traffic from http"
  vpc_id      = aws_vpc.KPMG_VPC.id
 
    
    ingress {
    description      = "Allow inbound traffic from ssh"
    from_port        = var.port_ssh
    to_port          = var.port_ssh
    protocol         = "tcp"
    cidr_blocks      = [var.sub_cidr_1] # only from the bastion host
}

ingress {
    description      = "Allow inbound traffic from mysql"
    from_port        = var.port_mysql
    to_port          = var.port_mysql
    protocol         = "tcp"
    cidr_blocks      = [var.sub_cidr_3]  # only from web server
}

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
}
  tags = {
    Name = "KPMG_DB_SG"
  }
}

#Create Key Pair
resource "aws_key_pair" "KPMG_Key" {
 key_name = "KPMG_Key"
public_key = file(var.PATH_TO_PUBLIC_KEY) 
}
# Create a Web Server 
resource "aws_instance" "Web_Server" {
  ami           = var.ami
  instance_type = var.instance_type
  availability_zone = var.az_1
  key_name = aws_key_pair.KPMG_Key.key_name
  subnet_id     = aws_subnet.KPMG_Pri_SN_01.id
  vpc_security_group_ids = ["${aws_security_group.KPMG_WBS_SG.id}"]
  associate_public_ip_address = false

  tags = {
    Name = "Web_Server"
  }
}
# Create WEB Server AMI Image
resource "aws_ami_from_instance" "Web_Server-Image" {
  name               = "Web_Server-Image"
  source_instance_id = "${aws_instance.Web_Server.id}"
  snapshot_without_reboot = false
  
   depends_on = [
      aws_instance.Web_Server,
      ]

  tags = {
      Name = "Web_Server-Image"
  }
}

# Create a Database Server 
resource "aws_instance" "Mysql_Server" {
  ami           = var.ami
  instance_type = var.instance_type
  availability_zone = var.az_2
  key_name = aws_key_pair.KPMG_Key.key_name
  subnet_id     = aws_subnet.KPMG_Pri_SN_02.id
  vpc_security_group_ids = ["${aws_security_group.KPMG_WBS_SG.id}"]
  associate_public_ip_address = false

  tags = {
    Name = "Mysql_Server"
  }
}

# Create a Bastion Server 
resource "aws_instance" "Bastion_Server" {
  ami           = var.ami
  instance_type = var.instance_type
  availability_zone = var.az_1
  key_name = aws_key_pair.KPMG_Key.key_name
  subnet_id     = aws_subnet.KPMG_Pub_SN_01.id
  vpc_security_group_ids = ["${aws_security_group.KPMG_BASTION_SG.id}"]
  associate_public_ip_address = true

  tags = {
    Name = "Bastion_Server"
  }
}



# Create a Target Group for Load Balancer
resource "aws_lb_target_group" "lb-tg" {
  name                      = var.lb_tg_name
  port                      = 8080 # NOTE this would be the application port
  protocol                  = var.lb_protocol
  vpc_id                    = aws_vpc.KPMG_VPC.id

    target_type             = var.lb_tg_TT
    health_check {
    healthy_threshold       = 2
    unhealthy_threshold     = 2
    timeout                 = 3
    interval                = 30
    path                    = var.lb_tg_path
  }
}

# Create a Target Group Attachment 
resource "aws_lb_target_group_attachment" "tg-attach" {
  target_group_arn          = aws_lb_target_group.lb-tg.arn
  target_id                 = "${aws_instance.Web_Server.id}"
  port                      = 8080  # NOTE this would be the  application port

depends_on = [
      aws_instance.Web_Server,aws_lb_target_group.lb-tg
      ]
}

#Create a Load Balancer
resource "aws_lb" "lb-kpmg" {
  name                      = var.lb_name
  internal                  = false
  load_balancer_type        = var.lb_type
  security_groups           = [aws_security_group.KPMG_BASTION_SG.id]
  subnets                   = [aws_subnet.KPMG_Pub_SN_01.id,aws_subnet.KPMG_Pub_SN_02.id]
  enable_deletion_protection = false


  tags = {
    Environment = "lb-kpmg"
  }
}
#Create a Listener for Load Balancer
resource "aws_lb_listener" "listen-target" {
  load_balancer_arn        = aws_lb.lb-kpmg.arn
  port                     = 80
  protocol                 = var.lb_protocol

  default_action {
    type                   = var.lb_listener_DAT
    target_group_arn       = aws_lb_target_group.lb-tg.arn
  }
  depends_on = [
       aws_lb.lb-kpmg,aws_lb_target_group.lb-tg
      ]
}

# Creating launch configuration
resource "aws_launch_configuration" "KPMG-LC" {
  name_prefix   = "KPMG-LC"
  image_id      =   "${aws_ami_from_instance.Web_Server-Image.id}"
  instance_type = var.instance_type
  security_groups = [aws_security_group.KPMG_BASTION_SG.id]
  key_name = aws_key_pair.KPMG_Key.key_name

  lifecycle {
    create_before_destroy = true
    
  }
  depends_on = [
aws_ami_from_instance.Web_Server-Image,
    ]
} 
#Create Autoscaling group policy
resource "aws_autoscaling_group" "KPMG-ASG" {
  name                      = "KPMG-ASG"
  max_size                  = 3
  min_size                  = 2
  health_check_grace_period = 300
  health_check_type         = "EC2"
  desired_capacity          = 2
  force_delete              = true
  launch_configuration      = aws_launch_configuration.KPMG-LC.name
  vpc_zone_identifier       = [aws_subnet.KPMG_Pri_SN_01.id, aws_subnet.KPMG_Pri_SN_02.id]
}
#Create a Autosacaling group Policy
resource "aws_autoscaling_policy" "KPMG-ASG-Policy" {
  name                   = "KPMG-ASG-Policy"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60
  autoscaling_group_name = aws_autoscaling_group.KPMG-ASG.name
}