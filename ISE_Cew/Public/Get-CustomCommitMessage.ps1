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