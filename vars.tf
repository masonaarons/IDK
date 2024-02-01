variable "default-tags" {
  type = map(string)
  default = {
    "owner" = "kmackey"
    "team" = "red"
  }
  description = "This is a resource in my terraform testing environment"
}