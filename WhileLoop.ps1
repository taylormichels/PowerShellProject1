#
# WhileLoop.ps1
#

$array = 'one', 'two', 'three'
$counter = 3
While( $array.Count -gt 0) {
	Write-Host "$($array.Count)"
	if ($counter -gt 0) {
		$tmp = $array[$counter-1]
		$array = $array -ne $tmp
	}
	$counter--
}
Write-Host "$('fin')"
