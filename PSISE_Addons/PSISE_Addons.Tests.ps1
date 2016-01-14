$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
$RootLocation = Split-Path -Parent $here


$Scripts = Get-ChildItem "$here\" -Filter '*.ps1' -Recurse | Where-Object {$_.name -NotMatch "Tests.ps1"}
$Modules = Get-ChildItem "$here\" -Filter '*.psm1' -Recurse

if ($Modules.count -gt 0) {
Describe "Testing all Modules in this Repo to be be correctly formatted" {

    foreach($module in $modules)
    {

    Context "Testing Module  - $($module.BaseName) for Standard Processing" {
    Import-Module $module.FullName
          It "Is valid Powershell (Has no script errors)" {

                $contents = Get-Content -Path $module.FullName -ErrorAction Stop
                $errors = $null
             $null = [System.Management.Automation.PSParser]::Tokenize($contents, [ref]$errors)
                $errors.Count | Should Be 0
            }
            It "Has a root module file ($module_name.psm1)" {        
            
        $module.FullName.Replace('psm1','psd1') | Should Exist
    }

    It "Has a manifest file ($($module.BaseName).psd1)" {
            
        $module.FullName.Replace('psm1','psd1') | Should Exist
    }

    It "Contains a root module path in the manifest" {
            
        $module.FullName.Replace('psm1','psd1') | Should Contain "$module_name.psm1"
    }

    It "Contains all needed properties in the Manifest for PSGallery Uploads" {
    
        $module.FullName.Replace('psm1','psd1') | Should Contain "Author = *"
    }

     It 'passes the PSScriptAnalyzer without Errors' {
        (Invoke-ScriptAnalyzer -Path $module.Directory -Recurse -Severity Error).Count | Should Be 0
    }

     It 'passes the PSScriptAnalyzer with less than 10 Warnings excluding PSUseShouldProcessForStateChangingFunctions Rule as it is currently Pants!' {
        (Invoke-ScriptAnalyzer -Path $module.Directory -Recurse -Severity Warning -ExcludeRule PSUseShouldProcessForStateChangingFunctions,PSUseSingularNouns).Count | Should BeLessThan 10 
    }
    }
    $functions = Get-Command -FullyQualifiedModule $module.BaseName 
    foreach($modulefunction in $functions)
    {
    
        Context "Testing that the function - $($modulefunction.Name) - is compliant" {
            It "Function $($modulefunction.Name) Has show-help comment block" {

                $modulefunction.Definition.Contains('<#') | should be 'True'
                $modulefunction.Definition.Contains('#>') | should be 'True'
            }

            It "Function $($modulefunction.Name) Has show-help comment block has a.SYNOPSIS" {

                $modulefunction.Definition.Contains('.SYNOPSIS') -or $modulefunction.Definition.Contains('.Synopsis') | should be 'True'
                

            }

            It "Function $($modulefunction.Name) Has show-help comment block has an example" {

                $modulefunction.Definition.Contains('.EXAMPLE') | should be 'True'
            }

            It "Function $($modulefunction.Name) Is an advanced function" {

                $modulefunction.CmdletBinding | should be 'True'
                $modulefunction.Definition.Contains('param') -or  $modulefunction.Definition.Contains('Param') | should be 'True'
            }
            }
        }
    }
 }
}

if ($scripts.count -gt 0) {
Describe "Testing all Scripts in this Repo to be be correctly formatted" {

    foreach($Script in $Scripts)
    {

    Context "Testing Script  - $($Script.BaseName) for Standard Processing" {
    
          It "Is valid Powershell (Has no script errors)" {

                $contents = Get-Content -Path $script.FullName -ErrorAction Stop
                $errors = $null
                $null = [System.Management.Automation.PSParser]::Tokenize($contents, [ref]$errors)
                $errors.Count | Should Be 0
            }
            
     It 'passes the PSScriptAnalyzer without Errors' {
        (Invoke-ScriptAnalyzer -Path $script.FullName -Severity Error).Count | Should Be 0
    }

     It 'passes the PSScriptAnalyzer with less than 10 Warnings excluding PSUseShouldProcessForStateChangingFunctions Rule as it is currently Pants!' {
        (Invoke-ScriptAnalyzer -Path $script.FullName -Severity Warning -ExcludeRule PSUseShouldProcessForStateChangingFunctions).Count | Should BeLessThan 10 
    }

    It "Has show-help comment block" {

                $script.FullName | should contain '<#'
                $script.FullName | should contain '#>'
            }

            It "Has show-help comment block has a synopsis" {

                $script.FullName | should contain '\.SYNOPSIS'
            }

            It "Has show-help comment block has an example" {

                $script.FullName | should contain '\.EXAMPLE'
            }

            It "Is an advanced function" {

                $script.FullName | should contain 'function'
                $script.FullName | should contain 'cmdletbinding'
                $script.FullName | should contain 'param'
            }
            }

        }
    }
} 

