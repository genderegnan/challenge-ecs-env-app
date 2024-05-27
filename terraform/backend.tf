# where to save Terraform state file
terraform {
  backend "s3" {
    bucket = "tranque-terraform-state"
    key    = "ecs-dev/terraform.tfstate"
    region = "us-east-1"
  }
}