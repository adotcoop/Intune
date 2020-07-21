# Intune
A collection of scripts I have found useful while moving from ConfigMgr to Intune.

## Scripts

* Install-CompanyPortal.ps1

  When the SCCM client gets installed it installs a control panel, but for some reason enrolling in Intune doesn't install Company Portal automatically. There are two options to deploy Company Portal, use Microsoft Store for Business or make it available. Neither of these made sense to me so, borrowing heavily from code from Oliver Kieselbach, here is a way to automatically install the Company Portal app via Powershell.


## Disclaimer

All content is provided "as is", without warranty of any kind. Any script or code in this repository should not be considered production ready, so test these scripts in a test environment.
