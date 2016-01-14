#Module#PSISE_Addons#
Function Save-AllNamedFiles {
    <#
        .SYNOPSIS
        Saves all Files in a PowerShell ISE Tab that already have a filename 
        .DESCRIPTION
        This uses $PSISE.CurrentFiles to save all files that have been edited in the session
   
        This will save the file in the location determined by the $PSISE.CurrentFile.FullPath for each open file
        (uses $PSISE.CurrentPowerShellTab.Files to find them all) and then does a where loop
        (Which should be in a PSDrive for ease of access because you do use PSDrives right??)
   
        Also as I would expect that your using Git for Source control (You are using source control right??) 
        this will also commit the file saves to Git on the basis that the files you have been working on are stored
        in either the root of the directory of a Git Repo or is in a subdirectory and will traverse upwards until the 
        function finds the directory that contains the Git Repo Store i.e the folder that contains a hidden subfolder called .git

        If not then you NEED to learn Git and start to use it - this function makes it so much simpler to deal with as well!  
        .EXAMPLE
        Save-AllUnnamedFiles
        .EXAMPLE
        Place into your Profile the following

        if ($host.Name -eq "Windows PowerShell ISE Host") {
        $MyMenu = $psise.CurrentPowerShellTab.AddOnsMenu.Submenus.Add("PSISE_Addons",$null,$null)
        $MyMenu.Submenus.Add("Save & Commit Current ISE File", { Save-CurrentISEFile }, "Ctrl+Alt+Shift+S") | Out-Null
        $MyMenu.Submenus.Add("Save & Commit all files that have been named", { Save-AllNamedFiles }, "Ctrl+Shift+S") | Out-Null
        $MyMenu.Submenus.Add("Save & Commit all unnamed files", { Save-AllUnnamedFiles -GeneralModuleDetails $psd1 }, "Ctrl+Alt+S") | Out-Null
        }

        Now you can run this function using Ctrl+Alt+S and the sister function to this one, Save-AllNamedFiles with Ctrl+Shift+S and it's other more popular sister
        Save-CurrentISEFile using Ctrl+Alt+Shift+S
        
        .OUTPUTS
        Updated Saved PowerShell scripts/module files and Git Commits
        .NOTES
        This Function drastically makes Source control with git much easier to deal with and ensures that you never miss a small 
        change to a script
        .AUTHOR
        Ryan Yates - ryan.yates@kilasuit.org
        .LICENSE
        MIT 
        .CREDITS
        Jeff Hicks Blog about extending the ISE with Addons as can be found at 
        https://www.petri.com/using-addonsmenu-property-powershell-ise-object-model
        .TO-DO
        Neaten this up and build a V2 version
    #>
    #Requires -Version 4.0
    [cmdletbinding()]
    param ()
    If ($host.Name -ne 'Windows PowerShell ISE Host')
    { Write-Warning 'Unable to be used in the console please use this in PowerShell ISE'}
    else {
        $oldlocation = Get-Location
        $psise.CurrentPowerShellTab.Files.Where(
        {-Not $_.IsUntitled -and -not $_.IsSaved}).Foreach(
            {$_.save() ; 
            $displayname = $($_.DisplayName.Replace('*','')) ; 
            Set-Location $_.FullPath.Replace($DisplayName,'') ; 
                if((test-path .\.git\) -eq $true) 
                { git add $displayname ; 
                    $CustomCommit = Request-YesOrNo -title 'Pre-Commit Message' -message 'Do you want to provide a Custom Commit Message'
                    if($CustomCommit) {$CustomCommitMessage = Get-CustomCommitMessage -filename $displayname ; git commit -m $CustomCommitMessage }
                    else { git commit -m "Saving file $displayname at $(get-date -Format "dd/MM/yyyy HH:mm") and commiting to Repo"} 
                }
                else {
                do {Set-Location .. } until ((Test-Path .\.git\) -eq $true) } ;
                $gitfolder = Get-Item .\ ; 
                $gitfile = $_.FullPath.Replace("$($gitfolder.FullName)","").TrimStart('\') ; 
                git add $gitfile ;
                $CustomCommit = Request-YesOrNo -title 'Pre-Commit Message' -message 'Do you want to provide a Custom Commit Message'
                if($CustomCommit) {$CustomCommitMessage = Get-CustomCommitMessage -filename $displayname ; git commit -m $CustomCommitMessage }
                else { git commit -m "Saving file $gitfile at $(get-date -Format "dd/MM/yyyy HH:mm") and commiting to Repo"} ;
           })
    #Correct Location for the Set-Location as in the Else loop from the 1st If
    Set-Location $oldlocation
    }
}

Function Save-AllUnnamedFiles {
    <#
        .SYNOPSIS
        Saves all Files that have no filename based on the FirstLine of the File
        .DESCRIPTION
        This uses $PSISE.CurrentFiles to save all files on the basis that the first line has the following Structure
        #Script#SP CSOM Testing Lists#
        or
        #Module#Test Module#

        This will save the file in the location PSDrive called Scripts and in the Subdirectory WIP (Work in Progress) (because you do use PSDrives right??) with the filename 
        SP CSOM Testing Lists.ps1 as in this example it is denoted as a script.

        However if you are creating a Module (again because you are creating Modules and not single scripts right??) then it will be created as a .psm1 file
        and the function will automatically create you an example .psd1 module manifest with the details as detailed in the ps1ddetails variable at the the bottom of
        the PSISE_Addons psm1 file.
   
        Also as I would expect that your using Git for Source control (You are using source control right?? - Do you see a patter forming here??) 
        this will also commit the file saves to Git on the basis that you have the Scripts PSDrive Root as the Git Repo store i.e this folder
        contains a hidded subfolder called .git
   
        If not then you NEED to learn Git and start to use it - this function makes it so much simpler to deal with as well!  
        .EXAMPLE
        Save-AllUnnamedFiles
        .EXAMPLE
        Place into your Profile the following

        if ($host.Name -eq "Windows PowerShell ISE Host") {
        $MyMenu = $psise.CurrentPowerShellTab.AddOnsMenu.Submenus.Add("PSISE_Addons",$null,$null)
        $MyMenu.Submenus.Add("Save & Commit Current ISE File", { Save-CurrentISEFile }, "Ctrl+Alt+Shift+S") | Out-Null
        $MyMenu.Submenus.Add("Save & Commit all files that have been named", { Save-AllNamedFiles }, "Ctrl+Shift+S") | Out-Null
        $MyMenu.Submenus.Add("Save & Commit all unnamed files", { Save-AllUnnamedFiles -GeneralModuleDetails $psd1 }, "Ctrl+Alt+S") | Out-Null
        }

        Now you can run this function using Ctrl+Alt+S and the sister function to this one, Save-AllNamedFiles with Ctrl+Shift+S and it's other more popular sister
        Save-CurrentISEFile using Ctrl+Alt+Shift+S
        
        .OUTPUTS
        New Saved files and Git Commits
        .NOTES
        This Function drastically makes Source control with git much easier to deal with and ensures that you never miss a small change to a script
        .AUTHOR
        Ryan Yates - ryan.yates@kilasuit.org
        .LICENSE
        MIT 
        .CREDITS
        Jeff Hicks Blog about extending the ISE with Addons as can be found at https://www.petri.com/using-addonsmenu-property-powershell-ise-object-model
        .TO-DO
        Neaten this up and build a V2 version
    #>
    #Requires -Version 4.0
    [cmdletbinding()]
    param(
        [hashTable]$GeneralModuleDetails,
        [object]$DefaultPesterTests
    )
    If ($host.Name -ne 'Windows PowerShell ISE Host')
    { Write-Warning 'Unable to be used in the console please use this in PowerShell ISE'}
    else {
        $oldlocation = Get-Location
        $psise.CurrentPowerShellTab.Files.Where({$_.IsUntitled}).Foreach({$firstLine = $(($_.Editor.Text -split '[\n]')[0].Trim()) ;
                if ($firstLine.Contains('Script')) { $type = 'Script' ; $filename = $($firstline.replace('#Script','').Replace('#','')) ; $name = "$filename.ps1" }
                elseif ($firstLine.Contains('Module')) { $type = 'Module'; $filename = $($firstline.replace('#Module','').Replace('#','')) ; $name = "$filename.psm1" }
                if ($type -eq 'Script') {$path = "$(Get-PSDrive Scripts-Wip | Select-Object -ExpandProperty root)\"}
                elseif ($type -eq 'Module') {$path = "$(Get-PSDrive Modules-Wip | Select-Object -ExpandProperty root)\$filename\" ; New-item $path -ItemType Directory -Force | Out-Null} 
                $fullname = "$path$name" ; 
                $_.saveas($fullname) ; 
                Set-Location $path ;
                if ($type -eq 'Script')  { Set-Location .. ; 
                    New-Item -Path .\$filename.tests.ps1 -ItemType File -Force | Out-Null ;
                    Set-Content -Path .\$filename.tests.ps1 -Value $defaultPesterTests ;
                    git add WIP\$name ; 
                    git commit -m "Saving script $name at $(get-date -Format "dd/MM/yyyy HH:mm") and commiting them to Repos"}
                elseif ($type -eq 'Module') { $psd1.RootModule = $name ; 
                    $psd1.Path = "$path$filename.psd1" ; $psd1.Description = $psd1.Description.Replace('*ModuleName*',$filename) ;
                    New-ModuleManifest @psd1 ;
                    New-Item -Path .\$filename.tests.ps1 -ItemType File -Force | Out-Null ;
                    Set-Content -Path .\$filename.tests.ps1 -Value $defaultPesterTests ;
                    Set-Location .. ; 
                    git add $filename\* ; 
                    git commit -m "Saving Module $name at $(get-date -Format "dd/MM/yyyy HH:mm") and commiting it to the Repos"}
        })
        #Correct Location for the Set-Location as in the Else loop from the 1st If
    Set-Location $oldlocation 
    }
}

Function Save-CurrentISEFile {
<#
        .SYNOPSIS
        Saves Current File that you have open in ISE - only saves the Open and active File
        .DESCRIPTION
        This uses $PSISE.CurrentFile to save the file on the basis that the first line has the following Structure
        #Script#SP CSOM Testing Lists#
        or
        #Module#Test Module#

        This will save the file in the location PSDrive called Scripts-WIP (if marked as a Script) - because you do use PSDrives right?? - with the filename 
        SP CSOM Testing Lists.ps1 as in this example it is denoted as a script and will create a default pester test script as well.

        However if you are creating a Module (again because you are creating Modules and not single scripts right??) then it will be created as a .psm1 file
        and the function will automatically create you an example .psd1 module manifest with the details as detailed in the ps1ddetails variable at the the bottom of
        the PSISE_Addons psm1 file.
   
        Also as I would expect that your using Git for Source control (You are using source control right?? - Do you see a patter forming here??) 
        this will also commit the file saves to Git on the basis that you have the Scripts-Wip PSDrive Root as the Git Repo store i.e this folder
        contains a hidded subfolder called .git or the Modules-WIP PSDrive
   
        If not then you NEED to learn Git and start to use it - this function makes it so much simpler to deal with as well!  
        .EXAMPLE
        Save-CurrentISEFile
        .EXAMPLE
        Place into your Profile the following

        if ($host.Name -eq "Windows PowerShell ISE Host") {
        $MyMenu = $psise.CurrentPowerShellTab.AddOnsMenu.Submenus.Add("PSISE_Addons",$null,$null)
        $MyMenu.Submenus.Add("Save & Commit Current ISE File", { Save-CurrentISEFile }, "Ctrl+Alt+Shift+S") | Out-Null
        $MyMenu.Submenus.Add("Save & Commit all files that have been named", { Save-AllNamedFiles }, "Ctrl+Shift+S") | Out-Null
        $MyMenu.Submenus.Add("Save & Commit all unnamed files", { Save-AllUnnamedFiles -GeneralModuleDetails $psd1 }, "Ctrl+Alt+S") | Out-Null
        }

        Now you can run this function using Ctrl+Alt+S and the sister function to this one, Save-AllNamedFiles with Ctrl+Shift+S and it's other more popular sister
        Save-CurrentISEFile using Ctrl+Alt+Shift+S

        .OUTPUTS
        New Saved files and Git Commits
        .NOTES
        This Function drastically makes Source control with git much easier to deal with and ensures that you never miss a small change to a script
        .AUTHOR
        Ryan Yates - ryan.yates@kilasuit.org
        .LICENSE
        MIT 
        .CREDITS
        Jeff Hicks Blog about extending the ISE with Addons as can be found at https://www.petri.com/using-addonsmenu-property-powershell-ise-object-model
        .TO-DO
        Neaten this up and build a V2 version
    #>
    #Requires -Version 4.0
    [cmdletbinding()]
    param()

If ($host.Name -ne 'Windows PowerShell ISE Host')
    { Write-Warning 'Unable to be used in the console please use this in PowerShell ISE'}
    else {
$oldlocation = get-location
$currentfile = $psISE.CurrentFile
if (($CurrentFile.IsSaved -eq $false) -and ($CurrentFile.IsUntitled -eq $false)) {
    Write-Verbose 'Now Saving existing file to its current saved path'
    $CurrentFile.Save()
    $displayname = $($CurrentFile.DisplayName.Replace('*','')) 
    Set-Location $CurrentFile.FullPath.Replace($DisplayName,'') ; 
    if((test-path .\.git\) -eq $true) { git add $displayname ; 
        $CustomCommit = Request-YesOrNo -title 'Pre-Commit Message' -message "Do you want to provide a Custom Commit Message for $DisplayName"
        if($CustomCommit) {$CustomCommitMessage = Get-CustomCommitMessage -filename $displayname  ; git commit -m $CustomCommitMessage }
        else { git commit -m "Saving file $displayname at $(get-date -Format "dd/MM/yyyy HH:mm") and commiting to Repo"} 
    }
    else {
    do {Set-Location .. } until ((Test-Path .\.git\) -eq $true) } ;
    $gitfolder = Get-Item .\ ; 
    $gitfile = $currentfile.FullPath.Replace("$($gitfolder.FullName)","").TrimStart('\') ; 
    git add $gitfile ;
    $CustomCommit = Request-YesOrNo -title 'Pre-Commit Message' -message "Do you want to provide a Custom Commit Message for $displayname"
    if($CustomCommit) {$CustomCommitMessage = Get-CustomCommitMessage -filename $displayname  ; git commit -m $CustomCommitMessage }
    else { git commit -m "Saving file $gitfile at $(get-date -Format "dd/MM/yyyy HH:mm") and commiting to Repo"} ;
  }
    elseif (($CurrentFile.IsSaved -eq $false) -and ($CurrentFile.IsUntitled -eq $true)) {
        $firstLine = $(($currentfile.Editor.Text -split '[\n]')[0].Trim()) ;
                if ($firstLine.Contains('Script')) { $type = 'Script' ; $filename = $($firstline.replace('#Script','').Replace('#','')) ; $name = "$filename.ps1" }
                elseif ($firstLine.Contains('Module')) { $type = 'Module'; $filename = $($firstline.replace('#Module','').Replace('#','')) ; $name = "$filename.psm1" }
                if ($type -eq 'Script') {$path = "$(Get-PSDrive Scripts-wip | Select-Object -ExpandProperty root)\"}
                elseif ($type -eq 'Module') {$path = "$(Get-PSDrive Modules-wip | Select-Object -ExpandProperty root)\$filename\" ; New-item $path -ItemType Directory -Force | Out-Null } 
                $fullname = "$path$name" ; 
                $Currentfile.saveas($fullname) ; 
                Set-Location $path ;
                if ($type -eq 'Script')  { 
                    New-Item -Path .\$filename.tests.ps1 -ItemType File -Force | Out-Null ;
                    Set-Content -Path .\$filename.tests.ps1 -Value $defaultPesterTests ;
                    git add --all ;
                    $CustomCommit = Request-YesOrNo -title 'Pre-Commit Message' -message "Do you want to provide a Custom Commit Message for $filename"
                    if($CustomCommit) {$CustomCommitMessage = Get-CustomCommitMessage -filename $filename  ; git commit -m $CustomCommitMessage }
                    else { git commit -m "Saving file $displayname at $(get-date -Format "dd/MM/yyyy HH:mm") and commiting to Repo"}
                    }
                elseif ($type -eq 'Module') { 
                Set-location $path
                $psd1.RootModule = $name ; 
                    $psd1.Path = "$path$filename.psd1" ; $psd1.Description = $psd1.Description.Replace('*ModuleName*',$filename) ;
                    New-ModuleManifest @psd1 ;
                    New-Item -Path .\$filename.tests.ps1 -ItemType File -Force | Out-Null ;
                    Set-Content -Path .\$filename.tests.ps1 -Value $defaultPesterTests ;
                    Set-Location .. ; 
                    git add $filename\* ;
                    $CustomCommit = Request-YesOrNo -title 'Pre-Commit Message' -message "Do you want to provide a Custom Commit Message for $filename"
                    if($CustomCommit) {$CustomCommitMessage = Get-CustomCommitMessage -filename $filename  ; git commit -m $CustomCommitMessage }
                    else { git commit -m "Saving file $displayname at $(get-date -Format "dd/MM/yyyy HH:mm") and commiting to Repo"}
        }
    }
    Set-Location $oldlocation
}
}

Function Get-CustomCommitMessage {
<#
 .SYNOPSIS
  Grabs Custom Git Commit Message
 .DESCRIPTION
  Requests User to Add in Custom Commit Message for the File in question
 .EXAMPLE
  $CustomCommit = Request-YesOrNo -title 'Pre-Commit Message' -message 'Do you want to provide a Custom Commit Message'
  if ($customCommit) { *do x*} else { *do y*}
 .TO-DO
  Not Use VB Popup - but is slightly better than current Read-Host on Win10 
  #>
  [cmdletbinding()]
  param(
  $filename
  )
Add-Type -AssemblyName Microsoft.VisualBasic
[Microsoft.VisualBasic.Interaction]::InputBox("Enter Custom Git Commit Message for $filename","Git Commit Message for $filename", '')
}

function Request-YesOrNo {
<#
 .SYNOPSIS
  Requests from the End User a Yes or a No to the Question passed to it
 .DESCRIPTION
  As SYNOPSIS
 .EXAMPLE
  $CustomCommitMessage = Get-CustomCommitMessage
  #>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$false, Position=1)]
        [string]$title="Confirm",
        
        [Parameter(Mandatory=$true, Position=2)]
        [string]$message="Are you sure?"
    )

	$choiceYes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "Answer Yes."
	$choiceNo = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "Answer No."
	$options = [System.Management.Automation.Host.ChoiceDescription[]]($choiceYes, $choiceNo)

	try {
		$result = $host.ui.PromptForChoice($title, $message, $options, 1)
	}
	catch [Management.Automation.Host.PromptingException] {
	    $result = $choiceNo
	}	

	switch ($result)
	{
		0 { Return $true  } 
		1 { Return $false }
	}
}


<#
Suggestion to put this in your PowerShell ISE Profile or in a General Profile in a scriptblock like the following 

if ($host.Name -eq "Windows PowerShell ISE Host") {

Put the below variables psd1 & DefaultPesterTests in your PowerShell Profile so that It can always be called - Be sure to change the details to your own.
$psd1 = @{
    Path = '' #Please Leave blank as it is automatically populated by the function;
    Author = 'Ryan Yates';
    CompanyName = '';
    Copyright = "© $(Get-date -Format yyyy) Ryan Yates";
    RootModule = '' # Please leave this blank as it is automatically populated by the function;
    Description = 'Initial Description for *ModuleName*'#This is replaced correctly in the function;
    ProjectUri = [uri]'https://github.com/kilasuit/poshfunctions' # Suggested GitHub Location;
    LicenseUri = [uri]'https://github.com/kilasuit/poshfunctions/License.md' #Suggested License;
    ReleaseNotes = 'Initial starting release of this module';
    DefaultCommandPrefix = '';
    ModuleVersion = '0.0.1'
    PrivateData = @{Twitter = '@ryanyates1990'; Blog='www.kilasuit.org/blog'}
}
$DefaultScriptPesterTests = Get-Content -Path "$(Split-path -Path ((get-module PSISE_Addons -ListAvailable).Path) -Parent)\PSISE_Addons.default.script.tests.ps1"
$DefaultPesterTests = Get-Content -Path "$(Split-path -Path ((get-module PSISE_Addons -ListAvailable).Path) -Parent)\PSISE_Addons.default.tests.ps1"
}
#>