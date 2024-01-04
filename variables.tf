variable "do_token" {
  type = string
}
variable "ssh_key" {
  type = string
}
variable "loadbalancer_name" {
  type = string
}
variable "region" {
  type    = string
  default = "sgp1"
}
variable "tag_elb_master_name" {
  type = string
}
variable "master_size" {
  type = string
}
variable "master_name" {
  type    = string
  default = "talos-master"
}
variable "worker_size" {
  type = string
}
variable "worker_name" {
  type    = string
  default = "talos-worker"
}
variable "MASTER_COUNT" {
  type = number
}

variable "WORKER_COUNT" {
  type = number
}
variable "image_slug" {
  type = string
}