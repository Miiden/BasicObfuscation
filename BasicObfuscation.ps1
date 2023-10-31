<#
.SYNOPSIS
This script obfuscates a PowerShell script by applying various obfuscation techniques.
.DESCRIPTION
This script allows you to obfuscate a PowerShell script using different methods. You can choose from the following obfuscation techniques:
- RemoveComments (-rc): Removes comments from the script.
- Base64 (-b64): Encodes the script in Base64.
- RandomizeVariableNames (-rvn): Randomizes variable names.
.PARAMETER ScriptPath
The path to the PowerShell script you want to obfuscate.
.PARAMETER RemoveComments
Remove comments from the script.
.PARAMETER Base64
Obfuscate using Base64 encoding.
.PARAMETER RandomizeVariableNames
Randomize variable names.
.EXAMPLE
.\ObfuscateScript.ps1 -ScriptPath "C:\path\to\your_script.ps1" -RemoveComments -Base64 -RandomizeVariableNames
This command obfuscates the specified script by removing comments, converting it to Base64, and randomizing variable names.

You can then run the target script using the following one-liner:
Invoke-Expression ([System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String((Get-Content -Raw -Path "obfuscated.ps1")))

#>

param(
    [string]$ScriptPath,
    [switch]$RemoveComments,
    [switch]$Base64,
    [switch]$RandomizeVariableNames,
    [switch]$all,
    [switch]$rc,
    [switch]$b64,
    [switch]$rvn
)

if (-not $PSBoundParameters.GetEnumerator().MoveNext() -or $help -or $h) {
    # If no parameters are provided or '-help' is specified, display simplified help.
    Write-Host "Usage: .\ObfuscateScript.ps1 -ScriptPath <script path> [-all] [-rc] [-b64] [-rvn] [-help]"
    Write-Host "Options:"
    Write-Host "- ScriptPath: The path to the PowerShell script you want to obfuscate."
    Write-Host "- -all: Apply all available obfuscation techniques."
    Write-Host "- -rc: Remove comments from the script."
    Write-Host "- -b64: Obfuscate using Base64 encoding."
    Write-Host "- -rvn: Randomize variable names."
    Write-Host "- -help: Display this help message."
    Exit
}

# Check if the "All" parameter is specified
if ($all) {
    $RemoveComments = $true
    $Base64 = $true
    $RandomizeVariableNames = $true
}

# Check if no obfuscation switch is specified
if (-not ($RemoveComments -or $Base64 -or $RandomizeVariableNames -or $rc -or $b64 -or $rvn)) {
    Write-Host "No obfuscation technique selected. Please specify at least one obfuscation switch or use -help for usage information."
    Exit
}

if (-not (Test-Path $ScriptPath)) {
    Write-Host "The specified script file does not exist: $ScriptPath"
    Exit
}

# Read the original script content
$originalScript = Get-Content -Path $ScriptPath -Raw

# Apply selected obfuscation methods

# Remove comments, lines starting with #, trailing whitespace, and consecutive newlines
if ($RemoveComments -or $rc) {
    $originalScript = $originalScript -replace '(?m)^\s*#.*$|(?s)<#.*?#>|^\s*#.*', '' -replace '\s+$', '' -replace '\n{2,}', "`n"
}

# Define a list of variables that should not be modified
$protectedVariables = @('$_', '$args', '$PSItem', '$Error', '$Host', '$ExecutionContext', '$null', 'True', 'False')

if ($RandomizeVariableNames -or $rvn) {
    $variableMapping = @{}
    
    # Find all variable names in the script
    $variableRegex = '\$\w+'
    $variableNames = $originalScript | Select-String -Pattern $variableRegex -AllMatches | ForEach-Object {
        $_.Matches.Value
    } | Sort-Object -Unique

    # Generate and store random alphanumeric values for each variable name
    $random = New-Object System.Random
    $characters = [char[]](@(48..57) + @(65..90) + @(97..122))

    $variableNames | ForEach-Object {
        # Check if the variable is in the list of protected variables
        if ($protectedVariables -notcontains $_) {
            $randomName = -join ($characters | ForEach-Object { $_ } | Sort-Object { $random.Next() } | Select-Object -First 5) # Maximum length 5 characters
            $variableMapping[$_] = '$' + $randomName
        } else {
            # If the variable is protected, keep it unchanged
            $variableMapping[$_] = $_
        }
    }
    
    # Replace variable names with the corresponding random values
    $originalScript = $variableNames | ForEach-Object {
        $originalScript -replace [regex]::Escape($_), $variableMapping[$_]
    }
}


if ($Base64 -or $b64) {
    $originalScript = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($originalScript))
}

# Determine the directory of the obfuscation script
$scriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Definition

# Get the base name of the script being obfuscated
$scriptBaseName = [System.IO.Path]::GetFileNameWithoutExtension($ScriptPath)

# Save the obfuscated script to a new file
$obfuscatedScriptFileName = [System.IO.Path]::GetFileNameWithoutExtension($ScriptPath) + "-obfuscated.ps1"
$obfuscatedScriptFilePath = Join-Path -Path $scriptDirectory -ChildPath $obfuscatedScriptFileName

# Save the obfuscated script content to the file
Set-Content -Path $obfuscatedScriptFilePath -Value ([System.Text.Encoding]::UTF8.GetBytes($originalScript)) -Encoding Byte

Write-Host "Script obfuscated and saved to $obfuscatedScriptFilePath"

if ($Base64 -or $b64 -or $all) {
	Write-Host "Use the following one-liner to run:"
	Write-Host "Invoke-Expression ([System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String((Get-Content -Raw -Path '$obfuscatedScriptFilePath'))))" 
}
