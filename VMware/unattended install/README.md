Install VMware ESXi 7 automatically with script (ks_cust.cfg)
===============================
***Step-by-step guide on create an Installer ISO Image with a Custom Installation Script***


# 1. Download Terraform

Download the Terraform Windows Binary (.zip) from below 👇 Official Link 👇

[Official Download Terraform](https://www.terraform.io/downloads.html)

---

# 2. Unzipping Terraform
Moving the terraform.exe to a directory included in your system’s `PATH`.

😘 Putting terraform.exe into system’s `PATH`, you can run it any directory. 

Otherwise, you can only run terraform in Download Folder

## Procedure 1. Getting your system’s PATH

1. Right-click Windows Icon

2. Click Advanced system settings

3. Click Environment Variables…

4. Select Path in System variables

5. Click Edit…

![Untitled](https://user-images.githubusercontent.com/67352969/145761191-c365645f-ecee-47ec-bc8a-ad49e74b0b32.png)

## Procedure 2. Moving the terraform.exe to system’s PATH

In this case, I copy terraform.exe, paste it in C:\Windows\System32

![Screenshot 2021-12-13 at 12 07 39 PM](https://user-images.githubusercontent.com/67352969/145761309-466027fb-be7b-48dd-b1e6-929a5d8772b6.png)

---

# 3. Verify Terraform version

`terraform version`

![render1639369127325](https://user-images.githubusercontent.com/67352969/145761361-89dfc140-ccf2-46a0-9832-fd521a059875.gif)

---

# 4. (Optional) SHA256 checksums for Terraform 1.1.0

verify the SHA256 checksum of the file to ensure its integrity.

Using `curl` to get the original checksum value for integrity

`(curl https://releases.hashicorp.com/terraform/1.1.0/terraform_1.1.0_SHA256SUMS).content`

Using `certutil.exe` to get the hash value of terraform.zip

`certutil.exe -hashfile .\terraform_1.1.0_windows_amd64.zip sha256`

![Screenshot 2021-12-13 at 12 40 03 PM](https://user-images.githubusercontent.com/67352969/145761396-0f150c58-fc46-4025-b8eb-19aaada045d5.png)

The generated checksum matches with the original checksum

# 5. References
[VMware ESXi Installation and Setup](https://docs.vmware.com/en/VMware-vSphere/7.0/vsphere-esxi-703-installation-setup-guide.pdf)

