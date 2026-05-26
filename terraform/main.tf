terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
  required_version = ">= 1.0"
}

provider "docker" {}

# Pull de nginx image van Docker Hub
resource "docker_image" "nginx" {
  name         = "nginx:latest"
  keep_locally = true
}

# Start een nginx container
resource "docker_container" "nginx" {
  name  = "demo-nginx"
  image = docker_image.nginx.image_id

  ports {
    internal = 80
    external = 8080
  }

  # Custom welkomstpagina via een label (voor de demo)
  labels {
    label = "demo"
    value = "terraform-cicd"
  }
}

# Output: URL waar nginx bereikbaar is
output "nginx_url" {
  value       = "http://localhost:${docker_container.nginx.ports[0].external}"
  description = "URL van de nginx-container"
}
