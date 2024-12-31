variable "organization" {
  type    = string
  default = "organization"
}

variable "project" {
  type    = string
  default = "project"
}

variable "egress_worker_filter" {
  type = string
  default = "\"egress\" in \"/tags/type\""
}

variable "ingress_worker_filter" {
  type = string
  default = "\"ingress\" in \"/tags/type\""
}

variable "horizon_vdi_host_catalog" {
  type    = string
  default = "UAG Host Catalog"
}

variable "horizon_vdi_host_name" {
  type    = string
  default = "example"
}

variable "horizon_vdi_host_address" {
  type    = string
}

variable "horizon_vdi_fqdn" {
  type    = string
}

