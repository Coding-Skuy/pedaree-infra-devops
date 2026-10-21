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
  default     = "https://api-pengembangan.pawonee.chefgenie.id/v1"
}

variable "kelas_instance" {
  type    = string
  default = "db.t4g.micro"
}

variable "retensi_cadangan_hari" {
  type        = number
  default     = 1
  description = "Hari retensi snapshot otomatis (staging/produksi >= 7)"
}

variable "lindungi_dari_hapus" {
  type    = bool
  default = false
}

# Satu DB per service: instans ini hanya memuat DB logis `pedaree`.
# Kata sandi master dikelola RDS di AWS Secrets Manager (tidak ada di state/repo/tfvars).
resource "aws_db_instance" "pedaree" {
  identifier                  = "pedaree-${var.lingkungan}"
  db_name                     = "pedaree"
  engine                      = "postgres"
  engine_version              = "16.6"
  instance_class              = var.kelas_instance
  allocated_storage           = 20
  username                    = "pedaree_admin"
  manage_master_user_password = true
  storage_encrypted           = true
  backup_retention_period     = var.retensi_cadangan_hari
  deletion_protection         = var.lindungi_dari_hapus
  skip_final_snapshot         = var.lingkungan == "pengembangan"
  final_snapshot_identifier   = var.lingkungan == "pengembangan" ? null : "pedaree-${var.lingkungan}-akhir"
}

output "db_secret_arn" {
  description = "ARN secret kata sandi master di Secrets Manager (gunakan untuk membuat pengguna aplikasi pedaree_app)"
  value       = aws_db_instance.pedaree.master_user_secret[0].secret_arn
}
