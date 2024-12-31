data "boundary_scope" "organization" {
  name     = var.organization
  scope_id = "global"
}

data "boundary_scope" "project" {
  name     = var.project
  scope_id = data.boundary_scope.organization.id
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