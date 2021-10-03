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
        name: actions-runner-deployment
        namespace: actions-runner-system
      spec:
        template:
          metadata:
            annotations:
              cluster-autoscaler.kubernetes.io/safe-to-evict: "true"
          spec:
            organization: teokyllc
            image: johndvs/actions-runner:v2.283.2-ubuntu-20.04
            imagePullPolicy: IfNotPresent
            tolerations:
              - key: "node.kubernetes.io/unreachable"
                operator: "Exists"
                effect: "NoExecute"
                tolerationSeconds: 10
            ephemeral: true
            dockerEnabled: true
            dockerRegistryMirror: https://mirror.gcr.io/
            dockerdWithinRunnerContainer: false
            workDir: /home/runner/work
      ---
      apiVersion: actions.summerwind.dev/v1alpha1
      kind: HorizontalRunnerAutoscaler
      metadata:
        name: runner-deployment-autoscaler
        namespace: actions-runner-system
      spec:
        scaleTargetRef:
          name: actions-runner-deployment
        minReplicas: 1
        maxReplicas: 10
        metrics:
        - type: PercentageRunnersBusy
          scaleUpThreshold: '0.75'    # The percentage of busy runners at which the number of desired runners are re-evaluated to scale up
          scaleDownThreshold: '0.3'   # The percentage of busy runners at which the number of desired runners are re-evaluated to scale down
          scaleUpAdjustment: 2        # The scale up runner count added to desired count
          scaleDownAdjustment: 1      # The scale down runner count subtracted from the desired count
      EOF
    EOT
  }
}
