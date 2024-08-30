resource "aws_s3_bucket" "s3_bucket" {
  bucket        = var.bucket
  force_destroy = var.force_destroy
  tags = merge(var.tags, {
    Name = var.bucket
  })
}

resource "aws_s3_bucket_versioning" "s3_bucket_versioning" {
  bucket = aws_s3_bucket.s3_bucket.id
  versioning_configuration {
    status = var.versioning_configuration.enabled ? "Enabled" : "Disabled"
  }
}

resource "aws_s3_bucket_public_access_block" "public_access_block" {
  bucket                  = aws_s3_bucket.s3_bucket.id
  block_public_acls       = var.public_access_block.acls
  block_public_policy     = var.public_access_block.policy
  ignore_public_acls      = var.public_access_block.acls
  restrict_public_buckets = var.public_access_block.buckets
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3_encryption" {
  count  = var.encryption_configuration.enabled == true ? 1 : 0
  bucket = aws_s3_bucket.s3_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = var.encryption_configuration.sse_algorithm
    }
  }
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  count  = length(var.policies)
  bucket = aws_s3_bucket.s3_bucket.id
  policy = var.policies[count.index]
}




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











resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}


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


resource "aws_eip" "nat" {
  vpc = true
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id
}


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
