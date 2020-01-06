include {
  path = "${find_in_parent_folders()}"
}

terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-iam//modules/iam-user?ref=v2.3.0"
}

locals {
  aws_region  = "eu-west-3"
  env         = yamldecode(file("${get_terragrunt_dir()}/${find_in_parent_folders("common_tags.yaml")}"))["Env"]
  custom_tags = yamldecode(file("${get_terragrunt_dir()}/${find_in_parent_folders("common_tags.yaml")}"))
}

dependency "s3-policy" {
  config_path = "../s3-policy"

  mock_outputs = {
    arn = "arn:aws:iam::000000000000:policy/policy"
  }
}

inputs = {

  aws = {
    "region" = local.aws_region
  }

  tags = merge(
    local.custom_tags
  )

  name                          = "tf-particule-training-s3-user"
  force_destroy                 = true
  create_iam_user_login_profile = false
  create_iam_access_key         = true
  policy                        = dependency.s3-policy.outputs.arn
}
