resource "null_resource" "setup_env" { 
  provisioner "local-exec" { 
    command = <<-EOT
      mkdir ~/.kube || echo "~/.kube already exists"
      (echo "${var.kubeconfig}" > ~/.kube/config
    EOT
  }
}

resource "null_resource" "deploy_actions_runner_controller" {
  depends_on = [null_resource.setup_env]
  provisioner "local-exec" {
    command = <<-EOT
      wget https://releases.hashicorp.com/vault/1.8.3/vault_1.8.3_linux_amd64.zip
      
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
