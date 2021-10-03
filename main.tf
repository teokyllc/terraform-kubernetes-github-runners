resource "null_resource" "setup_env" { 
  provisioner "local-exec" { 
    command = <<-EOT
      mkdir ~/.kube || echo "~/.kube already exists"
      echo "${var.kubeconfig}" > ~/.kube/config
    EOT
  }
}

resource "null_resource" "deploy_actions_runner_controller" {
  depends_on = [null_resource.setup_env]
  provisioner "local-exec" {
    command = <<-EOT
      helm upgrade --install \
        --namespace actions-runner-system \
        --create-namespace \
        --values runners-values.yaml \
        --wait \
        actions-runner-controller actions-runner-controller/actions-runner-controller
    EOT
  }
}

resource "null_resource" "deploy_actions_runner_deployment" {
  depends_on = [null_resource.deploy_actions_runner_controller]
  provisioner "local-exec" {
    command = <<-EOT
      cat <<EOF | kubectl apply -f -
      apiVersion: actions.summerwind.dev/v1alpha1
      kind: RunnerDeployment
      metadata:
        name: teokyllc-runner-deployment
        namespace: actions-runner-system
      spec:
        replicas: 1
        organization: teokyllc
      EOF
    EOT
  }
}
