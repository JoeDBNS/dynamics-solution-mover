# Install Power Platform CLI for Windows if not already installed
# https://learn.microsoft.com/en-us/power-platform/developer/cli/introduction


function ColorReadHost {
    Param (
        [String]$prompt,
        [String]$color
    )

    $response = $(Write-Host $prompt": " -ForegroundColor $color -NoNewLine; Read-Host)
    return $response
}


# Get a list of authentication profiles and store them in a variable
$profiles = pac auth list

# Display the profiles in the console
$profiles

# Clean profiles data to use later
$profilesClean = [System.Collections.ArrayList]@("new")

if ($profiles.length -gt 1) {
    $profileNameStartIndex = $profiles[0].IndexOf("Name")
    $profileNameEndIndex = $profiles[0].IndexOf("User")
    $profileNameLength = $profileNameEndIndex - $profileNameStartIndex

    for ($i = 1; $i -lt $profiles.Count-1; $i++) {
        $profileName = $profiles[$i].Substring($profileNameStartIndex, $profileNameLength).Trim()

        if ($profileName.length -gt 0) {
            $profilesClean.Add($profileName)| out-null
        }
    }
}

# Prompt the user to enter the name of a profile from the list or type "new" to create a new one
$exportChoice = ColorReadHost -prompt "Enter the name of a profile from the list or type 'new' to create a new one you want to EXPORT from" -color "Cyan"
$exportChoice = $exportChoice.Trim()

# Verify the user entered a valid profile name or "new"
while (!($profilesClean -contains $exportChoice)) {
    Write-Host "`nCHOICE NOT FOUND`n" -ForegroundColor "Red"

    $exportChoice = ColorReadHost -prompt "Enter the name of a profile from the list or type 'new' to create a new one you want to EXPORT from" -color "Cyan"
    $exportChoice = $exportChoice.Trim()
}

# If the user typed "new", prompt them to enter the URL of the environment and create a new profile
if ($exportChoice -eq "new") {
    $url = ColorReadHost -prompt "`nEnter the URL of the environment" -color "Cyan"
    $profileName = ColorReadHost -prompt "Enter a Profile Name" -color "Cyan"
    pac auth create --url $url --name $profileName
    # Get the name of the newly created profile and store it in a variable
    $exportChoice = $profileName
}

# Output empty line
""

# Set the active profile to the one chosen or created
pac auth select --name $exportChoice

# Get a list of solutions from the environment and store them in a variable
$solutions = pac solution list

# Display the solutions in the console
$solutions

# Clean solutions data to use later
$solutionsClean = New-Object System.Collections.ArrayList

if ($solutions.length -gt 1) {
    $solutionUniqueNameEndIndex = $solutions[4].IndexOf("Friendly Name") - 1

    for ($i = 5; $i -lt $solutions.Count-1; $i++) {
        $solutionsClean.Add($solutions[$i].substring(0, $solutionUniqueNameEndIndex).replace(' ', '').Trim())| out-null
    }
}

# Prompt the user to enter the name of a solution from the list
$solutionChoice = ColorReadHost -prompt "Enter the name of a solution from the list" -color "Cyan"
$solutionChoice = $solutionChoice.Trim()

# Verify the user entered a valid solution name
while (!($solutionsClean -contains $solutionChoice)) {
    Write-Host "`nCHOICE NOT FOUND`n" -ForegroundColor "Red"

    $solutionChoice = ColorReadHost -prompt "Enter the name of a solution from the list" -color "Cyan"
    $solutionChoice = $solutionChoice.Trim()
}

# Output empty line
""

# Prompt the user to choose whether solution will be exported as Unmanaged or Managed
$isSolutionManagedChoice = ColorReadHost -prompt "Do you want to export the solution as 'Managed' (y/n)" -color "Cyan"
$isSolutionManagedChoice = $isSolutionManagedChoice.Trim().ToLower()

# Verify the user entered a valid choice
while (!(("y", "n") -contains $isSolutionManagedChoice)) {
    Write-Host "`nCHOICE NOT FOUND`n" -ForegroundColor "Red"

    $isSolutionManagedChoice = ColorReadHost -prompt "Do you want to export the solution as 'Managed' (y/n)" -color "Cyan"
    $isSolutionManagedChoice = $isSolutionManagedChoice.Trim().ToLower()
}

# Get Unix Time Stamp
$dateTime = (Get-Date).ToUniversalTime()
$unixTimeStamp = [System.Math]::Truncate((Get-Date -Date $dateTime -UFormat %s))

# Set Path Variables
$solutionPath = "c:\pac\Solutions\" + $solutionChoice + "-" + $unixTimeStamp + ".zip"

# Export Solution
if ($isSolutionManagedChoice -eq "y") {
    pac solution export --path $solutionPath --name $solutionChoice --overwrite --managed
}
else {
    pac solution export --path $solutionPath --name $solutionChoice --overwrite
}


# Open Folder Containing Exported Solution
Start-Process -FilePath C:\Windows\explorer.exe -ArgumentList "/e, ""c:\pac\Solutions\"""

# List Auth Profiles
$profiles

# Prompt the user to enter the name of a profile from the list or type "new" to create a new one to Import the solution to
$importChoice = ColorReadHost -prompt "Enter the name of a profile from the list or type 'new' to create a new one to IMPORT the solution to" -color "Cyan"
$importChoice = $importChoice.Trim()

# Verify the user entered a valid profile name or "new"
while (!($profilesClean -contains $importChoice)) {
    Write-Host "`nCHOICE NOT FOUND`n" -ForegroundColor "Red"

    $importChoice = ColorReadHost -prompt "Enter the name of a profile from the list or type 'new' to create a new one to IMPORT the solution to" -color "Cyan"
    $importChoice = $importChoice.Trim()
}

# If the user typed "new", prompt them to enter the URL of the environment and create a new profile
if ($importChoice -eq "new") {
    $url = ColorReadHost -prompt "`nEnter the URL of the environment" -color "Cyan"
    $importProfileName = ColorReadHost -prompt "Enter a Profile Name" -color "Cyan"
    pac auth create --url $url --name $importProfileName
    # Get the name of the newly created profile and store it in a variable
    $importChoice = $importProfileName
}

# Output empty line
""

# Set the active profile to the one chosen or created
pac auth select --name $importChoice

# Import Solution
pac solution import --path $solutionPath --async --activate-plugins --publish-changes
