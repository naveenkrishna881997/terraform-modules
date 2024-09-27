variable "amiid" {
  default = "ami-08e5424edfe926b43"
}

variable "type" {
  default = "t2.micro"
}

variable "pemfile" { 
  default = "master"
}

variable "volsize" {
  type = number
  default = 8
}

variable "servername" {
  default = "demoserver"
}
