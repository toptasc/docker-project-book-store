resource "aws_instance" "host-ec2" {
  ami             = "ami-0230bd60aa48260c6"
  instance_type   = var.ins-type
  key_name        = var.key
  user_data       = filebase64("${path.module}/userdata.sh")
  vpc_security_group_ids = [aws_security_group.docker-ec2-sec.id]
  tags = {
    Name = "Web server for books_db"
  }
  depends_on = [ github_repository_file.dataforapp ]
}

resource "github_repository" "repoforapp" {
  name       = "books-db"
  visibility = "private"
  auto_init = true
}

variable "files" {
  default = ["library-api.py", "docker-compose.yml", "Dockerfile", "requirements.txt"]
}
resource "github_repository_file" "dataforapp" {
  repository = github_repository.repoforapp.name
  for_each = toset(var.files)
  content = file(each.value)
  file = each.value
  overwrite_on_create = true
}

output "dns" {
  value = aws_instance.host-ec2.public_dns
}
resource "aws_security_group" "docker-ec2-sec" {

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}