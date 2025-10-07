# tags.tf
# Centralized tagging configuration for all resources

locals {
  common_tags = {
    Class = "cs18"
    Assignment = "Homework3"
    ManagedBy   = "Terraform"
  }
}

