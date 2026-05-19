terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.4"
    }
  }

  cloud {

    organization = "hiephaohan"

    // workspace for dev environment
    workspaces {
      name = "vti-assignment-aws-2601"
    }
  }
}