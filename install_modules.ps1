<#
.SYNOPSIS
    This script is used in AWS CodeBuild to install the required PowerShell Modules for the build process.
.NOTES

#>
$ErrorActionPreference = 'Stop'
$VerbosePreference = 'SilentlyContinue'

$tempPath = [System.IO.Path]::GetTempPath()
$moduleInstallPath = 'C:\Program Files\PowerShell\Modules'
$modulesToInstall = @(
    @{
        ModuleName    = 'Pester'
        ModuleVersion = '4.4.4'
        BucketName    = 'ps-invoke-modules'
        KeyPrefix     = ''
    },
    @{
        ModuleName    = 'InvokeBuild'
        ModuleVersion = '5.4.2'
        BucketName    = 'ps-invoke-modules'
        KeyPrefix     = ''
    },
    @{
        ModuleName    = 'AWSPowerShell.NetCore'
        ModuleVersion = '3.3.428.0'
        BucketName    = 'ps-invoke-modules'
        KeyPrefix     = ''
    },
    @{
        ModuleName    = 'PSScriptAnalyzer'
        ModuleVersion = '1.17.1'
        BucketName    = 'ps-invoke-modules'
        KeyPrefix     = ''
    },
    @{
        ModuleName    = 'platyPS'
        ModuleVersion = '0.12.0'
        BucketName    = 'ps-invoke-modules'
        KeyPrefix     = ''
    }
)

'Installing PowerShell Modules'
foreach ($module in $modulesToInstall) {
    '  - {0} {1}' -f $module.ModuleName, $module.ModuleVersion

    # Download file from S3
    $key = '{0}_{1}.zip' -f $module.ModuleName, $module.ModuleVersion
    $localFile = Join-Path -Path $tempPath -ChildPath $key

    # Download modules from S3 to using the AWS CLI
    $s3Uri = 's3://{0}/{1}{2}' -f $module.BucketName, $module.KeyPrefix, $key
    & aws s3 cp $s3Uri $localFile --quiet
    #& aws s3 cp $s3Uri $localFile

    # Create module path
    $modulePath = Join-Path -Path $moduleInstallPath -ChildPath $module.ModuleName
    $moduleVersionPath = Join-Path -Path $modulePath -ChildPath $module.ModuleVersion
    $null = New-Item -Path $modulePath -ItemType 'Directory' -Force
    $null = New-Item -Path $moduleVersionPath -ItemType 'Directory' -Force

    # Expand downloaded file
    Expand-Archive -Path $localFile -DestinationPath $moduleVersionPath -Force
}