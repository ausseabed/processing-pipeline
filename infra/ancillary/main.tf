#----ancillary/main.tf

resource "aws_ecr_repository" "callcarisbatch" {
  name = "callcarisbatch"
  image_tag_mutability = "MUTABLE"
  tags = {
       Name = "tf_ecr"
  }
} 