# Download Terraform
Download the Terraform Windows Binary (.zip) from below 👇 Official Link 👇
Download Terraform - Terraform by HashiCorp
Download Terraform
- Terraform by HashiCorp Download Terraformwww.terraform.io
- 
# Unzipping Terraform
Moving the terraform.exe to a directory included in your system’s PATH.
😘 Putting terraform.exe into system’s PATH, you can run it any directory. Otherwise, you can only run terraform in Download Folder
## Procedure 1. Getting your system’s PATH
Right-click Windows Icon
Click Advanced system settings
Click Environment Variables…
Select Path in System variables
Click Edit…

## Procedure 2. Moving the terraform.exe to system’s PATH
In this case, I copy terraform.exe, paste it in C:\Windows\System32

# Verify Terraform version
`terraform version`

# (Optional) SHA256 checksums for Terraform 1.1.0
verify the SHA256 checksum of the file to ensure its integrity.
Using `curl` to get the original checksum value for integrity
`(curl https://releases.hashicorp.com/terraform/1.1.0/terraform_1.1.0_SHA256SUMS).content`
Using `certutil.exe` to get the hash value of terraform.zip
`certutil.exe -hashfile .\terraform_1.1.0_windows_amd64.zip sha256`

The generated checksum matches with the original checksum
# References
[link]Download Terraform - Terraform by HashiCorp
Download Terraform
- Terraform by HashiCorp Download Terraformwww.terraform.i
Install Terraform | Terraform - HashiCorp Learn
To use Terraform you will need to install it. HashiCorp distributes Terraform as a binary package. You can also install…
learn.hashicorp.com
# Special Thanks 😘 to https://terminalizer.com
Recording terminal and generate amazing animated gif
