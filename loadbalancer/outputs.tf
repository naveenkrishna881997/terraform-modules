output "elb_dns_name" {
  value       = aws_elb.demo[0].dns_name
  description = "The domain name of the load balancer"
}

