output "Web_Server" {
     value = aws_instance.Web_Server.public_ip
 }
 output "Bastion_Server" {
      value = aws_instance.Bastion_Server.public_ip
}
output "lb_endpoint" {
    value = aws_lb.lb-kpmg.dns_name
}