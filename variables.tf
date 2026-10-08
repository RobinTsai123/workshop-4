variable "do_token" {
  description = "DigitalOcean API token"
  type        = string
  sensitive   = true
}

variable "docker_host" {
  description = "Docker host IP address"
  type        = string
}

variable "docker_cert_path" {
  description = "Path to Docker certificates"
  type        = string
}

variable "mysql_root_password" {
  description = "MySQL root password"
  type        = string
  sensitive   = true
}

variable "mysql_db_name" {
  description = "MySQL database name"
  type        = string
  default     = "boardgamedb"
}

variable "backend_count" {
  description = "Number of backend containers"
  type        = number
  default     = 3
}
