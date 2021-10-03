resource "null_resource" "setup_env" { 
  provisioner "local-exec" { 
    command = <<-EOT
      mkdir ~/.kube || echo "~/.kube already exists"
      echo "${var.aks_kubeconfig}" > ~/.kube/config
    EOT
  }
}

resource "null_resource" "configure_cert_manager" {
  depends_on = [null_resource.setup_env]
  provisioner "local-exec" {
    command = <<-EOT
      kubectl create namespace ${var.cert_manager_namespace}
      helm repo add jetstack https://charts.jetstack.io
      helm repo update
      helm install cert-manager jetstack/cert-manager \
        --namespace ${var.cert_manager_namespace} \
        --version ${var.cert_manager_version} \
        --set installCRDs=true \
        --set image.repository=${var.image_path} \
        --set image.tag=${var.image_tag} \
        --set image.replicaCount=${var.replicas} \
        --set global.imagePullSecrets[0].name="artifactory-access" \
        --set serviceAccount.name=${var.service_account_name} \
        --set webhook.image.repository=${var.webhook_image_path} \
        --set webhook.image.tag=${var.webhook_image_tag} \
        --set webhook.serviceType="ClusterIP" \
        --set cainjector.image.repository=${var.cainjector_image_path} \
        --set cainjector.image.tag=${var.cainjector_image_tag}    
    EOT
  }
}
