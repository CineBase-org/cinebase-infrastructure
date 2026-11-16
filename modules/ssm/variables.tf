variable "project-name" {
  type        = string
  description = "The name of the project"
}

variable "domain_name" {
  description = "Base domain name for CineBase"
  type        = string
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

variable "stripe_secret_key" {
  type        = string
  sensitive   = true
  ephemeral   = true
  description = "The secret key for Stripe"
}

variable "stripe_webhook_secret" {
  type        = string
  sensitive   = true
  ephemeral   = true
  description = "The webhook secret for Stripe"
}

variable "stripe_price_id" {
  type        = string
  sensitive   = true
  ephemeral   = true
  description = "The price ID for Stripe"
}