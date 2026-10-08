resource "aws_ecr_repository" "image_repository" {
  name                 = "${var.project-name}-ecr"
  force_delete         = true
  image_tag_mutability = "IMMUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
}