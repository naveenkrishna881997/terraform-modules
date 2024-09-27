#------------------
# Create EC2 Server
#------------------
resource "aws_instance" "server" {
   ami           = var.amiid
   instance_type = var.type
   key_name      = var.pemfile
  
   root_block_device {
       volume_size = var.volsize
   }
   associate_public_ip_address = true

   tags = {
        Name = "${var.servername} - WEZVATECH"
    }

}
