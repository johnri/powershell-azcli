# powershell-azcli

**AzCli** is a wrapper for the [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/). The JSON output of **az** is converted to [PSCustomObject](https://docs.microsoft.com/en-us/powershell/scripting/learn/deep-dives/everything-about-pscustomobject) to make it easy to work with in PowerShell.

It includes helper functions to test whether **az** is installed and to install it on Windows and on Linux.

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

Invoke the Azure CLI. Returns the results as <PSCustomObject[]> that can be used directly with `Select-Object`, `Where-Object`, `Sort-Object`, etc. If the output is not JSON, it is returned as a raw string. Use the `-Raw` switch to invoke **az** directly with no output parsing--useful with interactive commands like `az login`.

Alias: `AzCli`

```ps1
Invoke-AzCli [[-Command] <String[]>] [-Raw] [<CommonParameters>]
```


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
