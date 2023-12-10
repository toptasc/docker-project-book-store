provider "aws" {
  # Configuration options
  region = "us-east-1"
}

provider "github" {
  # Configuration options
  token = var.git-token
}