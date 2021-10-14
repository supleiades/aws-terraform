variable "amis" {
  type = map(any)
  default = {
    ap-northeast-1 = "ami-0701e21c502689c31" # AmazonLinux2
  }
}

variable "aws_region" {
  default = "ap-northeast-1"
}

variable "key_pair_filepath" {
    default = "~/.ssh/dev-key.pub"
}