### Digitalocean Talos
### variables
#### terraform.tfvars
```
do_token            = "change me"
ssh_key             = "change me"
region              = "sgp1"
loadbalancer_name   = "talos-elb"
tag_elb_master_name = "talos-control-plane"
image_id            = "146722313"
MASTER_COUNT        = 2
master_size         = "s-2vcpu-4gb"
WORKER_COUNT        = 2
worker_size         = "s-2vcpu-4gb"




```
#### upload image
```
- download DigitalOcean image digital-ocean-amd64.raw.gz
- upload custom image and get id
```