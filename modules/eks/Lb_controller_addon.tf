
# ==============================================================================
# EKS POD IDENTITY FOR AWS LOAD BALANCER CONTROLLER
# ==============================================================================
module "lb_controller_pod_identity" {
  # This tells Terraform to dynamically stream the blueprint from the public registry
  source  = "terraform-aws-modules/eks-pod-identity/aws"
  version = "~> 1.0"

  name = "${var.environment}-${var.application}-aws-lb-controller"

  # OPTIMIZED: Uses the module's built-in flag instead of hardcoding raw ARNs
  attach_aws_lb_controller_policy = true 

  # Creates the logical cloud bridge mapping between AWS and your cluster pod
  associations = {
    lb_controller = {
      cluster_name    = module.eks.cluster_name
      namespace       = "kube-system"
      service_account = "aws-load-balancer-controller"
    }
  }
}

resource "helm_release" "aws_lb_controller" {
  name       = "aws-load-balancer-controller"
  
  # FIXED: Pointing to the real official AWS EKS Helm repository
  repository = "https://aws.github.io/eks-charts" 
  chart      = "aws-load-balancer-controller"
  
  namespace  = "kube-system"
  version    = "1.7.2" # Double check artifacthub.io for the latest version

  set = [
    {
    name  = "clusterName"
    value = module.eks.cluster_name
    },

    {
    name  = "serviceAccount.create"
    value = "true"
    },

    {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
    }
  ]
  
  depends_on = [module.eks, module.lb_controller_pod_identity]
}
