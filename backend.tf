terraform {
  backend "s3" {
    bucket  = "tf-state-dcuk074-its-deloittecloud-co-uk-dev"
    key     = "tf_jenkins_tfstate"
    encrypt = true
    region  = "eu-west-1"
  }
}
