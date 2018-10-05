[System.Console]::ForegroundColor = "white"
#[System.Console]::BackgroundColor = "DarkBlue"
$console = $host.UI.RawUI
$colors = $host.PrivateData
$console.WindowTitle = "Marks Profile"
$colors.VerboseForegroundColor = "white"
$colors.VerboseBackgroundColor = "blue"
$colors.WarningForegroundColor = "yellow"
$colors.WarningBackgroundColor = "darkgreen"
$colors.ErrorForegroundColor = "white"
$colors.ErrorBackgroundColor = "red"

$MaximumHistoryCount = 10000

$varHomeDrive = Join-Path ([Environment]::GetFolderPath([Environment+SpecialFolder]::MyDocuments)) -ChildPath '.\WindowsPowershell\'
#Browser Directory
#TODO: THIS IS HARDCODED
$varBrowser = 'C:\Program Files\Mozilla Firefox\firefox.exe'
#The alias you want to use for the broswer extension(example:chrome)
$varBrowserAlias = 'firefox'
#Powershell Script Directory
$varScriptDir = Join-Path ([Environment]::GetFolderPath([Environment+SpecialFolder]::MyDocuments)) -ChildPath '.\WindowsPowerShell\scripts\'
$varModulesDir = Join-Path ([Environment]::GetFolderPath([Environment+SpecialFolder]::MyDocuments)) -ChildPath '.\WindowsPowerShell\Modules\'

New-PSDrive -Name Scripts -PSProvider FileSystem -Root $varScriptDir
New-PSDrive -Name Modules -PSProvider FileSystem -Root $varModulesDir

Set-Alias -name $varBrowserAlias -Value $varBrowser
New-Alias -name nu -Value Invoke-NormalUser
New-Alias -name su -Value Invoke-SuperUser

Set-Location $varHomeDrive


#Anything past this point will be read into the shell (KEEP THIS CLEAN AND SMALL)
$PSVersionTable
Set-PSDebug -Strict


function TestMessages {
    #Output for testing the shell color style, just uncomment to test
    Write-Output "This is a test message."
    Write-Verbose "This is a verbose message." -Verbose
    Write-Warning "This is a warning message."
    Write-Error "This is an error message."
}
function uptime {
	Get-WmiObject win32_operatingsystem | select csname, @{LABEL='LastBootUpTime';
	EXPRESSION={$_.ConverttoDateTime($_.lastbootuptime)}}
}

function reload-profile {
	& $profile
}

function find-file($name) {
	ls -recurse -filter "*${name}*" -ErrorAction SilentlyContinue | foreach {
		$place_path = $_.directory
		echo "${place_path}\${_}"
	}
}

function print-path {
	($Env:Path).Split(";")
}

function unzip ($file) {
	$dirname = (Get-Item $file).Basename
	echo("Extracting", $file, "to", $dirname)
	New-Item -Force -ItemType directory -Path $dirname
	expand-archive $file -OutputPath $dirname -ShowProgress
}


#Prompt Transcripts
Write-Verbose ("[{0}] Initialize Transcript" -f (Get-Date).ToString()) -Verbose
If ($host.Name -eq "ConsoleHost") {

    $transcripts = $varHomeDrive + 'Transcripts\Powershell'

    If (-Not (Test-Path $transcripts)) {

        New-Item -path $transcripts -Type Directory | out-null

    }

    $global:TRANSCRIPT = ("{0}\PSLOG_{1:dd-MM-yyyy}.txt" -f $transcripts, (Get-Date))

    Start-Transcript -Path $transcript -Append

    Get-ChildItem $transcripts | Where {

        $_.LastWriteTime -lt (Get-Date).AddDays(-14)

    } | Remove-Item -Force -ea 0

}

function prompt {
    $a = get-date
    $id = 1
    $historyItem = get-history -count 1
    if ($historyitem) {

        $id = $historyItem.id + 1

    }

    write-host -foregroundcolor black "`n[$(get-location)]"
    write-host "[" -noNewLine
    write-host -foregroundcolor Green -backgroundcolor Black $id -noNewLine
    write-host "]" -noNewLine
    write-host "[" -noNewLine
    write-host  -noNewLine $a.ToShortTimeString()
    write-host "]" -noNewLine
    #	write-host $($(Get-Location).Path.replace($home,"~").replace("\","/")) -foreground White -background Black -noNewLine
    write-host $(if ($nestedpromptlevel -ge 1) { '>>' }) -noNewLine

    return "> "
    "`b"
}
