output "endpoint" {
  value = "${aws_eks_cluster.kubernetes.endpoint}"
}

output "kubeconfig-certificate-authority-data" {
  value = "${aws_eks_cluster.kubernetes.certificate_authority.0.data}"
}
