#Import-Module "..\DSCResources\xSetupVisualStudio\xSetupVisualStudio.psm1" -Force -Global

Using Module "..\DSCResources\xVisualStudio\xVisualStudio.psm1"

# Test install visual studio code
$s  = [xVisualStudio]::new()
$s.Ensure = 'Present';
$s.ProductName = 'Visual Studio Professional 2017'

$isPresent = $s.Test()
if(-not $isPresent){
    $s.Set()
}
