<#
.SYNOPSIS
    Bulk creates AD users for AATU domain from a CSV file.

.DESCRIPTION
    Reads a CSV with FirstName, LastName, Department, JobTitle columns.
    Creates users in the appropriate department OU, adds them to department
    and all-employees groups, and sets a temporary password (Tervetuloa2026!) requiring change
    at first logon.

.PARAMETER CsvPath
    Path to the CSV file containing user information.

.PARAMETER DefaultPassword
    Initial password for all created accounts. Must be changed at first login.

.EXAMPLE
    .\New-AATUUser.ps1 -CsvPath "C:\Lab\new-users.csv"

.NOTES
    Author: [your name]
    Created: [date]
    Domain: aatu.lab
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$CsvPath,
    
    [Parameter(Mandatory=$false)]
    [string]$DefaultPassword = "Tervetuloa2026!"
)

# Verify CSV exists
if (-not (Test-Path $CsvPath)) {
    Write-Error "CSV file not found: $CsvPath"
    exit 1
}

# Import the AD module
Import-Module ActiveDirectory

# Read the CSV
$users = Import-Csv -Path $CsvPath

# Track results
$created = 0
$skipped = 0
$errors = 0

foreach ($user in $users) {
    # Build the user's logon name: first letter of first name + last name, lowercase
    $samAccountName = ($user.FirstName.Substring(0,1) + $user.LastName).ToLower()
    
    # Remove Finnish characters for the SAM name (ä → a, ö → o, å → a)
    $samAccountName = $samAccountName -replace 'ä','a' -replace 'ö','o' -replace 'å','a'
    
    # Build the display name and UPN
    $displayName = "$($user.FirstName) $($user.LastName)"
    $upn = "$samAccountName@aatu.lab"
    
    # Build the target OU path
    $ouPath = "OU=$($user.Department),OU=Users,OU=AATU,DC=aatu,DC=lab"
    
    # Department group to add to
    $deptGroup = "GG_$($user.Department)_Staff"
    
    # Check if user already exists
    if (Get-ADUser -Filter "SamAccountName -eq '$samAccountName'" -ErrorAction SilentlyContinue) {
        Write-Warning "User $samAccountName already exists. Skipping."
        $skipped++
        continue
    }
    
    try {
        # Create the user
        New-ADUser `
            -Name $displayName `
            -GivenName $user.FirstName `
            -Surname $user.LastName `
            -SamAccountName $samAccountName `
            -UserPrincipalName $upn `
            -DisplayName $displayName `
            -Title $user.JobTitle `
            -Department $user.Department `
            -Path $ouPath `
            -AccountPassword (ConvertTo-SecureString $DefaultPassword -AsPlainText -Force) `
            -ChangePasswordAtLogon $true `
            -Enabled $true `
            -ErrorAction Stop
        
        # Add to department group
        Add-ADGroupMember -Identity $deptGroup -Members $samAccountName -ErrorAction Stop
        
        # Add to all-employees group
        Add-ADGroupMember -Identity "GG_All_Employees" -Members $samAccountName -ErrorAction Stop
        
        Write-Host "Created user: $displayName ($samAccountName) in $($user.Department)" -ForegroundColor Green
        $created++
    }
    catch {
        Write-Error "Failed to create $displayName : $_"
        $errors++
    }
}

# Summary
Write-Host "`n=== Summary ===" -ForegroundColor Cyan
Write-Host "Created: $created" -ForegroundColor Green
Write-Host "Skipped: $skipped" -ForegroundColor Yellow
Write-Host "Errors:  $errors" -ForegroundColor Red