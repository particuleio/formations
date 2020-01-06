include {
  path = "${find_in_parent_folders()}"
}

terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-s3-bucket?ref=v1.0.0"
}

locals {
  aws_region  = "eu-west-3"
  env         = yamldecode(file("${get_terragrunt_dir()}/${find_in_parent_folders("common_tags.yaml")}"))["Env"]
  custom_tags = yamldecode(file("${get_terragrunt_dir()}/${find_in_parent_folders("common_tags.yaml")}"))
}

inputs = {

  aws = {
    "region" = local.aws_region
  }

  tags = merge(
    local.custom_tags
  )

  bucket = "particule-training"
  acl    = "public"

  cors_rule = {
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
    allowed_headers = ["*"]
  }

  versioning = {
    enabled = true
  }

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm     = "AES256"
        kms_master_key_id = null
      }
    }
  }

  website = {
    index_document = "index.html"
  }

  policy = <<POLICY
{
  "Version":"2012-10-17",
  "Statement":[
    {
      "Sid":"PublicRead",
      "Effect":"Allow",
      "Principal": "*",
      "Action":["s3:GetObject"],
      "Resource":["arn:aws:s3:::particule-training/*"]
    }
  ]
}
POLICY
}
