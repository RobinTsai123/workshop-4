# Pull Docker images
resource "docker_image" "bgg_database" {
  name         = "chukmunnlee/bgg-database:v3.1"
  keep_locally = false
}

resource "docker_image" "bgg_backend" {
  name         = "chukmunnlee/bgg-backend:v3"
  keep_locally = false
}

# Create Docker network
resource "docker_network" "bgg_net" {
  name = "my-bgg-net"
}

# Create Docker volume
resource "docker_volume" "data_vol" {
  name = "my-data-vol"
}

# MySQL Database Container
resource "docker_container" "bgg_database" {
  name  = "my-bgg-database"
  image = docker_image.bgg_database.image_id

  networks_advanced {
    name = docker_network.bgg_net.id
  }

  volumes {
    volume_name    = docker_volume.data_vol.name
    container_path = "/var/lib/mysql"
  }

  ports {
    internal = 3306
    external = 3306
  }
}

# Backend Containers (3 replicas)
resource "docker_container" "bgg_backend" {
  count = 3
  name  = "my-bgg-backend-${count.index}"
  image = docker_image.bgg_backend.image_id

  networks_advanced {
    name = docker_network.bgg_net.id
  }

  env = [
    "BGG_DB_USER=root",
    "BGG_DB_PASSWORD=changeit",
    "BGG_DB_HOST=${docker_container.bgg_database.name}"
  ]

  ports {
    internal = 3000
    external = 3000 + count.index
  }

  depends_on = [docker_container.bgg_database]
}

# Generate Nginx configuration
resource "local_file" "nginx_conf" {
  filename = "nginx.conf"
  content  = templatefile("${path.module}/nginx.conf.tftpl", {
    docker_host = var.docker_host
    ports       = docker_container.bgg_backend[*].ports[0].external
  })
}

output "backend_ports" {
  value = docker_container.bgg_backend[*].ports[0].external
}

output "database_container" {
  value = docker_container.bgg_database.name
}
