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
	#$ughh = [regex]::new('(?s)\@\x27.*?\x27\@')
	$ughh = [regex]::new('(?s)\@\'(.*?)\'\@')
    $originalScript = $originalScript -replace '(?m)^\s*#.*$|(?s)<#.*?#>|^\s*#.*', '' -replace '\s+$', '' -replace '\n{2,}', "`n", -replace $ughh, ''
}

###############################################################################
#Protected Variables that are standard to PowerShell
$protectedVariables = @('_', 'args', 'PSItem', 'Error', 'Host', 'ExecutionContext', 'null', 'True', 'False')
#Protected Switches that are standard to PowerShell
$protectedSwitches = @(
    'and', 'or', 'not', 'is', 'as', 'ne', 'gt', 'lt', 'eq', 'isnot', 'path',
    'force', 'out', 'contains', 'erroraction', 'encoding', 'value', 'bor',
    'notmatch', 'match', 'band', 'like', 'unlike', 'ge', 'le', 'split',
    'join', 'try', 'catch', 'finally', 'throw', 'in', 'notcontains', 'bxor', 'bnot', 'shl', 'shr',
    'property', 'f', 'replace' ,'match',
	'Clone', 'sCompareTo', 'sContains', 'sCopyTo', 'sEndsWith'
	'Equals', 'sGetEnumerator', 'sGetHashCode', 'sGetType', 'sGetTypeCode'
	'IndexOf', 'sIndexOfAny', 'sInsert', 'sIsNormalized', 'sLastIndexOf'
	'LastIndexOfAny', 'sNormalize', 'sPadLeft', 'sPadRight', 'sRemove'
	'Replace', 'sSplit', 'sStartsWith', 'sSubstring', 'sToBoolean'
	'ToByte', 'sToChar', 'sToCharArray', 'sToDateTime', 'sToDecimal'
	'ToDouble', 'sToInt16', 'sToInt32', 'sToInt64', 'sToLower'
	'ToLowerInvariant', 'sToSByte', 'sToSingle', 'sToString', 'sToType'
	'ToUInt16', 'sToUInt32', 'sToUInt64', 'sToUpper', 'sToUpperInvariant'
	'Trim', 'sTrimEnd', 'sTrimStart', 'imatch'
)
#Protected DotNotations that are standard to PowerShell
$protectedDotNotations = @(
	"Length", "Count", "Name", "Value", "Path", "Extension", "FullName", 
	"BaseName", "LastWriteTime", "LastAccessTime", "CreationTime", "DirectoryName",
	"Mode", "Size", "PSBase", "PSChildName", "PSParentPath", "PSDrive", "PSIsContainer",
	"PSParentPath", "PSProvider", "PSPath", "PSDrive", "Aliases", "Definition", "AppDomain",
	"ModuleBuilder", "Assembly", "PackingSize", 'Name', 'SamAccountName', 'DistinguishedName',
	'UserPrincipalName', 'Description', 'Enabled', 'PasswordLastSet', 'AccountExpires', 'EmailAddress',
	'GivenName', 'Surname', 'DisplayName', 'Title', 'Department', 'Company', 'Manager', 'MemberOf', 'HomeDirectory',
	'HomeDrive', 'ScriptPath', 'Enabled', 'LockedOut', 'PasswordNeverExpires', 'PasswordExpired', 'ObjectClass',
	"CharSet", "Type", 'UnmanagedType', 'StringWriter'
)


