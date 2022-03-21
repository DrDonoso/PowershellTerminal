Import-Module -Name Terminal-Icons
Import-Module PSReadLine
Import-Module PSFzf
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
oh-my-posh prompt init pwsh --config C:\Users\davidrodr\AppData\Local\Programs\oh-my-posh\themes/tonybaloney.omp.json | Invoke-Expression
