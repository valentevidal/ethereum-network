


variable "ssh_private_key_path" {
  description = "The path to the private key for SSH access"
  type        = string
}

variable "genesis_file_path" {
  description = "Path to the genesis file"
  type        = string
}

variable "password_file_path" {
  description = "Path to the password file"
  type        = string
}

variable "keystore_file_path" {
  description = "Path to the keystore file"
  type        = string
}

variable "keystore_file_name" {
  description = "Filename for the keystore"
  type        = string
}

variable "service_file_path" {
  description = "Path to the ethnode.service file"
  type        = string
}
