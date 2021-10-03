variable "kubeconfig" {
    type = string
    description = "The kubeconfig file from the AKS cluster."
}

variable "actions_runner_namespace" {
    type = string
    description = "The namespace Github Actions runners will be deployed to."
}
