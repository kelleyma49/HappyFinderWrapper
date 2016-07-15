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
	& $HfPath $BasePath "$batScriptPath $tmpFilePath"
	$results = @()
	Get-Content $tmpFilePath | ForEach-Object {
		$results += $_
	}	
	Remove-Item $tmpFilePath

	if ($results.Length -eq 2) {
		return $results[1]	
	} elseif ($results.Length -gt 2) {
		return $results[1..($results.Length-1)]
	}
}

Export-ModuleMember -Function 'Invoke-HappyFinder'