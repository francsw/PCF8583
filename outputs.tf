output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_spot_instance_request.game_vm.id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_spot_instance_request.game_vm.public_ip
}

output "elastic_ip" {
  description = "Public elastic ip"
  value = aws_eip.ip-game-env.public_ip
}