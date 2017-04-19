[CmdletBinding()]
param(
    [ValidateSet("nuget", "vsix")]
    [Parameter(Position = 0, Mandatory = "true")]
    [string]$ToolToFetch
)

$root = $PSScriptRoot
$tools = [System.IO.Path]::Combine($root, "..", ".tools")

New-Item $tools -ItemType Directory -ErrorAction Ignore | Out-Null

$uri = $null
$destination = $null

switch($ToolToFetch)
{
    "nuget" {
        # TODO Once nuget v4.0.0 is the latest, we'll go back to using the
        # `latest` URI. v3.5.0 does not understand restoring packages for VS 2017
        # projects.

        # $uri = "https://dist.nuget.org/win-x86-commandline/latest/nuget.exe"

        $uri = "https://dist.nuget.org/win-x86-commandline/v4.0.0/nuget.exe"
        $destination = Join-Path $tools "nuget.exe"
    }
    "vsix" {
        $uri = "https://raw.github.com/madskristensen/ExtensionScripts/master/AppVeyor/vsix.ps1"
        $destination = Join-Path $tools "vsix.ps1"
    }
}

if ($uri -eq $null -or $destination -eq $null) 
{
    Write-Error "Could not set the URI or destination for where to download the tool."
    return -1
}

if(Test-Path $destination)
{
    Write-Verbose "$ToolToFetch already available"
}
else
{
    Write-Verbose "Trying to download $ToolToFetch from $uri to $destination"
    
    Invoke-Webrequest $uri -OutFile $destination
}

$(Resolve-Path $destination).Path