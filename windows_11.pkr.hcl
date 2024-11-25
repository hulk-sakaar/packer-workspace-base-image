packer {
  required_plugins {
    hyperv = {
      source  = "github.com/hashicorp/hyperv"
      version = "~> 1"
    }
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = "~> 1"
    }
    windows-update = {
      version = "0.16.8"
      source  = "github.com/rgl/windows-update"
    }
  }

}

########################################################################################################################
####### Do not change anything below #######
########################################################################################################################

local "buildtime" {
  expression = formatdate("YYYY-MM-DD", timestamp())
}

variable "cpus" {
  type    = string
  default = "2"
}

variable "headless" {
  type    = string
  default = false
}

variable "disk_size" {
  type    = string
  default = "70000"
}

variable "iso_url" {
  type    = string
  default = "./iso/Windows_11.iso"
}

variable "memory" {
  type    = string
  default = "8096"
}

variable "vm_name" {
  type    = string
  default = "windows_11"
}


source "hyperv-iso" "hyperv" {
  boot_command = ["a<wait3>a<wait3>a<wait3>a<wait3>a<wait3>a<wait3>a<wait3>a"]
  boot_wait    = "-1s"
  cd_files = [
    "./answer_files/11_hyperv/Autounattend.xml",
    "./scripts/enable-winrm.ps1"

  ]
  communicator                     = "winrm"
  configuration_version            = "10.0"
  cpus                             = "${var.cpus}"
  disk_size                        = "${var.disk_size}"
  enable_dynamic_memory            = false
  enable_mac_spoofing              = true
  enable_secure_boot               = true
  enable_tpm                       = true
  enable_virtualization_extensions = true
  generation                       = "2"
  guest_additions_mode             = "disable"
  iso_checksum                     = "${var.hash}"
  iso_url                          = "${var.urlPath}"
  memory                           = "${var.memory}"
  shutdown_command                 = "shutdown /s /t 10 /f /d p:4:1 /c \"Packer Shutdown\""
  switch_name                      = "Default Switch"
  vm_name                          = "${var.vm_name}-${local.buildtime}"
  winrm_password                   = "${var.adminPassword}"
  winrm_timeout                    = "6h"
  winrm_username                   = "workspaces_byol"
  headless                         = "${var.headless}"
}


build {
  sources = [
    "source.hyperv-iso.hyperv"
  ]

  provisioner "file" {
    source      = "./scripts/BYOLChecker"
    destination = "C:/Users/workspaces_byol/Documents"
  }

  provisioner "windows-update" {
    search_criteria = "IsInstalled=0"
    filters = [
      "exclude:$_.Title -like '*Preview*'",
      "include:$true",
    ]
    update_limit = 25
  }

  provisioner "powershell" {
    scripts = [
      "./scripts/cleanUp.ps1"
    ]
  }

  provisioner "powershell" {
    scripts = [
      "./scripts/disable-winrm.ps1"
    ]
  }


  post-processors {

    post-processor "amazon-import" {
      access_key     = "${var.accessKey}"
      secret_key     = "${var.secretKey}"
      s3_bucket_name = "${var.bucket_name}"
      s3_key_name    = "${var.s3_prefix}-${local.buildtime}/${var.vm_name}.vhdx"
      format         = "vhdx"
      platform       = "windows"
      boot_mode      = "uefi"
      tags = {
        Name = "${var.vm_name}-${local.buildtime}"
      }

    }
    post-processor "manifest" {
      output     = "Manifest.json"
      strip_path = true
    }

  }
}



