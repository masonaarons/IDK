variable "default-tags" {
  type = map(string)
  default = {
    "team" = "red"
  }
  description = "This is a resource in my terraform testing environment"
}