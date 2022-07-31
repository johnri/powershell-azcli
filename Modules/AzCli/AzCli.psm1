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
        [string[]]$Command
    )

    $expression = "az"
    if ($Command) {
        $expression = "az $($Command -join ' ') -o json"
    }

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
        Installs the Azure CLI on Windows.

    .DESCRIPTION
        Installs the Azure CLI on Windows.

    .COMPONENT
        Azure CLI.

    .PARAMETER Quiet 
        Quiet mode, no user interaction.

    .PARAMETER Passive
        Unattended mode - progress bar only.

    .PARAMETER Args
        Additional arguments passed to msiexec.

    .INPUTS
        None. You cannot pipe objects to Install-AzCli.

    .OUTPUTS
        None.

    .LINK
        https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-windows
    #>

    [CmdletBinding()]
    param (
        [switch]$Quiet,
        [switch]$Passive,
        [Parameter(ValueFromRemainingArguments=$true)]
        [string[]]$Args
    )

    if ($env:OS -ne "Windows_NT") {
        Write-Error "Install-AzCli is supported only on Windows"
        return
    }

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

New-Alias azcli Invoke-AzCli
Export-ModuleMember -Function Invoke-AzCli,Install-AzCli
Export-ModuleMember -Alias azcli
