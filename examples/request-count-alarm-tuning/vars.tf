variable "hosted_zone" {
  type        = string
  description = "Primary hosted zone for this service. Populate `TF_VAR_hosted_zone` before running any tests to have this value populated."
}
