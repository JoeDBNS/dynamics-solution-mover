# Install Power Platform CLI for Windows if not already installed
# https://learn.microsoft.com/en-us/power-platform/developer/cli/introduction


# Get a list of authentication profiles and store them in a variable
$profiles = pac auth list

# Display the profiles in the console
$profiles

# Clean profiles data to use later
$profilesClean = New-Object System.Collections.ArrayList
$profilesClean.Add("new")

if ($profiles.length -gt 1) {
    $profileMaxLength = $profiles[1].length
    $profileDetailsStartIndex = $profiles[1].IndexOf("DATAVERSE") + 10
    $profileDetailsEndIndex = $profileMaxLength - $profileDetailsStartIndex

    for ($i = 1; $i -lt $profiles.Count-1; $i++) {
        $profileClean = New-Object System.Collections.ArrayList
        $profileSplit = New-Object System.Collections.ArrayList(,$profiles[$i].Substring($profileDetailsStartIndex, $profileDetailsEndIndex).Split(" "))

        foreach ($item in $profileSplit) {
            if ($item -ne "") {
                $profileClean.Add($item)| out-null
            }
        }

        $profilesClean.Add($profileClean[0])| out-null
    }
}

# Prompt the user to enter the name of a profile from the list or type "new" to create a new one
$exportChoice = Read-Host "Enter the name of a profile from the list or type 'new' to create a new one you want to Export from"
$exportChoice = $exportChoice.Trim()

# Verify the user entered a valid profile name or "new"
while (!($profilesClean -contains $exportChoice)) {
    $exportChoice = Read-Host "Choice not found. Enter the name of a profile from the list or type 'new' to create a new one you want to Export from"
    $exportChoice = $exportChoice.Trim()
}

# If the user typed "new", prompt them to enter the URL of the environment and create a new profile
if ($exportChoice -eq "new") {
    $url = Read-Host "Enter the URL of the environment"
    $profileName = Read-Host "Enter a Profile Name"
    pac auth create --url $url --name $profileName
    # Get the name of the newly created profile and store it in a variable
    $exportChoice = $profileName
}

# Set the active profile to the one chosen or created
pac auth select --name $exportChoice

# Get a list of solutions from the environment and store them in a variable
$solutions = pac solution list

# Display the solutions in the console
$solutions

# Clean profiles data to use later
$solutionsClean = New-Object System.Collections.ArrayList

if ($solutions.length -gt 1) {
    $solutionUniqueNameEndIndex = $solutions[4].IndexOf("Friendly Name") - 1

    for ($i = 5; $i -lt $solutions.Count-1; $i++) {
        $solutionsClean.Add($solutions[$i].substring(0, $solutionUniqueNameEndIndex).replace(' ', ''))| out-null
    }
}

# Prompt the user to enter the name of a solution from the list
$solutionChoice = Read-Host "Enter the name of a solution from the list"
$solutionChoice = $solutionChoice.Trim()

# Verify the user entered a valid solution name
while (!($solutionsClean -contains $solutionChoice)) {
    $solutionChoice = Read-Host "Choice not found. Enter the name of a solution from the list"
    $solutionChoice = $solutionChoice.Trim()
}

# Get Unix Time Stamp
$dateTime = (Get-Date).ToUniversalTime()
$unixTimeStamp = [System.Math]::Truncate((Get-Date -Date $dateTime -UFormat %s))

# Set Path Variables
$solutionPath = "c:\pac\Solutions\" + $solutionChoice + "-" + $unixTimeStamp + ".zip"

# Export Solution
pac solution export --path $solutionPath --name $solutionChoice --overwrite

# Open Folder Containing Exported Solution
Start-Process -FilePath C:\Windows\explorer.exe -ArgumentList "/e, ""c:\pac\Solutions\"""

# List Auth Profiles
$profiles

# Prompt the user to enter the name of a profile from the list or type "new" to create a new one to Import the solution to
$importChoice = Read-Host "Enter the name of a profile from the list or type 'new' to create a new one to Import the solution to"
$importChoice = $importChoice.Trim()

# Verify the user entered a valid profile name or "new"
while (!($profilesClean -contains $importChoice)) {
    $importChoice = Read-Host "Choice not found. Enter the name of a profile from the list or type 'new' to create a new one you want to Import the solution to"
    $importChoice = $importChoice.Trim()
}

# If the user typed "new", prompt them to enter the URL of the environment and create a new profile
if ($importChoice -eq "new") {
    $url = Read-Host "Enter the URL of the environment"
    $profileName = Read-Host "Enter a Profile Name"
    pac auth create --url $url --name $profileName
    # Get the name of the newly created profile and store it in a variable
    $importChoice = $importProfileName
}

# Set the active profile to the one chosen or created
pac auth select --name $importChoice

# Import Solution
pac solution import --path $solutionPath --async --activate-plugins --publish-changes
