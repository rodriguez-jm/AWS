vpc_Name                                 = "Terraform-Test-VPC"
private_Subnet_Cidr_Block                = "10.0.0.0/24"
private_Subnet_Name                      = "Private-Subnet-01"
private_Subnet_Vm_Ami                    = "ami-0022f774911c1d690"
private_Subnet_Vm_Name                   = "Private-Subnet-Linux-VM"
private_To_Internet_Route_Table_Name_Tag = "Route-To-internet"
public_Subnet_Cidr_Block                 = "10.0.10.0/24"
public_Subnet_Name                       = "Public-NAT-Instance-Subnet"
nat_Instance_Private_Ip                  = "10.0.10.69"
nat_Instance_Name                        = "NAT-Instance"
nat_Instance_Ami                         = "ami-0022f774911c1d690"
ec2_Connect_Ip_Range                     = "18.206.107.24/29"
#Replace with valid IP
my_Ip                                    = "1.1.1.1/32"