<# 
    Author: Chi Chiu
    Date: 03/04/2021
    Script Name: DNS_Record_Analyzer.ps1

.SYNOPSIS
    This script retrieves DNS records from a specified DNS server and zone, identifies duplicate records based on IP addresses, and identifies outdated records based on a specified threshold.

.DESCRIPTION
    This PowerShell script helps identify duplicate and outdated DNS entries.

.Parameters
    - DnsServer: Specifies the DNS server to retrieve records from.
    - Zone: Specifies the DNS zone to retrieve records from.
    - DaysThreshold: Specifies the number of days threshold for identifying outdated records.

.Example
 .\DNS_Record_Analyzer.ps1 -DnsServer "your_dns_server" -Zone "your_dns_zone" -DaysThreshold 365
#>

# Function to retrieve DNS records from specified DNS server
function Get-DNSRecords {
    param (
        [string]$DnsServer,
        [string]$Zone
    )

    $Records = Get-WmiObject -Class MicrosoftDNS_AType -Namespace "root\MicrosoftDNS" -ComputerName $DnsServer -Filter "ContainerName='$Zone'"
    return $Records
}
<# Invoke with credential
$credential = Get-Credential
Invoke-Command -ComputerName 'lis-dc-01' -Credential $credential -ScriptBlock {
    Get-DnsServerZone
}
#>


# Function to identify duplicate DNS records
function Get-DuplicateRecords {
    param (
        [array]$Records
    )

    $Duplicates = @{}

    foreach ($Record in $Records) {
        $Key = $Record.RecordData.IPAddress
        if ($Duplicates.ContainsKey($Key)) {
            $Duplicates[$Key] += $Record
        } else {
            $Duplicates[$Key] = @($Record)
        }
    }

    return $Duplicates.Values | Where-Object { $_.Count -gt 1 }
}

# Function to identify outdated DNS records (older than specified days)
function Get-OutdatedRecords {
    param (
        [array]$Records,
        [int]$DaysThreshold
    )

    $OutdatedRecords = @()

    foreach ($Record in $Records) {
        $RecordDate = $Record.Timestamp
        $DaysDifference = (Get-Date) - $RecordDate
        if ($DaysDifference.Days -gt $DaysThreshold) {
            $OutdatedRecords += $Record
        }
    }

    return $OutdatedRecords
}

# Specify DNS server and zone
$DnsServer = "your_dns_server"
$Zone = "your_dns_zone"

# Get all DNS records for the specified zone
$Records = Get-DNSRecords -DnsServer $DnsServer -Zone $Zone

# Identify duplicate records
$DuplicateRecords = Get-DuplicateRecords -Records $Records

# Identify outdated records (older than 365 days in this example)
$OutdatedRecords = Get-OutdatedRecords -Records $Records -DaysThreshold 365

# Output the results
Write-Host "Duplicate DNS Records:"
$DuplicateRecords | Format-Table -Property OwnerName, RecordType, RecordData

Write-Host "`nOutdated DNS Records (older than 365 days):"
$OutdatedRecords | Format-Table -Property OwnerName, RecordType, RecordData, Timestamp
