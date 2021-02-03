provider "kubernetes" {}

provider "aws" {
  region = "us-east-1"
}
//k8s deployment

resource "kubernetes_deployment" "wordpress-deploy" {

    metadata{
      name= "wordpress-deployment"
    }

    spec{
      replicas=2

      selector{
        match_expressions {
          key= "app"
          operator= "In"
          values= [ "wordpress" ]
        }
      }

      template{
        metadata{
          labels ={
            app= "wordpress"
          }
        }

        spec{
          container{
            name= "wordpress-con"
            image= "wordpress:4.8-apache"
            env{
              name= "WORDPRESS_DB_HOST"
              value= module.module_rds.wb_rds_output

            }
            env{
              name= "WORDPRESS_DB_PASSWORD"
              value= "123456789"

            }

            env{
              name= "WORDPRESS_DB_USER"
              value= "admin"

            }
          }
        }
      }

    }
}

// k8s service
resource "kubernetes_service" "wp_service" {

  metadata{
    name= "wordpress-service"
  }

  spec{
     selector = {
       app = "wordpress"
     }

    type= "NodePort"

    port{
      port= 80
      node_port= 30007
    }
  }

}

module "module_rds" {
  source = "./aws_rds"
}

output "aws_rds_address"{
  value=module.module_rds.wb_rds_output
}
