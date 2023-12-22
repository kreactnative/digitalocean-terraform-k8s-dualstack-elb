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
variable "image_id" {
  type = string
}
variable "worker_size" {
  type = string
}
variable "MASTER_COUNT" {
  description = "Number of masters to create (Should be an odd number)"
  type        = number
}

variable "WORKER_COUNT" {
  description = "Number of workers to create"
  type        = number
}