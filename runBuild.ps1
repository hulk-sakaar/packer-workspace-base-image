# Gather ISO and S3 information from the user
$Env:PKR_VAR_urlPath = (Read-Host "Enter URL or local path to your ISO")
$Env:PKR_VAR_hash = (Read-Host "Enter the Hash of your ISO file")
$Env:PKR_VAR_bucket_name = (Read-Host "Enter your S3 Bucket name")
$Env:PKR_VAR_s3_prefix = (Read-Host "Enter the S3 Prefix you want to use for the bucket")
$Env:PKR_VAR_accessKey = (Read-Host "Enter your Access Key")
$Env:PKR_VAR_secretKey = (Read-Host "Enter your Secret Key")
$region = (Read-Host "What region do you want to import the image to?")
$buildDate = (get-date).ToString("yyyy_MM_dd_hh_mm_ss")
$expectedValues = @("y", "n")

# Initialize a variable for user input
$userInput = "".ToLower()

# Loop until the user input matches one of the expected values
do
{
#    # Prompt the user for input
#    $userInput = Read-Host "Do you want a BYOP Image y or n?"

    # Check if the input matches any of the expected values
    if ($expectedValues -contains $userInput)
    {
        continue
    }
    else
    {
        Write-Host "Input does not match any expected values. Please try again."
    }

} while (-not ($expectedValues -contains $userInput))

# Create a random password with a length between 12 and 16 chars
$plength = Get-Random -Minimum 12 -Maximum 16
$Password = -join ((0x30..0x39) + ( 0x41..0x5A) + ( 0x61..0x7A) + ( 0x20..0x2F) | Get-Random -Count $plength  | ForEach-Object { [char]$_ })

# Update the unattend file with the newly generated password
$path = "answer_files/11_hyperv/Autounattend.xml"

if (Test-Path $path)
{
    (Get-Content $path).Replace('adminPassword', $Password) | Set-Content $path

    $Env:PKR_VAR_adminPassword = $Password

    Write-Output "Workspaces_byol account password set to $Password"

    packer.exe init .
    packer.exe build --force .

    # Blank password out in unattend file
    $path = "answer_files/11_hyperv/Autounattend.xml"
    (Get-Content $path).Replace($Password, "adminPassword") | Set-Content $path
    Write-Output  "Password reset to adminPassword"
}

else
{
    Write-Error "Unattend file not found"
}

# Get ami ID from manifest file - work in progress
#$jsonFilePath = "Manifest.json"

#if (Test-Path $jsonFilePath)
#{
#    $jsonContent = Get-Content -Path $jsonFilePath -Raw
#    $jsonObject = ConvertFrom-Json -InputObject $jsonContent
#    $amistring = $jsonObject.builds.artifact_id
#    $ami = $amistring -split ":"
#    $amiID = $ami[1]
#    Write-Host "AMI ID": $amiID

#    #Importing into workspaces
#    #Adding WorkSpaces Powershell module
#    Write-Host "Installing AWS WorkSpaces PowerShell module"
#    Install-Module -Name AWS.Tools.WorkSpaces -Scope CurrentUser -Confirm:$False -Force
#
#    if ($userInput -eq "y")
#    {     Write-Host "Importing BYOP Image"
#          Import-WKSWorkspaceImage -ImageName "Packer_Image_$buildDate" -Ec2ImageId "$amiID" -ImageDescription "testing automated import" -IngestionProcess BYOL_REGULAR_BYOP -AccessKey $Env:PKR_VAR_accessKey -SecretKey $Env:PKR_VAR_secretKey -Region $region
#
#    }
#    else
#    {     Write-Host "Importing BYOL Image"
#          Import-WKSWorkspaceImage -ImageName "Packer_Image_$buildDate" -Ec2ImageId "$amiID" -ImageDescription "testing automated import" -IngestionProcess BYOL_REGULAR -AccessKey $Env:PKR_VAR_accessKey -SecretKey $Env:PKR_VAR_secretKey -Region $region
#
#    }
#}
#
#
#else
#{
#    Write-Error "Json file not found"
#}

