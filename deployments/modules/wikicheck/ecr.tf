resource "aws_ecr_repository" "ecr" {
  name = "${var.name}-sf-tech-test"
}

resource "aws_ecr_repository" "ecr_db" {
  name = "${var.name}-sf-tech-test-db"
}
