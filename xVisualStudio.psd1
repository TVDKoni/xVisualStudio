@{
# Version number of this module.
moduleVersion = '1.0.1.0'

# ID used to uniquely identify this module
GUID = 'a8f62162-ca16-4f9a-b0e7-5928520b041e'

# Author of this module
Author = 'Trivadis'

# Company or vendor of this module
CompanyName = 'Trivadis'

# Copyright statement for this module
Copyright = '(c) 2019 Trivadis. All rights reserved.'

# Description of the functionality provided by this module
Description = 'This module installs visual studio editions.'

# Minimum version of the Windows PowerShell engine required by this module
PowerShellVersion = '4.0'

# Minimum version of the common language runtime (CLR) required by this module
CLRVersion = '4.0'

# Functions to export from this module
FunctionsToExport = '*'

# Cmdlets to export from this module
CmdletsToExport = '*'

# Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
PrivateData = @{

    PSData = @{

        # Tags applied to this module. These help with module discovery in online galleries.
        Tags = @('DesiredStateConfiguration', 'DSC', 'DSCResourceKit', 'DSCResource')

        # A URL to the license for this module.
        LicenseUri = 'https://github.com/TVDKoni/xVisualStudio/blob/master/LICENSE'

        # A URL to the main website for this project.
        ProjectUri = 'https://github.com/TVDKoni/xVisualStudio'

        # A URL to an icon representing this module.
        # IconUri = ''

        # ReleaseNotes of this module
        ReleaseNotes = '* Converted appveyor.yml to install Pester from PSGallery instead of from Chocolatey.
* Fixes registry not being evaluated correctly.
* Fixes failing tests introduced in changes to Pester 4.
* Change layout of parameters to compile with style guide.

'

    } # End of PSData hashtable

} # End of PrivateData hashtable
}