# Main Loop for randomizing the variables corrisponding switches and DotNotations
if ($RandomizeVariableNames -or $rvn) {
    $mappings = @()

    # Read the original script line by line
    $lines = $originalScript -split "`n"
	$lineCount = 0
    $processedScript = @()
	$valuesToBeChanged = @()
	
	#Code for creating new random names
    $random = New-Object System.Random
    $characters = [char[]](@(97..122) + @(65..90)) # Lowercase and uppercase letters

    foreach ($line in $lines) {
		#Regex including word boundries to make sure that Variables, Switches and DotNotations are selected correctly.
        $matches = [regex]::Matches($line, ('\$\b[\w\d]+\b| -\b[\w\d]+\b|\.\b[\w\d]+\b'))

        $processedLine = $line  # Initialize processedLine
		
		#Loop for analyzing the suitability of every match for obfuscation
        foreach ($match in $matches) {
            $value = $match.Value

			# Loop to make sure that negative numbers and single character variables are not changed i.e. $i or -1
			if ($value -notmatch '\s*-\d+|\$[a-zA-Z]\b') {
				#Storing found variables, switches and DotNotations in corrisponding variables with regex including word boundries
				$isVariable = $value -match '\$[\w\d]+\b'
				$isSwitch = $value -match ' -[\w\d]+\b'
				$isDotNotation = $value -match '\.[\w\d]+\b'
				
				# Remove the prefix to treat variables and switches without their prefixes
				$cleanValue = $value -replace '^\$|^\s-|^-|^\.'
			
				#Checks if the found value is a variable, and checks if the clean value already exists in the switches and variables hashtables
				if ($isVariable) {
					if ($protectedVariables -notcontains $cleanValue) {
						$mappingsVariable = $mappings | Where-Object { $_["type"] -eq "variable"}
						$mapping = $mappingsVariable | Where-Object { $_["cleanValue"] -eq $cleanValue }
						
						
						if ($mapping -eq $null) {
							$mappingsSwitch = $mappings | Where-Object { $_["type"] -eq "switch" }
							$mapping = $mappingsSwitch | Where-Object { $_["cleanValue"] -eq $cleanValue }
						}
						#If the clean value dosent already have a mapping add it to the hashtable with type "variable" and add the clean value to the entry
						if ($mapping -eq $null) {
							$mapping = @{
								"type" = "variable"
								"cleanValue" = $cleanValue
								"obfuscatedValue" = ""
							}
							$mappings += $mapping
						}

						#If the entry is found and does not already an obfuscated value associated to it, create one and add it to the entry
						if ($mapping["obfuscatedValue"] -eq "") {
							$randomName = -join ($characters | ForEach-Object { $_ } | Sort-Object { $random.Next() } | Select-Object -First 5) # Maximum length 5 characters
							$obfuscatedValue = "$" + $randomName.Substring(0, [Math]::Min(5, $randomName.Length))
							$mapping["obfuscatedValue"] = $obfuscatedValue
						}
						#Check the line for the clean value, and if found replace it with the obfuscated value.
						$processedLine = $processedLine -replace "$([regex]::Escape($value))\b", $mapping["obfuscatedValue"]

					}
				#Checks if the found value is a switch, and checks if the clean value already exists in the switches and variables hashtables						
				} elseif ($isSwitch) {
					if ($protectedSwitches -notcontains $cleanValue) {

							$mappingsVariable = $mappings | Where-Object { $_["type"] -eq "variable" }
							$mapping = $mappingsVariable | Where-Object { $_["cleanValue"] -eq $cleanValue }
						if ($mapping -ne $null) {
							#Had an issue at some point where it was adding variables insted of switches, so used regex to clean the value
							$newSwitchValue = $mapping["obfuscatedValue"] -replace '^\$|^\s-|^-'
							#Passes the value to be written to the line and adds the correct prefix of " -"
							$processedLine = $processedLine -replace "$([regex]::Escape($value))\b", (" -" + $newSwitchValue)
						}
					}
					#Checks if the found value is a DotNotation, and checks if the clean value already exists in the variables hashtables
					#Dont want to obfuscate a DotNotation that isnt designated within the script we are obfuscating
				} elseif ($isDotNotation) {
						if ($protectedDotNotations -notcontains $cleanValue) {
						$mappingsVariable = $mappings | Where-Object { $_["type"] -eq "variable" }
						$mapping = $mappingsVariable | Where-Object { $_["cleanValue"] -eq $cleanValue }
						#If a variable is found with clean value associated to it, the value is cleaned and added back as a DotNotation with the correct prefix "."
						if ($mapping -ne $null) {
							$newDotNotationValue = $mapping["obfuscatedValue"] -replace '^\$|^\s-|^-'
							$processedLine = $processedLine -replace "$([regex]::Escape($value))\b", ("." + $newDotNotationValue)
						}
					}
				}
			

		}
	}
		# Add the processedLine to the processedScript
        $processedScript += $processedLine  
    }

    # Join the processed script lines
    $originalScript = $processedScript -join "`n"

}

###############################################################################

if ($Base64 -or $b64) {
    $originalScript = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($originalScript))
}

# Determine the directory of the obfuscation script
$scriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Definition

# Get the base name of the script being obfuscated
$scriptBaseName = [System.IO.Path]::GetFileNameWithoutExtension($ScriptPath)

# Save the obfuscated script to a new file using StreamWriter
$obfuscatedScriptFileName = [System.IO.Path]::GetFileNameWithoutExtension($ScriptPath) + "-obfuscated.ps1"
$obfuscatedScriptFilePath = Join-Path -Path $scriptDirectory -ChildPath $obfuscatedScriptFileName

# Use StreamWriter to write the obfuscated script content to the file
$streamWriter = [System.IO.StreamWriter]::new($obfuscatedScriptFilePath)
$streamWriter.Write($originalScript)
$streamWriter.Close()

Write-Host "Script obfuscated and saved to $obfuscatedScriptFilePath"

if ($Base64 -or $b64 -or $all) {
    Write-Host "Use the following one-liner to run:"
    Write-Host "Invoke-Expression ([System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String((Get-Content -Raw -Path '$obfuscatedScriptFilePath'))))"
}
