variable "do_token" {
  type = string
}
variable "ssh_key" {
  type = string
}
variable "user" {
  description = "user for ssh"
  type        = string
  default     = "root"
}
variable "region" {
  type    = string
  default = "sgp1"
}
variable "master_size" {
  type = string
}
variable "master_name" {
  type    = string
  default = "k8s-master"
}
variable "worker_size" {
  type = string
}
variable "worker_name" {
  type    = string
  default = "k8s-worker"
}
variable "MASTER_COUNT" {
  type    = number
  default = 1
}

variable "WORKER_COUNT" {
  type = number
}
variable "image_slug" {
  type = string
}
variable "domain_name" {
  type = string
}
