variable "actions_runner_namespace" {
    type = string
    description = "The namespace Github Actions runners will be deployed to."
}

variable "values_filename" {
    type = string
    description = "The filename for values.yaml."
}

variable "docker_enabled" {
    type = bool
    description = "Enables using docker on runner container."
}

variable "docker_enabled_in_runner_container" {
    type = bool
    description = "Enables using docker inside runner container vs using a sidecar."
}

variable "ephemeral" {
    type = bool
    description = "Runner container is ephemeral and stops after a single run."
}

variable "container_registry" {
    type = string
    description = "The container registry with the runner image."
}

variable "container_image" {
    type = string
    description = "The docker image name."
}

variable "container_tag" {
    type = string
    description = "The docker image tag."
}

variable "github_org" {
    type = string
    description = "The Github org the runners will serve."
}