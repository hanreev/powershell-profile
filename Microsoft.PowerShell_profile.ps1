# Shows navigable menu of all options when hitting Tab
Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete

# Autocompletion for arrow keys
Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward

# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}

$Exts = (
  @{Path = "$PSScriptRoot\Scripts\Ext.Composer.ps1"; Command = "composer" },
  @{Path = "$PSScriptRoot\Scripts\Ext.Git.ps1"; Command = "git" },
  @{Path = "$PSScriptRoot\Scripts\Ext.Laravel.ps1"; Command = "php" },
  @{Path = "$PSScriptRoot\Scripts\Ext.Yarn.ps1"; Command = "yarn" }
)

foreach ($Ext in $Exts) {
  $Ok = Test-Path $Ext.Path
  if ($Ext.Command) {
    Get-Command $Ext.Command 2>&1> $null
    $Ok = $? -and $Ok
  }
  if ($Ok) {
    Import-Module -Global $Ext.Path
  }
}

function Get-PyVenvConfig {
  param (
    [String]
    $ConfigDir
  )

  # Ensure the file exists, and issue a warning if it doesn't (but still allow the function to continue).
  $pyvenvConfigPath = Join-Path -Resolve -Path $ConfigDir -ChildPath 'pyvenv.cfg' -ErrorAction Continue

  # An empty map will be returned if no config file is found.
  $pyvenvConfig = @{ }

  if ($pyvenvConfigPath) {
    $pyvenvConfigContent = Get-Content -Path $pyvenvConfigPath

    $pyvenvConfigContent | ForEach-Object {
      $keyval = $PSItem -split "\s*=\s*", 2
      if ($keyval[0] -and $keyval[1]) {
        $val = $keyval[1]

        # Remove extraneous quotations around a string value.
        if ("'""".Contains($val.Substring(0, 1))) {
          $val = $val.Substring(1, $val.Length - 2)
        }

        $pyvenvConfig[$keyval[0]] = $val
      }
    }
  }
  return $pyvenvConfig
}

function prompt_separator {
  param (
    [Parameter(Mandatory = $true)]
    [ValidateSet("Black", "DarkBlue", "DarkGreen", "DarkCyan", "DarkRed", "DarkMagenta", "DarkYellow", "Gray", "DarkGray", "Blue", "Green", "Cyan", "Red", "Magenta", "Yellow", "White")]
    [String]
    $Fg,
    [ValidateSet("Black", "DarkBlue", "DarkGreen", "DarkCyan", "DarkRed", "DarkMagenta", "DarkYellow", "Gray", "DarkGray", "Blue", "Green", "Cyan", "Red", "Magenta", "Yellow", "White")]
    [String]
    $Bg
  )
  if ($Bg) {
    Write-Host -Object "" -NoNewline -ForegroundColor $Fg -BackgroundColor $Bg
  }
  else {
    Write-Host -Object "" -NoNewline -ForegroundColor $Fg
  }
}

# Prompt
$env:VIRTUAL_ENV_DISABLE_PROMPT = $true
function global:prompt {
  $Success = $?

  $VenvDir = $env:VIRTUAL_ENV
  if ($env:VIRTUAL_ENV) {
    $pyvenvCfg = Get-PyVenvConfig -ConfigDir $VenvDir
    if ($pyvenvCfg -and $pyvenvCfg.prompt) {
      $Prompt = $pyvenvCfg.prompt;
    }
    else {
      $Prompt = Split-Path -Path $VenvDir -Leaf
    }
    Write-Host -NoNewline -ForegroundColor Black -BackgroundColor DarkYellow " $Prompt "
  }

  if (!$Success) {
    Write-Host -Object " ✘" -NoNewline -ForegroundColor Red -BackgroundColor DarkGray
  }

  ## User
  $IsAdmin = (New-Object Security.Principal.WindowsPrincipal ([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
  Write-Host -Object "$(if ($IsAdmin) {' ☠'}) $env:USERNAME " -NoNewline -ForegroundColor White -BackgroundColor DarkGray
  prompt_separator -Fg DarkGray -Bg Blue

  ## Path
  $Drive = $pwd.Drive.Name
  $Pwds = $pwd -split "\\" | Where-Object { -Not [String]::IsNullOrEmpty($_) }
  $PwdPath = if ($Pwds.Count -gt 3) {
    "..\$($Pwds[-2])\$($Pwds[-1])"
  }
  elseif ($Pwds.Count -eq 3) {
    "$($Pwds[-2])\$($Pwds[-1])"
  }
  elseif ($Pwds.Count -eq 2) {
    $Pwds[-1]
  }
  else { "" }

  Write-Host -Object " $Drive`:\$PwdPath " -NoNewline -ForegroundColor Black -BackgroundColor Blue

  $Branch = $(git_current_branch) 2> $null
  if ($Branch) {
    $Bg = "Green"
    $Prefix = ""
    $Suffix = ""
    $CurrentBranch = $(git branch --show-current)
    if (!$CurrentBranch) { $Prefix = "➦" }
    $IsDirty = $(git status --porcelain --ignore-submodules)
    if ($IsDirty) { $Bg = "Yellow"; $Suffix = "±" }

    prompt_separator -Fg Blue -Bg $Bg
    Write-Host -Object " $Prefix $Branch$Suffix " -NoNewline -ForegroundColor Black -BackgroundColor $Bg
    prompt_separator -Fg $Bg
  }
  else {
    prompt_separator -Fg Blue
  }

  return " "
}

function which {
  for ($i = 0; $i -lt $args.Count; $i++) {
    $result = Get-Command $args[$i]
    $retval = $result.Source
    if (!$retval) {
      if ($result.ResolvedCommand) {
        $retval = $result.ResolvedCommand.Source
        if ($retval.StartsWith("Microsoft.PowerShell")) {
          $retval = "$Command -> $($result.ResolvedCommand.Name)"
        }
      }
      else {
        $retval = $result.Name
      }
    }
    Write-Host $retval
  }
}

function touch {
  param (
    [Parameter(Mandatory = $true)]
    [String]
    $FilePath
  )

  if (Test-Path $FilePath) {
    (Get-ChildItem $FilePath).LastWriteTime = Get-Date
  }
  else {
    New-Item -ItemType file $FilePath > $null
  }
}

function wt_admin {
  Start-Process -Verb RunAs wt.exe
}
