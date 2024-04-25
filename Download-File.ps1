<#
  Author: Chi Chiu
  Date: 04/25/2024
.SYNOPSIS
    Downloads a file from a specified URL using PowerShell.

.DESCRIPTION
    This PowerShell script automates the process of downloading a file from a website. 
    It uses the Invoke-WebRequest cmdlet to fetch the file from the specified URL and saves it to the specified output path. 
    You can customize the URL and output path according to your requirements.

.PARAMETER Url
    Specifies the URL of the file to download.

.PARAMETER Output
    Specifies the path where the downloaded file will be saved.

.EXAMPLE
    Download-File -Url "https://example.com/file.zip" -Output "C:\Downloads\file.zip"
#>

param (
    [string]$Url,
    [string]$Output
)

# Download the file from the specified URL
Invoke-WebRequest -Uri $Url -OutFile $Output
