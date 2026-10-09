variable "project-name" {
  type        = string
  description = "The name of the project"
}

variable "db_password" {
  type        = string
  sensitive   = true
  ephemeral   = true
  description = "The password for the PostgreSQL database"
}

variable "django_secret_key" {
  type        = string
  sensitive   = true
  ephemeral   = true
  description = "The secret key for the Django application"
}

variable "tmdb_api_key" {
  type        = string
  sensitive   = true
  ephemeral   = true
  description = "The API key for The Movie Database (TMDB)"
}