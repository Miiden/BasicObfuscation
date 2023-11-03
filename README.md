
# BasicObfuscation - PowerShell Script Obfuscator

This PowerShell script allows you to obfuscate your PowerShell scripts using different methods to protect your code from easy inspection and tampering.

## Features

- **RemoveComments**: Removes single line and multiline comments from the script.
- **Base64**: Encodes the script in Base64.
- **RandomizeVariableNames**: Randomizes variable names and corrisponding switches/dotnotation leaves protected values alone.

## Prerequisites

- Windows PowerShell or PowerShell Core

## Getting Started

1. Clone this repository or download the script file.
2. Open your terminal or PowerShell command prompt.

### Basic Usage

```powershell
.\BasicObfuscation.ps1 -ScriptPath "C:\path\to\your_script.ps1" -RemoveComments -Base64 -RandomizeVariableNames
```

This command obfuscates the specified script by removing comments, converting it to Base64, and randomizing variable names.

### Running Obfuscated Scripts

After obfuscation, you can run the obfuscated script using the following one-liner:

```powershell
Invoke-Expression ([System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String((Get-Content -Raw -Path "obfuscated.ps1")))
```

## Parameters

- **-ScriptPath**: The path to the PowerShell script you want to obfuscate.
- **-RemoveComments (-rc)**: Remove comments from the script.
- **-Base64 (-b64)**: Obfuscate using Base64 encoding.
- **-RandomizeVariableNames (-rvn)**: Randomize variable names.
- **-All (-all)**: Runs all of the aboves.

## Examples

- Obfuscate the script using all available techniques:
  
  ```powershell
  .\ObfuscateScript.ps1 -ScriptPath "C:\path\to\your_script.ps1" -all
  ```

## License

This project is licensed under the [MIT License](LICENSE.md).


**Note:** This script is intended for educational and informational purposes only. Please use it responsibly and adhere to all applicable laws and regulations in your jurisdiction.
