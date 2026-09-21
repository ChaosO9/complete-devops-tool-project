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
          "password" = local.jfrog_token
          "auth"     = base64encode("${var.artifactory_username}:${local.jfrog_token}")
        }
      }
    })
  }

  depends_on = [module.eks]
}

locals {
  jfrog_token = jsondecode(data.aws_secretsmanager_secret_version.jfrog_token.secret_string)["JFROG_TOKEN"]
}
