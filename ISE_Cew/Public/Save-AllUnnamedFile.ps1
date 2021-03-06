Function Save-AllUnnamedFile {
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
   
        Also as I would expect that your using Git for Source control (You are using source control right?? - Do you see a pattern forming here??) 
        this will also commit the file saves to Git on the basis that you have the Scripts PSDrive Root as the Git Repo store i.e this folder
        contains a hidded subfolder called .git
   
        If not then you NEED to learn Git and start to use it - this function makes it so much simpler to deal with as well!  
        .EXAMPLE
        Save-AllUnnamedFile
        .EXAMPLE
        Place into your Profile the following

        if ($host.Name -eq "Windows PowerShell ISE Host") {
        $MyMenu = $psise.CurrentPowerShellTab.AddOnsMenu.Submenus.Add("PSISE_Addons",$null,$null)
        $MyMenu.Submenus.Add("Save & Commit Current ISE File", { Save-CurrentISEFile }, "Ctrl+Alt+Shift+S") | Out-Null
        $MyMenu.Submenus.Add("Save & Commit all files that have been named", { Save-AllNamedFile }, "Ctrl+Shift+S") | Out-Null
        $MyMenu.Submenus.Add("Save & Commit all unnamed files", { Save-AllUnnamedFile -GeneralModuleDetails $psd1 }, "Ctrl+Alt+S") | Out-Null
        }

        Now you can run this function using Ctrl+Alt+S and the sister function to this one, Save-AllNamedFil with Ctrl+Shift+S and it's other more popular sister
        Save-CurrentISEFile using Ctrl+Alt+Shift+S
        
        .OUTPUTS
        New Saved files and Git Commits
        .NOTES
        This Function drastically makes Source control with git much easier to deal with and ensures that you never miss a small change to a script
        AUTHOR
        Ryan Yates - ryan.yates@kilasuit.org
        LICENSE
        MIT 
        CREDITS
        Jeff Hicks Blog about extending the ISE with Addons as can be found at https://www.petri.com/using-addonsmenu-property-powershell-ise-object-model
        TO-DO
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
                if ($type -eq 'Script') {$path = "$(Get-PSDrive Scripts-Wip | Select-Object -ExpandProperty root)\$filename\" ; New-item $path -ItemType Directory -Force | Out-Null }
                elseif ($type -eq 'Module') {$path = "$(Get-PSDrive Modules-Wip | Select-Object -ExpandProperty root)\$filename\" ; New-item $path -ItemType Directory -Force | Out-Null} 
                $fullname = "$path$name" ; 
                Set-Location $path ;
                git init ;
                $_.saveas($fullname) ; 
                if ($type -eq 'Script')  {
                    New-Item -Path .\$filename.basic.tests.ps1 -ItemType File -Force | Out-Null ;
                    New-Item -Path .\$filename.bespoke.tests.ps1 -ItemType File -Force | Out-Null ;
                    New-Item -Path .\README.md -ItemType File -Value "This is a Readme file for $filename" -Force | Out-Null ;
                    New-Item -Path .\LICENSE -ItemType File -Value $LicenseMDContent -Force | Out-Null 
                    Set-Content -Path .\$filename.basic.tests.ps1 -Value $defaultPesterTests ;
                    git add --all  ;
                    $CustomCommit = Request-YesOrNo -title 'Pre-Commit Message' -message "Do you want to provide a Custom Commit Message for $filename"
                    if($CustomCommit) {$CustomCommitMessage = Get-CustomCommitMessage -filename $filename  ; git commit -m $CustomCommitMessage }
                    else { git commit -m "Saving script $filename at $(get-date -Format "dd/MM/yyyy HH:mm") and commiting it the to Scripts WIP Repo"} 
                }
                elseif ($type -eq 'Module') { $psd1.RootModule = $name ; 
                    $psd1.Path = "$path$filename.psd1" ; $psd1.Description = $psd1.Description.Replace('*ModuleName*',$filename) ;
                    New-ModuleManifest @psd1 ;
                    New-Item -Path .\$filename.basic.tests.ps1 -ItemType File -Force | Out-Null ;
                    New-Item -Path .\$filename.bespoke.tests.ps1 -ItemType File -Force | Out-Null ;
                    New-Item -Path .\README.md -ItemType File -Value "This is a Readme file for $filename" -Force | Out-Null ;
                    New-Item -Path .\LICENSE -ItemType File -Value $LicenseMDContent -Force | Out-Null
                    Set-Content -Path .\$filename.basic.tests.ps1 -Value $defaultPesterTests ;
                    git add --all ;
                    $CustomCommit = Request-YesOrNo -title 'Pre-Commit Message' -message "Do you want to provide a Custom Commit Message for $filename"
                    if($CustomCommit) {$CustomCommitMessage = Get-CustomCommitMessage -filename $filename  ; git commit -m $CustomCommitMessage }
                    else { git commit -m "Saving New Module $filename at $(get-date -Format "dd/MM/yyyy HH:mm") and commiting to the Modules Repo" }
                }
        }) 
        #Correct Location for the Set-Location as in the Else loop from the 1st If
    Set-Location $oldlocation 
    }
}
