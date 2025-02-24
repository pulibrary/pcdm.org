variable "branch_or_sha" {
  type = string
  default = "main"
}
job "pcdm.org-staging" {
  region = "global"
  datacenters = ["dc1"]
  node_pool = "staging"
  type = "service"
  group "web" {
    count = 2
    network {
      port "http" { to = 3000 }
    }
    service {
      port = "http"
    }
    task "webserver" {
      driver = "podman"
      config {
        image = "ghcr.io/pulibrary/pcdm.org:${ var.branch_or_sha }"
        ports = ["http"]
        force_pull = true
      }
      resources {
        cpu    = 1000
        memory = 500
      }
    }
  }
}
