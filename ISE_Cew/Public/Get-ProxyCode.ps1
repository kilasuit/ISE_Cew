Function Get-ProxyCode {
<#
        .SYNOPSIS
        Used to get Proxy Code from a function
         
        .DESCRIPTION
        Used to get Proxy Code from a function
        
        .EXAMPLE
        gpc Get-Command | nt
        
        .EXAMPLE
        Get-ProxyCode Get-Command | New-IseTab
                        
        .NOTES
        AUTHOR
        Dave Wyatt
        LICENSE
        MIT 
        
      #>
    [CmdletBinding()]
    [OutputType([String])]
    param (
        [Parameter(Mandatory=$true, Position=0)]
        [System.String]
        $Name,
        [Parameter(Mandatory=$false,Position=1)]
        [System.Management.Automation.CommandTypes]
        $CommandType
    )
    process {
        $command = $null
        if ($PSBoundParameters['CommandType']) {
            $command = $ExecutionContext.InvokeCommand.GetCommand($Name, $CommandType)
        } else {
            $command = (Get-Command -Name $Name)
        }


        # Add a function header and indentation to the output of ProxyCommand::Create

        $MetaData = New-Object System.Management.Automation.CommandMetaData ($command)
        $code = [System.Management.Automation.ProxyCommand]::Create($MetaData)

        $sb = New-Object -TypeName System.Text.StringBuilder

        $sb.AppendLine("function $($command.Name)") | Out-Null
        $sb.AppendLine('{') | Out-Null

        foreach ($line in $code -split '\r?\n') {
            $sb.AppendLine('    {0}' -f $line) | Out-Null
        }

        $sb.AppendLine('}') | Out-Null

        $sb.ToString()
    }

}