data "aws_secretsmanager_secret" "jfrog_token" {
  name = "devops/jfrog/token"
}

data "aws_secretsmanager_secret_version" "jfrog_token" {
  secret_id = data.aws_secretsmanager_secret.jfrog_token.id
}

resource "kubernetes_secret" "artifactory_registry_secret" {
  metadata {
    name      = "artifactory-registry-secret"
    namespace = "default"
  }

  type = "kubernetes.io/dockerconfigjson"

  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        (var.artifactory_server) = {
          "username" = var.artifactory_username
          "password" = data.aws_secretsmanager_secret_version.jfrog_token.secret_string
          "auth"     = base64encode("${var.artifactory_username}:${data.aws_secretsmanager_secret_version.jfrog_token.secret_string}")
        }
      }
    })
  }

  depends_on = [module.eks]
}
