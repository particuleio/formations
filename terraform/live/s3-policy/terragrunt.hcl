include {
  path = "${find_in_parent_folders()}"
}

terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-iam//modules/iam-policy?ref=v2.3.0"
}

locals {
  aws_region  = "eu-west-3"
  env         = yamldecode(file("${get_terragrunt_dir()}/${find_in_parent_folders("common_tags.yaml")}"))["Env"]
  custom_tags = yamldecode(file("${get_terragrunt_dir()}/${find_in_parent_folders("common_tags.yaml")}"))
}

dependency "s3-bucket" {
  config_path = "../s3-bucket"

  mock_outputs = {
    this_s3_bucket_arn = "arn:aws:s3:::bucket"
  }
}

inputs = {

  aws = {
    "region" = local.aws_region
  }

  tags = merge(
    local.custom_tags
  )

  name        = "tf-particule-training-s3-user"
  path        = "/"
  description = "S3 policy for particule training bucket"

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowFullAccesstoS3",
            "Effect": "Allow",
            "Action": [
                "s3:*"
            ],
            "Resource": [
              "${dependency.s3-bucket.outputs.this_s3_bucket_arn}",
              "${dependency.s3-bucket.outputs.this_s3_bucket_arn}/*"
            ]
        }
    ]
}
POLICY
}
