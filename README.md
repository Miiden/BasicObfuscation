# EyeSpy

![EyeSpy Logo](https://github.com/Miiden/EyeSpy/blob/main/eyespy_logo.png)

EyeSpy is a tool designed to enumerate and gain access to IP Cameras via RTSP. It provides a flexible and efficient way to scan for open RTSP ports, discover available paths, and attempt common credential spraying attacks.

## Table of Contents

- [Introduction](#introduction)
- [Installation](#installation)
- [Usage](#usage)
- [Examples](#examples)
- [Contributing](#contributing)
- [License](#license)

## Introduction

EyeSpy is developed by Miiden and is available on [GitHub](https://github.com/Miiden). It utilizes PowerShell scripting to perform various tasks related to IP camera enumeration and access.

## Installation

There is no specific installation required for EyeSpy. Simply download or clone the script from the [GitHub repository](https://github.com/Miiden/EyeSpy) and run it using PowerShell.

## Usage

EyeSpy provides several command-line options to customize its behavior:

- `-Scan <IP>`: Scan a single IP address for open RTSP ports.
- `-FullAuto <IP/CIDR>`: Perform a full automatic scan within a specified IP range (CIDR notation).
- `-PathScan <IP/CIDR>`: Scan for open RTSP ports and spray common paths.
- `-Help`: Display the help menu, showing usage instructions and examples.

## Examples

```powershell
EyeSpy -Scan 192.168.0.123
Full Automatic Scan
powershell
Copy code
EyeSpy -FullAuto 192.168.0.1/24
Path Scan
powershell
Copy code
EyeSpy -PathScan 10.0.0.0/16
Display Help
powershell
Copy code
EyeSpy -Help
```
### Basic Usage

```powershell
EyeSpy -Scan 192.168.0.123
