
#===========================================================================================================
<#

FileName: TflExercise_v1.ps1
Author: Adil Mohammad
Date: 08/03/2021


Transport for London
Senior DevOps Developer (Monitoring)
Technical Exercise (PowerShell)


This technical exercise is to be provided to candidates prior to a face to face interview. The candidate will have 1 week to produce code that satisfies the below requirements.
The code is to be returned to the TfL hiring manager who will assess the code prior to the face to face interview. The code should be returned in runnable electronic form.

Allowances may be made for the fact that the script may be run on a computer on which is was not developed.  

The requirements are intentionally open to allow for the conditions where the script would be developed by the candidate on a computer but  
Finally, the work may be discussed at the interview.

Exercise: 

The requirement of this technical exercise is to write one or more PowerShell scripts that perform the following 6 actions:
1.	Read a setting from registry
2.	Determine the version of .net installed on the computer
3.	Extract the version of a specific dll in a folder
4.	Take 5 consecutive CPU usage readings in 2 second intervals.
5.	Produce a max, min and mean of these readings.
6.	Determine the state of a windows service

The information derived should then be presented to the user running the script.

#==========================================================================================================
README
 
  - All outputs are shown in console.
  - In order to view the outputs please run the script in Powershell ISE 
  - The script can run locally or deploy to remote machine and execute should run. 
  
  Please note that to deploy and run the script on a remote machine another scipt needed to connect to remote machine, copy this script file and execute reomtely.

  I assumed this is out side the scope of the current exercise, although I tried to write script for connecting remote machine but I don't have infrastructure to test this.

#===========================================================================================================

#>

# To fix - The file C:\TfLDevOpsExercise\TfLExercise_v1\TfLExercise_v1.ps1 is not digitally signed.
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

#1.	Read a setting from registry

function GetRegSetting() {

    # I have tried with the following keys

    #$Key = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run' # enter key
    $Key = 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion'
    #$Key = 'HKCU:\Environment'

    Write-Host "======================================================="
    Write-Host "#1.	Read a setting from registry for:" $Key
    
    Get-ItemProperty -Path $Key

}

GetRegSetting

#===========================================================================================================

#2.	Determine the version of .net installed on the computer

function GetDotNetVersion()
{

    Write-Host "======================================================="
    Write-Host "#2.	The version of .net installed on the computer is:"

    $reg = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full'

    Write-Host "Version: " $reg.Version
    Write-Host "Release: " $reg.Release



}

GetDotNetVersion

#===========================================================================================================

#3.	Extract the version of a specific dll in a folder

Function GetDLLVersion() {

    $dllinfopath = "C:\Windows\System32\" # folder path of dll
       
    $dllfile = "comdlg32.dll"  # dll name

    $DLL = $dllinfopath + $dllfile
 
if (!(Test-Path $DLL)) {
    throw "File '{0}' does not exist" -f $DLL
}
 
try { 
    
    Write-Host "======================================================="
    Write-Host "#3.	Extract the version of" $dllfile "in " $dllinfopath ":"

    $dllversion = Get-ChildItem $DLL | Select-Object -ExpandProperty VersionInfo | Select-Object FileVersion | Select-Object -ExpandProperty FileVersion

    Write-Host "dll version: " $dllversion
    
    } catch {
        throw "Failed to get DLL file version: {0}." -f $_
    }

}

GetDLLVersion


#===========================================================================================================

# 4.	Take 5 consecutive CPU usage readings in 2 second intervals.

function CPUReadings(){

$Server = '\\' + $env:COMPUTERNAME 
$MaxSamples = 5
$SampleInterval = 2
$counterName = "\Processor(*)\% Processor Time"

$Counter = $Server + $counterName 

$Data = @() # array

Write-Host "======================================================="
Write-Host "# 4.Taking 5 consecutive CPU usage readings in 2 second intervals..."
Write-Host ""


Get-Counter -Counter $Counter -SampleInterval $SampleInterval -MaxSamples $MaxSamples | 
    Select-Object -ExpandProperty countersamples | 
      % {
        $object = New-Object psobject -Property @{
            CookedValue = $_.CookedValue
        }
        $Data += $object
      }

#===========================================================================================================

# 5.	Produce a max, min and mean of these readings.

Write-Host "# 5.	Produce a max, min and mean of these readings: "
Write-Host ""

$output = [PSCustomObject]@{

            TimeStamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            Mean =(($Data| Measure-Object -Average CookedValue).Average).ToString("#,0.000")
            Max = (($Data| Measure-Object -Maximum CookedValue).Maximum).ToString("#,0.000")
            Min = (($Data| Measure-Object -Minimum CookedValue).Minimum).ToString("#,0.000")
        }

$output

}

CPUReadings

#===========================================================================================================

#6.	Determine the state of a windows service

function CheckServiceStatus {

param($servicename)

$Server = $env:COMPUTERNAME # Insert Server Name, default local machine

$servicename = “wuauserv"   # “Insert SomeService Name”

if (Get-Service $servicename -ComputerName $Server -ErrorAction SilentlyContinue)

    {
        Write-Host "======================================================="
        Write-Host "#6.	Determine the state of a windows service: ", $servicename
        Get-Service $servicename -ComputerName $Server | select Displayname,Status,ServiceName,Can*
    }

Else {
    
    Write-Host "#6.	Determine the state of a windows service: " + $servicename
    Write-Host " $servicename not found"

    }

}

CheckServiceStatus

#===========================================================================================================
