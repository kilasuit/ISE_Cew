# ISE_Cew  - Archived
ISE_Cew is an addon for PowerShell ISE that simplifies the workflow for Script & Module Creation.

CEW stands for Creation Efficency Workflow

It does so by making use of the following required PSDrives

Scripts-WIP

Modules-WIP

ISE_Cew makes use of Git, Pester & PSScriptAnalyzer and automates the creation of the following

* Git Repo for the Script or Module that is being worked on - this allows you to then publish (with all the Commit history) to GitHub once you have completed the work on the Script or the Module. 
* Creation of a standard suite of Pester tests based on the included ISE_Cew.default.tests.ps1
* A set of simple Keyboard Shortcuts to enhance and simplify the overall Script & Module Creation Workflow
     
     These include
    * Ctrl+Shift+S      - Save-AllNamedFiles
    * Ctrl+Alt+S        - Save-AllUnnamedFiles -GeneralModuleDetails $psd1
    * Ctrl+Shift+Alt+S  - Save-CurrentISEFile
    * F6                - AlignEquals
    * F7                - CleanWhitespace
