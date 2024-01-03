locals {
  s3_names = {
    test-bucket = {
      name = "opsfleet-sdaf2",
    },
  }
}


module "s3" {
  source = "../../modules/s3"

  for_each = local.s3_names

  bucket_name    = each.value["name"]
  aws_account_id = var.aws_account_id
  versioning     = try(each.value["versioning"], "Disabled")

  tags = var.tags["gitlab"]

}