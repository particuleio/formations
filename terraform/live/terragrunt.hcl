remote_state {
  backend = "s3"

  config = {
    bucket         = "particule-tf-state-store-training-eu-west-3"
    key            = "${path_relative_to_include()}"
    region         = "eu-west-3"
    encrypt        = true
    dynamodb_table = "particule-tf-state-store-lock-training-eu-west-3"
  }
}
