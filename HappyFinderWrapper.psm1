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
	& $HfPath $BasePath "$batScriptPath $tmpFilePath"
	$results = @()
	Get-Content $tmpFilePath | ForEach-Object {
		$results += $_
	}	
	Remove-Item $tmpFilePath

	# skip first item as it's the name of the tmp file:
	if ($results.Length -ge 2) {
		return $results[1..($results.Length-1)]
	}
}

function Get-BufferState {
	param([ref]$line,[ref]$cursor)
	$lineTmp = $null
	$cursorTmp = $null
	[Microsoft.PowerShell.PSConsoleReadline]::GetBufferState([ref]$lineTmp, [ref]$cursorTmp)
	$line.Value = $lineTmp
	$cursor.Value = $cursorTmp
}

function Find-CurrentPath {
	param([ref]$leftCursor,[ref]$rightCursor)
	$line = $null
	$cursor = $null
	Get-BufferState ([ref]$line) ([ref]$cursor)
	for ($leftCursor = $cursor;$leftCursor -ge 0;$leftCursor--) {
		if ($line[$leftCursor] -eq " ") {
			for ($leftCursorQuote = $leftCursor;$leftCursorQuote -ge 0;$leftCursorQuote--) {
				if (($line[$leftCursorQuote] -eq '"') -and (($leftCursorQuote -le 0) -or ($line[$leftCursorQuote-1] -ne '"'))) {
					$leftCursor = $leftCursorQuote + 1
				}
				elseif (($line[$leftCursorQuote] -eq "'") -and (($leftCursorQuote -le 0) -or ($line[$leftCursorQuote-1] -ne "'"))) {
					$leftCursor = $leftCursorQuote + 1
				}
			}
			break
		}
	}
	for ($rightCursor = $cursor;$rightCursor -lt $line.Length;$rightCursor++) {
		if ($line[$rightCuror] -eq " ") {
			for ($rightCursorQuote = $rightCursor;$rightCursorQuote -lt $line.Length;$rightCursorQuote++) {
				if (($line[$rightCursorQuote] -eq '"') -and (($rightCursorQuote -gt $line.Length) -or ($line[$rightCursorQuote+1] -ne '"'))) {
					$rightCursor = $rightCursorQuote - 1
				}
				elseif (($line[$rightCursorQuote] -eq "'") -and (($rightCursorQuote -gt $line.Length) -or ($line[$rightCursorQuote+1] -ne "'"))) {
					$rightCursor = $rightCursorQuote - 1
				}
			}
			break
		}
	}
	return $line[$leftCursor..$rightCursor]
}

function Invoke-HappyFinderPsReadlineHandler {
	$leftCursor = $null
	$rightCursor = $null
	$currentPath = Find-CurrentPath ([ref]$leftCursor) ([ref]$rightCursor)
	#$result = Invoke-HappyFinder $currentPath
	$result = 'c:\tree'
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