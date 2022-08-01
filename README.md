# powershell-azcli

The `AzCli` module is a PowerShell-friendly wrapper for the Azure CLI (`az`).

## Install-AzCli

Install the Azure CLI on Windows or Linux.

```ps1
Install-AzCli [-Force] [-Quiet] [-Passive] [[-Args] <String[]>] [<CommonParameters>]
```

## Test-AzCli

Tests whether the Azure CLI is installed (or available on the path).

```ps1
Test-AzCli [<CommonParameters>]
```

## Invoke-AzCli

Invoke the Azure CLI. Returns the results as an array of PowerShell-friendly objects that can be used directly with `Select-Object`, `Where-Object`, `Sort-Object`, etc.

Alias: `azcli`

```ps1
Invoke-AzCli [[-Command] <String[]>] [-Raw] [<CommonParameters>]
```

Use the `-Raw` switch to invoke directly with no output parsing, which is useful interactive commands like `az login`.

Examples

```txt
> azcli account list | Select-Object -Property Id | Sort-Object
id
--
2ca99e4a-3ef7-409e-aef0-079ec07ab8c9
713bbca3-7f42-4d74-b686-a1e24147ce5b
e61630aa-b77c-4c89-bdaa-de16843a6581
f44781cb-e936-4784-bbce-c784f18b9c26
```

```txt
> azcli -raw login --use-device-code
To sign in, use a web browser to open the page https://microsoft.com/devicelogin and enter the code FDG8BUXAN to authenticate.
```
