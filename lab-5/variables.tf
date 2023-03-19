variable "your_ip" {
  type        = string
  description = "IP address in CIDR notation (/32)"

  validation {
    condition     = can(cidrhost(var.your_ip, 0))
    error_message = "Invalid IP address. Must be in CIDR notation (/32)"
  }
}

variable "ghost_app_image" {
  type        = string
  description = "Version of docker image, example - 'amd64/ghost'"
  default     = "amd64/ghost"
}

variable "ghost_app_image_version" {
  type        = string
  description = "Version of docker image, example - '4.12.1'"
  default     = "4.12.1"
}
