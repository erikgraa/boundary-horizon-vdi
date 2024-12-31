data "boundary_scope" "organization" {
  name     = var.organization
  scope_id = "global"
}

data "boundary_scope" "project" {
  name     = var.project
  scope_id = data.boundary_scope.organization.id
}

data "boundary_auth_method" "auth_method" {
  name = "password"
}

resource "boundary_host_catalog_static" "horizon_vdi_host_catalog" {
  name        = var.horizon_vdi_host_catalog
  description = "Host catalog for testing Horizon VDI with Boundary Transparent Sessions"
  scope_id    = data.boundary_scope.project.id
}

resource "boundary_host_static" "horizon_vdi_host" {
  name            = var.horizon_vdi_host_name
  description     = "Host for testing Horizon VDI with Boundary Transparent Sessions"
  address         = var.horizon_vdi_host_address
  host_catalog_id = boundary_host_catalog_static.horizon_vdi_host_catalog.id
}

resource "boundary_host_set_static" "horizon_vdi_host_set" {
  host_catalog_id = boundary_host_catalog_static.horizon_vdi_host_catalog.id
  host_ids = [
    boundary_host_static.horizon_vdi_host.id,
  ]
}

resource "boundary_target" "horizon_vdi" {
  name         = "Horizon VDI"
  description  = "Horizon VDI HTML Access"
  type         = "tcp"
  default_port = "443"
  scope_id     = data.boundary_scope.project.id
  host_source_ids = [
    boundary_host_set_static.horizon_vdi_host_set.id
  ]
  egress_worker_filter  = var.egress_worker_filter
  ingress_worker_filter = var.ingress_worker_filter
}

resource "boundary_alias_target" "horizon_vdi_alias_target" {
  name                      = "Horizon VDI Alias"
  description               = "Horizon VDI HTML Access"
  scope_id                  = "global"
  value                     = var.horizon_vdi_fqdn
  destination_id            = boundary_target.horizon_vdi.id
  authorize_session_host_id = boundary_host_static.horizon_vdi_host.id
}

resource "random_password" "authorized_vdi_user_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "boundary_account_password" "authorized_vdi_user" {
 auth_method_id = data.boundary_auth_method.auth_method.id
 login_name     = "authorizedforvdi"
 password       = random_password.authorized_vdi_user_password.result
}

resource "boundary_user" "authorized_vdi_user" {
  name        = "authorizedforvdi"
  description = "Authorized for Horizon HTML Access"
  account_ids = [boundary_account_password.authorized_vdi_user.id]
  scope_id    = "global"
}

resource "boundary_role" "authorized_global_role" {
 name          = "authorized_global_role"
 description   = "Authorized Global Role"
 scope_id      = "global"
 principal_ids = [boundary_user.authorized_vdi_user.id]
 grant_strings = [
   "ids=*;type=*;actions=read",
   "type=auth-token;ids=*;actions=read:self",
   "type=user;actions=list-resolvable-aliases;ids=*",
 ]
}
 
resource "boundary_role" "authorized_org_role" {
 name          = "authorized_org_role"
 description   = "Authorized Org Role"
 scope_id      = data.boundary_scope.organization.id
 principal_ids = [boundary_user.authorized_vdi_user.id]
 grant_strings = ["ids=*;type=*;actions=*"]
} 

resource "boundary_role" "authorized_target_role" {
 name          = "authorized_target_role"
 description   = "Authorized target Role"
 scope_id      = data.boundary_scope.project.id
 principal_ids = [boundary_user.authorized_vdi_user.id]
 grant_strings = ["ids=*;type=*;actions=*"]
}