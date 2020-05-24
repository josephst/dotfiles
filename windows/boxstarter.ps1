# Description: Boxstarter Script
# Author: Joseph Stahl
# Last Updated: 2019-06-04
#
# URL: https://raw.githubusercontent.com/josephst/win10-boxstarter/master/boxstarter.ps1
# 
# Based on Jess Fraz (https://gist.github.com/jessfraz/7c319b046daa101a4aaef937a20ff41f)
# Microsoft (https://github.com/microsoft/windows-dev-box-setup-scripts)
# Alex Hirsch (https://github.com/W4RH4WK/Debloat-Windows-10/blob/master/scripts/remove-default-apps.ps1)
#
# Install boxstarter:
# 	. { iwr -useb http://boxstarter.org/bootstrapper.ps1 } | iex; get-boxstarter -Force
#
# You might need to set: Set-ExecutionPolicy RemoteSigned
#
# Run this boxstarter by calling the following from an **elevated** command-prompt:
# 	start http://boxstarter.org/package/nr/url?<URL-TO-RAW-GIST>
# OR
# 	Install-BoxstarterPackage -PackageName <URL-TO-RAW-GIST> -DisableReboots
#
# Learn more: http://boxstarter.org/Learn/WebLauncher

#---- TEMPORARY ---
Disable-UAC

Write-Output "Uninstalling default apps"
$apps = @(
    # default Windows 10 apps
    "Microsoft.3DBuilder"
    "Microsoft.Appconnector"
    "Microsoft.BingFinance"
    # "Microsoft.BingNews"
    "Microsoft.BingSports"
    "Microsoft.BingTranslator"
    # "Microsoft.BingWeather"
    #"Microsoft.FreshPaint"
    "Microsoft.Microsoft3DViewer"
    # "Microsoft.MicrosoftOfficeHub"
    "Microsoft.MicrosoftSolitaireCollection"
    "Microsoft.MicrosoftPowerBIForWindows"
    "Microsoft.MinecraftUWP"
    #"Microsoft.MicrosoftStickyNotes"
    "Microsoft.NetworkSpeedTest"
    # "Microsoft.Office.OneNote"
    #"Microsoft.OneConnect"
    # "Microsoft.People"
    "Microsoft.Print3D"
    # "Microsoft.SkypeApp"
    "Microsoft.Wallet"
    #"Microsoft.Windows.Photos"
    # "Microsoft.WindowsAlarms"
    #"Microsoft.WindowsCalculator"
    # "Microsoft.WindowsCamera"
    # "microsoft.windowscommunicationsapps"
    # "Microsoft.WindowsMaps"
    # "Microsoft.WindowsPhone"
    # "Microsoft.WindowsSoundRecorder"
    #"Microsoft.WindowsStore"   # can't be re-installed
    # "Microsoft.XboxApp"
    # "Microsoft.XboxGameOverlay"
    # "Microsoft.XboxGamingOverlay"
    # "Microsoft.XboxSpeechToTextOverlay"
    # "Microsoft.Xbox.TCUI"
    # "Microsoft.ZuneMusic"
    # "Microsoft.ZuneVideo"
    
    
    # Threshold 2 apps
    # "Microsoft.CommsPhone"
    "Microsoft.ConnectivityStore"
    # "Microsoft.GetHelp"
    # "Microsoft.Getstarted"
    # "Microsoft.Messaging"
    "Microsoft.Office.Sway"
    # "Microsoft.OneConnect"
    # "Microsoft.WindowsFeedbackHub"

    # Creators Update apps
    "Microsoft.Microsoft3DViewer"
    #"Microsoft.MSPaint"

    #Redstone apps
    "Microsoft.BingFoodAndDrink"
    "Microsoft.BingTravel"
    "Microsoft.BingHealthAndFitness"
    "Microsoft.WindowsReadingList"

    # Redstone 5 apps
    # "Microsoft.MixedReality.Portal"
    # "Microsoft.ScreenSketch"
    # "Microsoft.XboxGamingOverlay"
    # "Microsoft.YourPhone"

    # non-Microsoft
    # "9E2F88E3.Twitter"
    "PandoraMediaInc.29680B314EFC2"
    "Flipboard.Flipboard"
    "ShazamEntertainmentLtd.Shazam"
    "king.com.CandyCrushSaga"
    "king.com.CandyCrushSodaSaga"
    "king.com.BubbleWitch3Saga"
    "king.com.*"
    "ClearChannelRadioDigital.iHeartRadio"
    # "4DF9E0F8.Netflix"
    "6Wunderkinder.Wunderlist"
    "Drawboard.DrawboardPDF"
    "2FE3CB00.PicsArt-PhotoStudio"
    "D52A8D61.FarmVille2CountryEscape"
    "TuneIn.TuneInRadio"
    "GAMELOFTSA.Asphalt8Airborne"
    #"TheNewYorkTimes.NYTCrossword"
    "DB6EA5DB.CyberLinkMediaSuiteEssentials"
    # "Facebook.Facebook"
    "flaregamesGmbH.RoyalRevolt2"
    "Playtika.CaesarsSlotsFreeCasino"
    "A278AB0D.MarchofEmpires"
    "KeeperSecurityInc.Keeper"
    "ThumbmunkeysLtd.PhototasticCollage"
    "XINGAG.XING"
    "89006A2E.AutodeskSketchBook"
    "D5EA27B7.Duolingo-LearnLanguagesforFree"
    "46928bounde.EclipseManager"
    "ActiproSoftwareLLC.562882FEEB491" # next one is for the Code Writer from Actipro Software LLC
    "DolbyLaboratories.DolbyAccess"
    # "SpotifyAB.SpotifyMusic"
    "A278AB0D.DisneyMagicKingdoms"
    "WinZipComputing.WinZipUniversal"
    "CAF9E577.Plex"  
    "7EE7776C.LinkedInforWindows"
    "613EBCEA.PolarrPhotoEditorAcademicEdition"
    "Fitbit.FitbitCoach"
    "DolbyLaboratories.DolbyAccess"
    "NORDCURRENT.COOKINGFEVER"

    # apps which cannot be removed using Remove-AppxPackage
    #"Microsoft.BioEnrollment"
    #"Microsoft.MicrosoftEdge"
    #"Microsoft.Windows.Cortana"
    #"Microsoft.WindowsFeedback"
    #"Microsoft.XboxGameCallableUI"
    #"Microsoft.XboxIdentityProvider"
    #"Windows.ContactSupport"

    # apps which other apps depend on
    # "Microsoft.Advertising.Xaml"
)

