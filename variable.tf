variable "vpc_cidr" {
    default = "10.0.0.0/16"
    description = "the cidr block of the vpc"
} 

variable "sub_cidr_1"{
   default = "10.0.1.0/24"
   description = "the cidr block of pub sub" 
}
variable "sub_cidr_2"{
   default = "10.0.2.0/24"
   description = "the cidr block of pub sub" 
}
variable "sub_cidr_3"{
   default = "10.0.3.0/24"
   description = "the cidr block of prv sub" 
}
variable "sub_cidr_4" {
    default = "10.0.4.0/24"
    description = "the cidr block of prv sub"
}

variable "az_1" {
    default = "eu-west-1a"
    description = "the zone to be created"
} 

variable "az_2" {
    default = "eu-west-1b" 
    description = "the zone to be created"
}
variable "my_ip" {
    default = "0.0.0.0/0"
    description = "the route cidr"
}
variable "all_cidr" {
    default = "0.0.0.0/0"
    description = "the route cidr"
}
variable "nat_cidr" {
    default = "10.0.1.0/24"
    description = "the route cidr"
}
variable "port_ssh"{
    default = "22"
    description = "port for the ssh"
} 
variable "port_http" {
    default = "80"
    description ="the port for http"
}
variable "port_proxy"{
    default = "8080"
    description = "the port for proxy"
}
variable "port_mysql" {
    default = "3306"
    description = "port for mysql server"
}
variable "PATH_TO_PUBLIC_KEY"{
   default = "/Users/DanielDavid/Documents/3_tier_application/Keypair.pub"
  description ="path to Public key"
}
variable "instance_type"{
   default = "t2.micro"
  description ="instance type"
}
variable "ami"{
   default = "ami-0ec23856b3bad62d3"
  description = "ami for instance"
}
variable "lb_tg_name" {
    default      = "lb-tg"
    description  = "The Load Balancer target group name"
    type         = string
}
variable "lb_protocol" {
    default      = "HTTP"
    description  = "The Load Balancer protocol"
    type         = string
}
variable "lb_tg_TT" {
    default      = "instance"
    description  = "The Load Balancer target group type"
    type         = string
}
variable "lb_tg_path" {
    default      = "/index.html"
    description  = "The Load Balancer target group path"
    type         = string
}
variable "lb_name" {
    default      = "lb-team1"
    description  = "The Load Balancer name"
    type         = string
}
variable "lb_type" {
    default      = "application"
    description  = "The Load Balancer type"
    type         = string
}
variable "lb_ALog_prefix" {
    default      = "myprefix"
    description  = "The Load Balancer Access log prefix"
    type         = string
}
variable "lb_listener_DAT" {
    default      = "forward"
    description  = "The Load Balancer Listener Default Action Type"
    type         = string
}