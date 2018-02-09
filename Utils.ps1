#
# Utils.ps1
#

function Do-Unescape([Parameter(Mandatory, ValueFromPipeline)][String] $json) {
  ($json -Split '\n' |
    % {
	  # unescape special characters if not in label condition
      if ($_ -NotMatch 'defaultLabelCondition') {
		  $line = [System.Text.RegularExpressions.Regex]::Unescape($_) 
      }
	  else {
		  # even label conditions have some special characters need replaced
		  $line = $_ -replace '\\u003e0', '>0'
		  $line = $_ -replace '\\u0026', '&' `
					 -replace '\\u003e', '>'
	  }
      $line
  }) -Join "`n"
}

function Remove-Var([Parameter(Mandatory, ValueFromPipeline)][String] $json) {
  $counter = 0
  ($json -Split '\n' |
    % {
		if ($counter -eq 0)
		{
		  $line = $_ -replace 'var _clientSpecificConfigSettings = {', '{'
		}
	    else {
			$line = $_
		}
	  $counter++
      $line
  }) -Join "`n"
}

function Append-Var([Parameter(Mandatory, ValueFromPipeline)][String] $json) {
  $counter = 0
  ($json -Split '\n' |
    % {
		if ($counter -eq 0)
		{
		  $line = $_ -replace , '{', 'var _clientSpecificConfigSettings = {'
		}
	    else {
			$line = $_
		}
	  $counter++
      $line
  }) -Join "`n"
}