Function Request-YesOrNo { 
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