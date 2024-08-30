1.First we create an S3 bucket by defining it in terraform conf file





resource "aws_s3_bucket" "annotest" {
  bucket = "annotest-example-bucket"
  acl    = "public-read"

  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}

resource "aws_s3_bucket_object" "index" {
  bucket = aws_s3_bucket.annotest.bucket
  key    = "index.html"
  source = "path/to/index.html"
  acl    = "public-read"
}

resource "aws_s3_bucket_object" "error" {
  bucket = aws_s3_bucket.annotest.bucket
  key    = "error.html"
  source = "path/to/error.html"
  acl    = "public-read"
}


output "website_url" {
  value = aws_s3_bucket.annotest.website_endpoint
}

and then:

terraform init
terraform apply


Worked succesfully


2.  We add all the required information to terraform configuration file

the vpc

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}




creating private subnets

resource "aws_subnet" "private_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-west-2a"
}

resource "aws_subnet" "private_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-west-2b"
}

resource "aws_subnet" "private_3" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-west-2c"
}




creating nat gateway


resource "aws_eip" "nat" {
  vpc = true
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id
}


creating route tables for private subnets

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
}

resource "aws_route_table_association" "private_1" {
  subnet_id      = aws_subnet.private_1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_2" {
  subnet_id      = aws_subnet.private_2.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_3" {
  subnet_id      = aws_subnet.private_3.id
  route_table_id = aws_route_table.private.id
}

and

terraform init
terraform apply




3.

I will create docker in docker yaml located in the dind subfolder:

version: '3.8'

services:
  dind:
    image: docker:20.10.7-dind
    privileged: true
    environment:
      DOCKER_TLS_CERTDIR: ""
    volumes:
      - dind-storage:/var/lib/docker
    ports:
      - "2375:2375"

volumes:
  dind-storage:


I will update the main docker compose file so it uses dind

version: "3.8"

#networks:
#  default:
#    name: localstack-net

services:
  tfrunner:
    build:
      context: ./tfrunner/
      dockerfile: ./Dockerfile
    container_name: tfrunner-cnt
    tty: true
    volumes:
      - type: bind
        source: ./terraform
        target: /mnt/terraform
  localstack:
    image: localstack/localstack
    environment:
      - DOCKER_HOST=tcp://dind:2375
    ports:
      - "4566:4566"
      - "4571:4571"
    depends_on:
      - dind

  dind:
    image: docker:20.10.7-dind
    privileged: true
    environment:
      DOCKER_TLS_CERTDIR: ""
    volumes:
      - dind-storage:/var/lib/docker
    ports:
      - "2375:2375"

volumes:
  dind-storage:
  
  
  
  
  
  