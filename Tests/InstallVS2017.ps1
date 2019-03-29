Configuration InstallVS2017 {

    Import-DscResource -ModuleName PSDesiredStateConfiguration, xSetupVisualStudio

    Node localhost {
        
        LocalConfigurationManager
        {
            ConfigurationMode = 'ApplyOnly'
            RebootNodeIfNeeded = $true
        }

        xSetupVisualStudio installVisualStudio {
            ProductName = 'Visual Studio Professional 2017'
            Ensure = 'Present'                      
        }

    }
}

InstallVS2017 -OutputPath .\ -Verbose
Start-DscConfiguration -Wait -Verbose -debug -Path .\ -Force
