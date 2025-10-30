variable "task_family" {
  description = "(optional) task family for task. This is effectively the name of the task, without qualification of revision"
  default     = null
  type        = string
}

variable "image_repo" {
  description = "(optional) image repo. e.g. image_repo = nginx --> nginx:image_tag"
  default     = "nginx"
  type        = string
}

variable "image_tag" {
  description = "(optional) tag of the image. e.g. image_tag = latest --> image_repo:latest"
  default     = "alpine"
  type        = string
}

variable "container_port" {
  description = "(optional) port the container is exposing"
  default     = 80
  type        = number
}

variable "container_definitions" {
  description = "(optional) JSON container definitions for task"
  default     = null
  type        = string
}

variable "container_name" {
  description = "(optional) name for the container to have"
  default     = null
  type        = string
}

variable "cpu_reservation" {
  description = "(optional) CPU reservation for task"
  default     = 256
  type        = number
}

variable "memory_reservation" {
  description = "(optional) memory reservation for task"
  default     = 512
  type        = number
}

variable "requires_compatibilities" {
  description = "(optional) capabilities that the task requires"
  default     = ["FARGATE"]
  type        = set(string)
}

variable "network_mode" {
  description = "(optional) network mode for the task"
  default     = "awsvpc"
  type        = string
}

variable "ssm_path" {
  description = "(optional) path to the ssm parameters you want pulled into your container during execution of the entrypoint"
  default     = null
  type        = string
}

variable "mesh_name" {
  description = "(optional) the name for the App Mesh this task is associated with. If null, ignored"
  default     = null
  type        = string
}

variable "virtual_node" {
  description = "(optional) the name of the virtual node associated with this task definition. Ignored if virtual_gateway set. If null, ignored"
  default     = null
  type        = string
}

variable "virtual_gateway" {
  description = "(optional) the name of the virtual gateway associated with this task definition. If null, ignored"
  default     = null
  type        = string
}

variable "envoy_tag" {
  description = "(optional) tag for envoy. Update periodically if using App Mesh."
  default     = "v1.23.1.0-prod"
  type        = string
}

variable "efs_mounts" {
  description = "(optional) efs mount set of objects. Components should include dns_name, container_mount_point, efs_mount_point"
  default     = []
  type = set(object({
    file_system_id = string
    efs_path       = string
    container_path = string
  }))
}

variable "env_vars" {
  description = "(optional) environment variables to be passed to the container. By default, only passes SSM_PATH"
  default     = null
  type        = set(map(any))
}


variable "secrets" {
  description = "(optional) secrets to be passed to the container. By default none is passed"
  default     = []
  type = set(object({
    name      = string
    valueFrom = string
  }))
}

variable "use_xray_sidecar" {
  description = "(optional) if set to null, will use the sidecar to trace the task if envoy is used, as that automatically implements tracing configs."
  default     = null
  type        = bool
}

variable "command" {
  description = "(optional) command to run in the container as an array. e.g. [\"sleep\", \"10\"]. If null, does not set a command in the task definition."
  default     = null
  type        = list(string)
}

variable "entrypoint" {
  description = "(optional) entrypoint to run in the container as an array. e.g. [\"sleep\", \"10\"]. If null, does not set an entrypoint in the task definition."
  default     = null
  type        = list(string)
}

variable "runtime_platform" {
  description = "(optional) Runtime platform for the task. Defaults to LINUX operating system family w/ CPU architecture x86_64."
  default = {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
  type = object({
    operating_system_family = optional(string, "LINUX")
    cpu_architecture        = optional(string, "X86_64")
  })
}

variable "log_group_name" {
  description = "(optional) name for the log group"
  default     = null
  type        = string
}

variable "log_group_class" {
  description = "(Optional) log class of the log group. Possible values are: STANDARD or INFREQUENT_ACCESS"
  default     = "INFREQUENT_ACCESS"
  type        = string
}

variable "retention_in_days" {
  description = "(optional) log retention in days"
  default     = 7
  type        = number
}

variable "awslogs_driver_mode" {
  description = "(optional) awslogs driver mode. Set this to `blocking` if you would rather have an outage than lose logs."
  default     = "non-blocking"
  type        = string
}

# Clowdwatch Application Signals
variable "enable_application_signals" {
  description = "(optional) if set to true, will enable CW Application Signals"
  default     = false
  type        = bool
}

variable "pythonpath" {
  description = "(optional) PYTHONPATH of the application; required by the cwagent sidecar container"
  type        = string

  default = ":"
}

variable "track_latest" {
  description = "(optional) Whether should track latest ACTIVE task definition on AWS or the one created with the resource stored in state."
  default     = false
  type        = bool
}

variable "lb_deregistration_delay" {
  description = "(optional) task deregistration delay for the load balancer"
  default     = 300
  type        = number
}