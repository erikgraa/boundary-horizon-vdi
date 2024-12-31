output "authorized_vdi_user_password" {
  value = random_password.authorized_vdi_user_password.result
  sensitive = true
}