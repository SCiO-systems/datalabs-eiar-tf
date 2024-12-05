resource "aws_eks_cluster" "eks-cluster" {
  name    = var.name
  role_arn        = aws_iam_role.eks_role.arn
  version = "1.31"

  vpc_config {
    subnet_ids              = var.private_subnets
    security_group_ids      = [aws_security_group.eks_sg.id]
    endpoint_private_access = true
  }

  depends_on = [
    aws_iam_role.eks_role
  ]

  tags = {
    Product = "Datalabs"
    Customer = "${var.customer}"
    ServerID = "d-server-02d1uqqpjnjums"
  }
}

resource "aws_eks_node_group" "eks_node_group" {
  for_each = { for idx, ng in var.node_groups : idx => ng }

  cluster_name    = var.name
  node_group_name = "${aws_eks_cluster.eks-cluster.name}-eks-worker-nodes-${each.key}"
  node_role_arn   = aws_iam_role.eks_worker_nodes_role.arn
  subnet_ids      = var.private_subnets[*]
  instance_types  = each.value.instance_types
  disk_size       = each.value.disk_size

  scaling_config {
    desired_size = each.value.desired_size
    max_size     = each.value.max_size
    min_size     = each.value.min_size
  }

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  ]
}

resource "aws_security_group" "eks_sg" {
  name_prefix = "${var.name}-eks-sg"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Product = "Datalabs"
    Customer = "${var.customer}"
  }
}

resource "aws_iam_role" "eks_role" {
  name = "${var.name}-eks_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  role       = aws_iam_role.eks_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role" "eks_worker_nodes_role" {
  name = "${var.name}-eks-worker-nodes-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  role       = aws_iam_role.eks_worker_nodes_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  role       = aws_iam_role.eks_worker_nodes_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  role       = aws_iam_role.eks_worker_nodes_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}