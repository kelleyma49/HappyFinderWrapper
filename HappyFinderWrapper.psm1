Function Get-ShortName
{
	param($path)
	$fso = New-Object -ComObject Scripting.FileSystemObject
	 if ($path.psiscontainer)
		{$fso.getfolder($path.fullname).ShortName
	} else {
	  $fso.getfile($path.fullname).ShortName
	} 
}

<#
	My Function
#>
function Invoke-HappyFinder {
	param($BasePath=$null)

	$HfPath = Join-Path $env:GOPATH 'bin\hf.exe' 

	if ($BasePath -eq $null) {
		$BasePath = $PWD.Path
	}

	$batScriptPath = Join-Path $PSScriptRoot 'setenvvar.bat'
	$tmpFilePath = [System.IO.Path]::GetTempFileName()
	$batShort = Get-ShortName (Get-ChildItem $batScriptPath)
	$tmpShort = Get-ShortName (Get-ChildItem $tmpFilePath)
	& $HfPath $BasePath "$batShort $tmpShort" 
	Remove-Item $tmpFilePath
}

Export-ModuleMember -Function 'Invoke-HappyFinder'