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

$script:PSReadlineHandlerChord = $null
$MyInvocation.MyCommand.ScriptBlock.Module.OnRemove =
{
	if ($script:PSReadlineHandlerChord -ne $null) {
		Remove-PSReadlineKeyHandler $script:PSReadlineHandlerChord
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
	"& $HfPath $BasePath '$batScriptPath $tmpFilePath'" | out-file C:\tools\shit.txt -Append -Encoding ascii
	& $HfPath $BasePath "$batScriptPath $tmpFilePath"
	$results = @()
	Get-Content $tmpFilePath | ForEach-Object {
		$results += Join-Path $BasePath $_.Trim()
	}	
	Remove-Item $tmpFilePath

	# skip first item as it's the name of the tmp file:
	if ($results.Length -ge 2) {
		return $results[1..($results.Length-1)]
	}
}

function Find-CurrentPath {
	param([string]$line,[int]$cursor,[ref]$leftCursor,[ref]$rightCursor)
	
	if ($line.Length -eq 0) {
		$leftCursor.Value = $rightCursor.Value = 0
		return $null
	}

	if ($cursor -ge $line.Length) {
		$leftCursorTmp = $cursor - 1
	} else {
		$leftCursorTmp = $cursor
	}
	for (;$leftCursorTmp -ge 0;$leftCursorTmp--) {
		if ([string]::IsNullOrWhiteSpace($line[$leftCursorTmp])) {
			if (($leftCursorTmp -lt $cursor) -and ($leftCursorTmp -lt $line.Length-1)) {
				$leftCursorTmpQuote = $leftCursorTmp - 1
				$leftCursorTmp = $leftCursorTmp + 1
			} else {
				$leftCursorTmpQuote = $leftCursorTmp
			}
			for (;$leftCursorTmpQuote -ge 0;$leftCursorTmpQuote--) {
				if (($line[$leftCursorTmpQuote] -eq '"') -and (($leftCursorTmpQuote -le 0) -or ($line[$leftCursorTmpQuote-1] -ne '"'))) {
					$leftCursorTmp = $leftCursorTmpQuote
					break
				}
				elseif (($line[$leftCursorTmpQuote] -eq "'") -and (($leftCursorTmpQuote -le 0) -or ($line[$leftCursorTmpQuote-1] -ne "'"))) {
					$leftCursorTmp = $leftCursorTmpQuote
					break
				}
			}
			break
		}
	}
	for ($rightCursorTmp = $cursor;$rightCursorTmp -lt $line.Length;$rightCursorTmp++) {
		if ([string]::IsNullOrWhiteSpace($line[$rightCursorTmp])) {
			if ($rightCursorTmp -gt $cursor) {
				$rightCursorTmp = $rightCursorTmp - 1
			}
			for ($rightCursorTmpQuote = $rightCursorTmp+1;$rightCursorTmpQuote -lt $line.Length;$rightCursorTmpQuote++) {
				if (($line[$rightCursorTmpQuote] -eq '"') -and (($rightCursorTmpQuote -gt $line.Length) -or ($line[$rightCursorTmpQuote+1] -ne '"'))) {
					$rightCursorTmp = $rightCursorTmpQuote 
					break
				}
				elseif (($line[$rightCursorTmpQuote] -eq "'") -and (($rightCursorTmpQuote -gt $line.Length) -or ($line[$rightCursorTmpQuote+1] -ne "'"))) {
					$rightCursorTmp = $rightCursorTmpQuote
					break
				}
			}
			break
		}
	}
	if ($leftCursorTmp -lt 0 -or $leftCursorTmp -gt $line.Length-1) { $leftCursorTmp = 0}
	if ($rightCursorTmp -ge $line.Length) { $rightCursorTmp = $line.Length-1 }
	$leftCursor.Value = $leftCursorTmp
	$rightCursor.Value = $rightCursorTmp
	$str = -join ($line[$leftCursorTmp..$rightCursorTmp])
	return $str
}

function Invoke-HappyFinderPsReadlineHandler {
	$leftCursor = $null
	$rightCursor = $null
	$line = $null
	$cursor = $null
	[Microsoft.PowerShell.PSConsoleReadline]::GetBufferState([ref]$line, [ref]$cursor)
	$currentPath = Find-CurrentPath $line $cursor ([ref]$leftCursor) ([ref]$rightCursor)
	if (!(Test-Path $currentPath)) {
		$currentPath = $null
	}
	$currentPath | Out-File c:\tools\shit.txt -Encoding ascii
	"left: $leftCursor ; right: $rightCursor" | Out-File c:\tools\shit.txt -Append -Encoding ascii
	$result = Invoke-HappyFinder $currentPath
	if ($result -ne $null) {
		$str = $result -join ','
		[Microsoft.PowerShell.PSConsoleReadLine]::Replace($leftCursor,$rightCursor-$leftCursor,$str)
	}
}

# install PSReadline shortcut:
if (Get-Module -ListAvailable -Name PSReadline) {
	if ($args.Length -ge 1) {
		$script:PSReadlineHandlerChord = $args[0] 
	} else {
		$script:PSReadlineHandlerChord = 'Ctrl+T'
	}
	if (Get-PSReadlineKeyHandler -Bound | Where Key -eq $script:PSReadlineHandlerChord) {
		Write-Warning ("PSReadline chord {0} already in use - keyboard handler not installed" -f $script:PSReadlineHandlerChord)
	} else {
		Set-PSReadlineKeyHandler -Key Ctrl+T -BriefDescription "InvokeHappyFinder" -ScriptBlock  {
			Invoke-HappyFinderPsReadlineHandler
		}
	} 
} else {
	Write-Warning "PSReadline module not found - keyboard handler not installed" 
}

Export-ModuleMember -Function 'Invoke-HappyFinder','Invoke-HappyFinderPsReadlineHandler'