# Install Power Platform CLI for Windows if not already installed
# https://learn.microsoft.com/en-us/power-platform/developer/cli/introduction


# Get a list of authentication profiles and store them in a variable
$profiles = pac auth list

# Display the profiles in the console
$profiles

# Prompt the user to enter the name of a profile from the list or type "new" to create a new one
$choice = Read-Host "Enter the name of a profile from the list or type 'new' to create a new one you want to Export from"

# If the user typed "new", prompt them to enter the URL of the environment and create a new profile
if ($choice -eq "new") {
    $url = Read-Host "Enter the URL of the environment"
    $profileName = Read-Host "Enter a Profile Name"
    pac auth create --url $url --name $profileName
    # Get the name of the newly created profile and store it in a variable
    $choice = $profileName
}

# Set the active profile to the one chosen or created
pac auth select --name $choice

# Get a list of solutions from the environment and store them in a variable
$solutions = pac solution list

# Display the solutions in the console
$solutions

# Prompt the user to enter the name of a solution from the list
$solutionChoice = Read-Host "Enter the name of a solution from the list"

# Set Path Variables
$solutionPath = "c:\pac\Solutions\" + $solutionChoice + ".zip"

# Export Solution
pac solution export --path $solutionPath --name $solutionChoice --overwrite

# List Auth Profiles
$profiles

# Prompt the user to enter the name of a profile from the list or type "new" to create a new one to Import the solution to
$importChoice = Read-Host "Enter the name of a profile from the list or type 'new' to create a new one to Import the solution to"

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
