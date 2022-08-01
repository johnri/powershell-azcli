# Copyright (c) Microsoft Corporation
# AzCli.psm1 - Azure CLI Powershell Module

function Invoke-AzCli {
    <#
    .SYNOPSIS
        Invokes the Azure CLI (az).

    .DESCRIPTION
        Invokes the Azure CLI (az).
        Returns the results as an array of PowerShell-friendly objects that can be used 
        directly with Select-Object, Where-Object, Sort-Object, etc.

    .COMPONENT
        Azure CLI.

    .PARAMETER Command 
        The command-line arguments.

    .PARAMETER Raw
        Invoke az directly with no output parsing.

    .INPUTS
        None. You cannot pipe objects to Invoke-AzCli.

    .OUTPUTS
        <PSCustomObject[]> if az returned valid json; otherwise <System.String>.

    .LINK
        https://aka.ms/cli_ref
    #>

    [CmdletBinding()]
    param (
        [Parameter(Position=0, ValueFromRemainingArguments=$true)]
        [string[]]$Command,
        [switch]$Raw
    )

    if (-not (Get-Command "az" -ErrorAction SilentlyContinue)) {
        Write-Error "Azure CLI is not installed. Use Install-AzCli."
        return
    }


    $expression = "az"
    if ($Command) {
        $expression += " $($Command -join ' ')"
    }
    else {
        $Raw = $true
    }

    if ($Raw) {
        Write-Verbose -Message "Executing: $expression"
        Invoke-Expression -Command $expression
        if ($LastExitCode -gt 0) {
            Write-Error "$expression"
        }
        return
    }

    $expression += " -o json"
    Write-Verbose -Message "Executing: $expression"
    $errorOutput = $($result = Invoke-Expression -Command $expression) 2>&1

    if ($LastExitCode -gt 0) {
        $azError = $errorOutput | Out-String

        # retry if "-o json" was not valid
        if ($azError.StartsWith("ERROR: 'json' is misspelled or not recognized by the system.")) {
            $expression = "az $($Command -join ' ') -h"
            Write-Verbose "Re-executing: $expression"
            $errorOutput = $($result = Invoke-Expression -Command $expression) 2>&1
            $azError = $errorOutput | Out-String
        }

        if ($LastExitCode -gt 0) {
            Write-Error $azError
            return $null
        }
    }

    try {
        $result | ConvertFrom-Json -Depth 20 | ForEach-Object { [PSCustomObject]$_ }
    }
    catch {
        $result
    }
}

function Install-AzCli {
    <#
    .SYNOPSIS
        Installs the Azure CLI on Windows or Linux.

    .DESCRIPTION
        Installs the Azure CLI on Windows or Linux.

    .COMPONENT
        Azure CLI.

    .PARAMETER Quiet 
        Quiet mode, no user interaction (Windows only).

    .PARAMETER Passive
        Unattended mode - progress bar only (Windows only).

    .PARAMETER Args
        Additional arguments passed to msiexec (Windows only).

    .INPUTS
        None. You cannot pipe objects to Install-AzCli.

    .OUTPUTS
        None.

    .LINK
        https://docs.microsoft.com/en-us/cli/azure/install-azure-cli
    #>

    [CmdletBinding()]
    param (
        [switch]$Quiet,
        [switch]$Passive,
        [Parameter(ValueFromRemainingArguments=$true)]
        [string[]]$Args
    )

    if ($env:OS -eq "Windows_NT") {
        Write-Host "Installing 'Azure CLI' for Windows" -ForegroundColor Green

        $OldProgressPreference = $ProgressPreference
        try {
            $ProgressPreference = 'SilentlyContinue'
            Write-Verbose "Downloading from https://aka.ms/installazurecliwindows"
            Invoke-WebRequest -Uri "https://aka.ms/installazurecliwindows" -OutFile ".\AzureCLI.msi"
    
            $argumentList = "/I AzureCLI.msi $($Args -join ' ')"
            if ($Quiet) {
                $argumentList += " /quiet"
            }
            if ($Passive) {
                $argumentList += " /passive"
            }
    
            Write-Verbose "Invoking msiexec $argumentList"
            $p = Start-Process msiexec.exe -Wait -ArgumentList $argumentList -PassThru
            $LASTEXITCODE = $p.ExitCode
            if ($LASTEXITCODE -eq 1602) {
                Write-Host "User cancelled installation"
            }
            elseif ($LASTEXITCODE -ne 0) {
                Write-Error "Installation failed: $LASTEXITCODE. See https://docs.microsoft.com/en-us/windows/win32/msi/error-codes"
            }
        }
        finally {
            $ProgressPreference = $OldProgressPreference
            if (Test-Path ".\AzureCLI.msi") {
                Remove-Item ".\AzureCLI.msi"
            }
        }
    }
    elseif ($PSVersionTable.OS.Contains('Ubuntu')) {
        Write-Host "Installing APT package 'azure-cli' for Ubuntu" -ForegroundColor Green
        Invoke-Expression "curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash"
    }
    else {
        Write-Error "Platform not supported"
    }
}

New-Alias azcli Invoke-AzCli
Export-ModuleMember -Function Invoke-AzCli,Install-AzCli
Export-ModuleMember -Alias azcli
