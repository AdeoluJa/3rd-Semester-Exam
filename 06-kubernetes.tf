
provider "kubectl" {
  host                   = data.aws_eks_cluster.eks_cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks_cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.eks_cluster.token
  #load_config_file       = false
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks_cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks_cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.eks_cluster.token
  #load_config_file       = false
}

#################################################################################################################################################################################################################################################################################################################

#################################################################################################################################################################################################################################################################################################################

# Create sockshop namespace
resource "kubernetes_namespace" "sockshop" {
  metadata {
    name = "sock-shop"
  }
  depends_on = [
    aws_eks_cluster.eks-cluster,
    aws_eks_node_group.node-1,
  ]
}

# Create webapp namespace
resource "kubernetes_namespace" "webapp" {
  metadata {
    name = "webapp"
  }
  depends_on = [
    aws_eks_cluster.eks-cluster,
    aws_eks_node_group.node-1,
  ]
}

# Create monitoring namespace
resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
  depends_on = [
    aws_eks_cluster.eks-cluster,
    aws_eks_node_group.node-1,
  ]
}

#################################################################################################################################################################################################################################################################################################################

#################################################################################################################################################################################################################################################################################################################

# Sock-shop Manifest
data "kubectl_path_documents" "sockshop" {
  pattern = "./sock-shop-manifests/*.yaml"
}

resource "kubectl_manifest" "sockshop" {
  count     = length(data.kubectl_path_documents.sockshop.documents)
  yaml_body = element(data.kubectl_path_documents.sockshop.documents, count.index)

  depends_on = [
    aws_eks_cluster.eks-cluster,
    aws_eks_node_group.node-1,
    kubernetes_namespace.sockshop,
  ]
}

#################################################################################################################################################################################################################################################################################################################

#################################################################################################################################################################################################################################################################################################################

# Monitoring Manifest
data "kubectl_path_documents" "monitoring" {
  pattern = "./manifests-monitoring/*.yaml"
  vars = {
    DS_PROMETHEUS = "DS_PROMETHEUS"
  }
}

resource "kubectl_manifest" "monitoring" {
  count     = length(data.kubectl_path_documents.monitoring.documents)
  yaml_body = element(data.kubectl_path_documents.monitoring.documents, count.index)

  depends_on = [
    aws_eks_cluster.eks-cluster,
    aws_eks_node_group.node-1,
    kubernetes_namespace.monitoring,
  ]
}

#################################################################################################################################################################################################################################################################################################################

#################################################################################################################################################################################################################################################################################################################

# Webapp Manifest
data "kubectl_path_documents" "webapp" {
  pattern = "./webapp-manifests/*.yaml"
}

resource "kubectl_manifest" "webapp" {
  count     = length(data.kubectl_path_documents.webapp.documents)
  yaml_body = element(data.kubectl_path_documents.webapp.documents, count.index)

  depends_on = [
    aws_eks_cluster.eks-cluster,
    aws_eks_node_group.node-1,
    kubernetes_namespace.webapp,
  ]

}

#################################################################################################################################################################################################################################################################################################################

#################################################################################################################################################################################################################################################################################################################

# Webapp Manifest
data "kubectl_path_documents" "grafana-import" {
  pattern = "./grafana-import/*.yaml"
}

resource "kubectl_manifest" "grafana-import" {
  count     = length(data.kubectl_path_documents.grafana-import.documents)
  yaml_body = element(data.kubectl_path_documents.grafana-import.documents, count.index)

  depends_on = [
    aws_eks_cluster.eks-cluster,
    aws_eks_node_group.node-1,
    kubernetes_namespace.monitoring,
    kubectl_manifest.monitoring,
  ]

}
