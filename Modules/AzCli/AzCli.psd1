# AzCli.psd1

@{
    Author                 = 'John Rivard'
    CompanyName            = ''
    Copyright              = 'Copyright (c) 2022 John Rivard'
    Description            = 'PowerShell wrapper for Azure CLI'
    GUID                   = '04c3414b-86d7-495d-afa7-d31e5adcab36'
    HelpInfoURI            = 'https://raw.githubusercontent.com/johnri/powershell-azcli/main/README.md'
    ModuleVersion          = '0.1.0.0'

    CLRVersion             = '4.0'
    CompatiblePSEditions   = @(
        'Desktop',
        'Core'
    )
    DotNetFrameworkVersion = '4.8'
    PowerShellVersion      = '5.1'
    ProcessorArchitecture  = 'None'

    FileList               = @(
        './AzCli.psd1',
        './AzCli.psm1'
    )

    ModuleToProcess        = @(
        "./AzCli.psm1"
    )

    FunctionsToExport      = @(
        'Install-AzCli'
        'Invoke-AzCli'
        'Test-AzCli'
    )

    CmdletsToExport        = @(
    )

    AliasesToExport        = @(
        'AzCli'
    )

    PrivateData            = @{
        PSData = @{
            IconUri      = 'https://portal.azure.com/Content/favicon.ico'
            LicenseUri   = 'https://raw.githubusercontent.com/johnri/powershell-azcli/main/LICENSE'
            PreRelease   = 'PRE'
            ProjectUri   = 'https://github.com/johnri/powershell-azcli'
            ReleaseNotes = 'https://raw.githubusercontent.com/johnri/powershell-azcli/main/README.md'
            Tags         = @(
                'az',
                'azure-cli',
                'AzureCLI'
            )
        }
    }
}
