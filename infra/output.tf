output "alb_dns_name" {
  description = "URL pública do Load Balancer. Use este endereço no código do seu Frontend!"
  value       = "http://${aws_lb.main.dns_name}" # Já concatenamos o http:// para facilitar sua vida
}

output "cloudfront_website_url" {
  description = "Public URL of the static website served through CloudFront."
  value       = "https://${aws_cloudfront_distribution.static_site.domain_name}"
}