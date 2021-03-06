Function New-ISETab { 
<#
        .SYNOPSIS
        Creates a New ISE Tab
         
        .DESCRIPTION
        Creates a New ISE Tab
        
        .EXAMPLE
        nt
        
        .EXAMPLE
        Get-ProxyCode Get-Command | New-IseTab
                        
        .NOTES
        AUTHOR
        Dave Wyatt
        LICENSE
        MIT 
        
      #>
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions','')]
    param(
        [Parameter(Mandatory=$false, Position=1, ValueFromPipeline = $true)]
        [System.String[]]
        $Text,

        [Parameter(Mandatory=$false)]
        [System.Object]
        $Separator
    )

    begin {
        if (!$psISE) {
            throw 'This command can only be run from within the PowerShell ISE.'
        }

        if ((!$PSBoundParameters['Separator']) -and (Test-Path 'variable:\OFS')) {
            $Separator = $OFS
        }

        if (!$Separator) { $Separator = "`r`n" }

        $tab = $psISE.CurrentPowerShellTab.Files.Add()

        $sb = New-Object System.Text.StringBuilder
    }

    process {
        foreach ($str in @($Text)) {
            if ($sb.Length -gt 0) {
                $sb.Append(("{0}{1}" -f $Separator, $str)) | Out-Null
            } else {
                $sb.Append($str) | Out-Null
            }
        }
    }

    end {
        $tab.Editor.Text = $sb.ToString()
        $tab.Editor.SetCaretPosition(1,1)
    }

}