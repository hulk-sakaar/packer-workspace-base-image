Install Packer
you'll need to download packer and install - https://developer.hashicorp.com/packer/install?ajs_aid=66515ee0-6e7d-4cb3-814a-ea70ee0dfeec&product_intent=packer - then set a system variable path for packer

Install ADK
you will need to download and install Microsoft's ADK - https://learn.microsoft.com/en-us/windows-hardware/get-started/adk-install - you will need to add a system variable path for ocsdimg - C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\x86\Oscdimg

Change product key
in the unattended file answer_files/11_hyperv/Autounattend.xml you will want to change the product key on line 34

ISO
The iso can be local or download from the web via the script.

Run script
runBuild.ps1


