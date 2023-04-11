<#
.SYNOPSIS
    Monitors 5 directories and moves files among them to maintain an approximately equal number of files in each directory.

.AUTHOR
    Oushi the Hacker aka Justin Ormsby - justinormsby.mail@gmail.com with contributions from OpenAI's ChatGPT 4

.DESCRIPTION
    This script monitors 5 directories and moves files among them to ensure that each directory has approximately the same number
    of files. If a file with the same name already exists in the destination directory, the script chooses a different directory.
#>

# Set the paths to the 5 directories to be monitored
$directories = @(
    "C:\Directory1",
    "C:\Directory2",
    "C:\Directory3",
    "C:\Directory4",
    "C:\Directory5"
)

# Function to retrieve file counts in each directory
function Get-FileCounts {
    $fileCounts = @()
    foreach ($directory in $directories) {
        $fileCount = (Get-ChildItem -Path $directory -File).Count
        $fileCounts += $fileCount
    }
    return $fileCounts
}

# Function to move files between directories to balance file counts
function Move-FilesToBalance {
    $fileCounts = Get-FileCounts
    $averageFileCount = [math]::Round(($fileCounts | Measure-Object -Sum).Sum / $fileCounts.Length)

    for ($i = 0; $i -lt $fileCounts.Length; $i++) {
        if ($fileCounts[$i] -gt $averageFileCount) {
            $filesToMove = Get-ChildItem -Path $directories[$i] -File | Select-Object -First ($fileCounts[$i] - $averageFileCount)

            foreach ($file in $filesToMove) {
                $availableDestinations = (0..($directories.Length - 1)) | Where-Object { $_ -ne $i } | ForEach-Object {
                    $destinationPath = Join-Path -Path $directories[$_] -ChildPath $file.Name
                    if (-not (Test-Path -Path $destinationPath)) { $_ }
                }

                if ($availableDestinations) {
                    $destinationIndex = $availableDestinations | Get-Random
                    Move-Item -Path $file.FullName -Destination $directories[$destinationIndex]
                }
            }
        }
    }
}

# Set the monitoring interval in seconds
$monitoringInterval = 60

# Main loop to run the balancing function at the specified interval
while ($true) {
    Move-FilesToBalance
    Start-Sleep -Seconds $monitoringInterval
}
