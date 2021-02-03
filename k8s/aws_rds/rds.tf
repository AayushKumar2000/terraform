resource "aws_db_instance" "wb_rds" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.6"
  instance_class       = "db.t2.micro"
  name                 = "wordpressdb"
  username             = "admin"
  password             = "123456789"
  publicly_accessible  = "true"
  
  final_snapshot_identifier= "wb-rds"
  // or skip_final_snapshot="true"
}


output "wb_rds_output" {
  value= aws_db_instance.wb_rds.address
}