foreach ($app in $apps) {
    Write-Output "Trying to remove $app"

    Get-AppxPackage -Name $app -AllUsers | Remove-AppxPackage -AllUsers

    Get-AppXProvisionedPackage -Online |
        Where-Object DisplayName -EQ $app |
        Remove-AppxProvisionedPackage -Online
}

#--- Enable developer mode on the system ---
Set-ItemProperty -Path HKLM:\Software\Microsoft\Windows\CurrentVersion\AppModelUnlock -Name AllowDevelopmentWithoutDevLicense -Value 1

# fonts
choco install firacode -y
choco install hackfont -y
# choco install inconsolata -y

# common dev tools
# choco install vscode  -y
# don't use choco for vscode (better to do local user install)
choco install git --params "/GitOnlyOnPath /NoAutoCrlf /WindowsTerminal /NoShellIntegration"  -y 
choco install poshgit  -y 
choco install Git-Credential-Manager-for-Windows  -y
choco install python  -y 
py -3 -m pip install -U pip
py -3 -m pip install --user pipenv

# java
# choco install jre8 -y

# web dev
choco install nodejs-lts -y
# choco install yarn -y
choco install visualstudio2017buildtools  -y
choco install visualstudio2017-workload-vctools  -y 
# remember to run `yarn global add windows-build-tools` AS ADMIN after this scrip finishes
# choco install python2 -y # Node.js requires Python 2 to build native modules
choco install hugo -y

# browsers
choco install firefox -y
choco install googlechrome -y

# apps
choco install vlc -y
choco install qbittorrent -y
choco install sumatrapdf.install -y
choco install adobereader -y

# utils
choco install youtube-dl -y
choco install ffmpeg -y
choco install 7zip.install -y
choco install sysinternals -y

# windows features
choco install -y Microsoft-Hyper-V-All -source windowsFeatures
choco install -y Microsoft-Windows-Subsystem-Linux -source windowsFeatures
Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0


# tweaks
# Privacy: Let apps use my advertising ID: Disable
Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo -Name Enabled -Type DWord -Value 0
# Show file extensions
Set-WindowsExplorerOptions -EnableShowFileExtensions
# will expand explorer to the actual folder you're in
# Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name NavPaneExpandToCurrentFolder -Value 1
#adds things back in your left pane like recycle bin
# Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name NavPaneShowAllFolders -Value 1

# Restore Temporary Settings
Enable-UAC
Enable-MicrosoftUpdate
Install-WindowsUpdate -acceptEula
