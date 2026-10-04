terraform {
  required_version = "1.10.5"
  required_providers {
    aws = { source = "hashicorp/aws", version = "5.87.0" }
  }
}

variable "lingkungan" {
  type    = string
  default = "pengembangan"
}

variable "pawonee_recipe_api" {
  type        = string
  description = "API resep milik Pawonee yang dibaca backend Pedaree"
  default     = "https://api-pengembangan.pawonee.example.id"
}

resource "aws_db_instance" "pedaree" {
  identifier     = "pedaree-${var.lingkungan}"
  db_name        = "pedaree"
  engine         = "postgres"
  engine_version = "16.6"
  instance_class = "db.t4g.micro"
  allocated_storage = 20
}
