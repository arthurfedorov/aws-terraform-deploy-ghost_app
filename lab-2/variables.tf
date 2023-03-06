variable "your_ip" {
  type = string
  description = "IP address in CIDR notation (/32)"

  validation {
    condition = can(cidrhost(var.your_ip, 0))
    error_message = "Invalid IP address. Must be in CIDR notation (/32)"
  }
}