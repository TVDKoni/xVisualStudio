enum Ensure
{
       Absent
       Present
}

[DscResource()]
class xSetupVisualStudio 
{

       [DscProperty(Key)]
       [ValidateSet('Visual Studio Enterprise 2017','Visual Studio Professional 2017','Visual Studio Coomunity 2017','Microsoft Visual Studio Enterprise 2015','Microsoft Visual Studio Professional 2015','Microsoft Visual Studio Community 2015','Microsoft Visual Studio Code')]
       [string] $ProductName

       [DscProperty()]
       [string] $SetupFile
        
       [DscProperty()]
       [string]$InstallationArgs = '/Full'

       [DscProperty()]
       [string] $AdminDeploymentFile    
           
       [DscProperty()]
       [string] $ProductKey

       [DscProperty(Mandatory)]
       [Ensure] $Ensure

       [void] validateArguments(){
            
            if($this.AdminDeploymentFile){
                $this.InstallationArgs = "/AdminFile $($this.AdminDeploymentFile)"
            }
            
            if(-not $this.SetupFile -or (-not (Test-Path $this.SetupFile)))
            {
                
                switch -Exact ($this.ProductName){
                    'Microsoft Visual Studio Enterprise 2015'  {
                        $this.SetupFile = 'https://download.microsoft.com/download/C/7/8/C789377D-7D49-4331-8728-6CED518956A0/vs_enterprise_ENU.exe'
                    }
                    'Microsoft Visual Studio Professional 2015' {
                        $this.SetupFile = 'https://download.microsoft.com/download/D/2/8/D28D3B41-BF4A-409A-AFB5-2C82C216D4E1/vs_professional_ENU.exe'
                    }
                    'Microsoft Visual Studio Community 2015' {
                        $this.SetupFile = 'https://download.microsoft.com/download/D/2/3/D23F4D0F-BA2D-4600-8725-6CCECEA05196/vs_community_ENU.exe'
                    }
                    'Visual Studio Enterprise 2017'  {
                        $this.SetupFile = 'https://download.visualstudio.microsoft.com/download/pr/3f2ebcc9-af11-4059-8c29-be4326fd9ca5/774c73c98597e433c92f50aa8dcafaeb/vs_enterprise.exe'
                    }
                    'Visual Studio Professional 2017' {
                        $this.SetupFile = 'https://download.visualstudio.microsoft.com/download/pr/90ff83d0-fc94-4d2d-99bd-2e6ec872fcf5/a73e7aaf20f350c5345c7f6a315c3934/vs_professional.exe'
                    }
                    'Visual Studio Community 2017' {
                        $this.SetupFile = 'https://download.visualstudio.microsoft.com/download/pr/cd9a58d6-b7f7-40a5-b2ee-b5f6b1f49fbb/d70da2680dd650f2769a397a257caf01/vs_community.exe'
                    }
                    'Microsoft Visual Studio Code' {
                        $this.SetupFile = 'https://go.microsoft.com/fwlink/?Linkid=852157'
                    }
                    default { 
                        throw "Unsupported"
                    }
                }
                
            }            
            

            if($this.SetupFile -and $this.SetupFile.StartsWith('http')){
                Write-Verbose "Downloading installation files from $($this.SetupFile)"
                $target = Join-Path $env:TEMP "VS_Setup.exe"
                [System.Net.WebClient]::new().DownloadFile($this.SetupFile, $target);
                $this.SetupFile = $target;
				if ($this.ProductName.EndsWith('2017')){
					$layoutDir = Join-Path $env:TEMP "VSlayout"
					& $target --layout $layoutDir --add Microsoft.VisualStudio.Workload.ManagedDesktop --add Microsoft.VisualStudio.Workload.NetWeb --add Component.GitHub.VisualStudio --add Microsoft.VisualStudio.Workload.Office --includeOptional --lang en-US --quiet
					while (-Not (Get-Process Setup -ErrorAction SilentlyContinue)) { Start-Sleep 2 }
					Wait-Process Setup
					$this.SetupFile = Join-Path $layoutDir "vs_setup.exe"
				}
            }

            if(-not $this.SetupFile -or -not (Test-Path $this.SetupFile)){            
                throw "Setup file cannot be fetched. URLs for downloading are wrong or you've specified an invalid target in SetupFile - $($this.SetupFile)"
            }
            
            if(-not $this.AdminDeploymentFile -and -not $this.InstallationArgs)
            {
                throw "Invalid arguments! Specify either a deployment file or InstallationArgs"
            }
            
       }



       [xVisualStudio] Get()
       {
            Write-Debug "Getting package";                        
            $this.Ensure = [Ensure]::Absent;            

            if($this.HasInstalledApp($this.ProductName)){
                $this.Ensure = [Ensure]::Present;
            }
            return $this;            

       }

       [void] Set()
       {
            $this.validateArguments();

            if($this.Ensure -eq [Ensure]::Present)
            {                
                $logFile = Join-path $Env:Temp "VSInstallation.log"

                if($this.ProductName -eq 'Microsoft Visual Studio Code'){
                    $args = "/SILENT /Log $logFile"
                } else {
					if ($this.ProductName.EndsWith('2017')){
						$args = "--quiet --wait --norestart"
						if($this.ProductKey)
						{
							$args = $args + " --productKey $this.ProductKey"
						}
					} else {
						$args = "/Quiet /NoRestart $($this.InstallationArgs) /Log $logFile"
						if($this.ProductKey)
						{
							$args = $args + " /ProductKey $this.ProductKey"
						}
					}
                }

                Write-Verbose "Starting Visual studio installation with $args " 
                Start-Process -FilePath $this.SetupFile -ArgumentList $args -Wait -NoNewWindow       
                Write-Verbose "Successfully installed VS" 
            }
            else
            {
                if($this.ProductName -ne 'Microsoft Visual Studio Code'){
                    $args = "/Quiet /Force /Uninstall /Log $Env:Temp\VS_Uninstall.log"                
                    Write-Verbose "Starting uninstallation usnig $args" 
                    Start-Process -FilePath $this.SetupFile -ArgumentList $args -Wait -NoNewWindow       
                    Write-Verbose "Uninstalled VS successfully" 
                } else {
                    throw 'Uninstalling VS full edition is not supported yet'
                }
            }
       }

       [bool] Test()
       {
            Write-Verbose "Testing if $($this.ProductName) exists"
            return $this.HasInstalledApp($this.ProductName);
       }

       [bool] HasInstalledApp($displayName){            
            return $this.GetInstalledApps().DisplayName -contains $displayName;            
       }

       [PSObject[]] GetInstalledApps()
       {            
            $Sys64Path = 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall'
            $Sys32Path = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall'
            if((Test-Path $Sys64Path)){
                $keys  = Get-childitem $Sys64Path;                
            } else {
                $keys= Get-childitem $Sys32Path;                         
            }
            return $keys|ForEach-Object {   
                $name = $_.GetValue('DisplayName');
                if($name){                            
                    New-Object PSObject -Property @{
                        "DisplayName" = $_.GetValue("DisplayName");
                        "DisplayVersion" = $_.GetValue("DisplayVersion");
                        "UninstallString" = $_.GetValue("UninstallString");
                        "Publisher" = $_.GetValue("Publisher")            
                    }         
                }                   
            }            
       }      
}
