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
      kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.5.3/cert-manager.yaml
      sleep 180
      helm repo add actions-runner-controller https://actions-runner-controller.github.io/actions-runner-controller
      helm upgrade --install actions-runner-controller actions-runner-controller/actions-runner-controller \
        --namespace "${var.actions_runner_namespace}" \
        --create-namespace \
        --values runners-values.yaml \
        --wait
        
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
        namespace: ${var.actions_runner_namespace}
      spec:
        replicas: 1
        organization: teokyllc
      EOF
    EOT
  }
}
