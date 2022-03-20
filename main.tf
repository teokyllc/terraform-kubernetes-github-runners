resource "kubernetes_namespace" "action_runner_ns" {
  metadata {
    name = var.actions_runner_namespace
  }
}

resource "helm_release" "runners_controller" {
  name       = "actions-runner-controller"
  repository = "https://actions-runner-controller.github.io/actions-runner-controller"
  chart      = "actions-runner-controller"
  namespace  = kubernetes_namespace.action_runner_ns.name
  values     = [
    "${file(var.gh_actiones_values_filename)}"
  ]
}

# resource "kubernetes_manifest" "actions_runner_deployment" {
#   depends_on = [helm_release.runners_controller]
#   manifest = {
#     "apiVersion" = "actions.summerwind.dev/v1alpha1"
#     "kind" = "RunnerDeployment"
#     "metadata" = {
#       "name" = "actions-runner-deployment"
#       "namespace" = "${kubernetes_namespace.action_runner_ns.name}"
#     }
#     "spec" = {
#       "template" = {
#         "metadata" = {
#           "annotations" = {
#             "cluster-autoscaler.kubernetes.io/safe-to-evict" = "true"
#           }
#         }
#         "spec" = {
#           "dockerEnabled" = "${var.docker_enabled}"
#           "dockerdWithinRunnerContainer" = "${var.docker_enabled_in_runner_container}"
#           "ephemeral" = "${var.ephemeral}"
#           "image" = "${var.container_registry}/${var.container_image}:${var.container_tag}"
#           "imagePullPolicy" = "IfNotPresent"
#           "organization" = "${var.github_org}"
#           "tolerations" = [
#             {
#               "effect" = "NoExecute"
#               "key" = "node.kubernetes.io/unreachable"
#               "operator" = "Exists"
#               "tolerationSeconds" = 10
#             },
#           ]
#           "workDir" = "/home/runner/work"
#         }
#       }
#     }
#   }
# }

# resource "kubernetes_manifest" "horizontalrunnerautoscaler_actions_runner_system_runner_deployment_autoscaler" {
#   manifest = {
#     "apiVersion" = "actions.summerwind.dev/v1alpha1"
#     "kind" = "HorizontalRunnerAutoscaler"
#     "metadata" = {
#       "name" = "runner-deployment-autoscaler"
#       "namespace" = "actions-runner-system"
#     }
#     "spec" = {
#       "maxReplicas" = 10
#       "metrics" = [
#         {
#           "scaleDownAdjustment" = 1
#           "scaleDownThreshold" = "0.3"
#           "scaleUpAdjustment" = 2
#           "scaleUpThreshold" = "0.75"
#           "type" = "PercentageRunnersBusy"
#         },
#       ]
#       "minReplicas" = 1
#       "scaleTargetRef" = {
#         "name" = "actions-runner-deployment"
#       }
#     }
#   }
# }