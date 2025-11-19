$pp_profiles = Get-Content -Path "./profile-list.json" -Raw | ConvertFrom-Json

foreach ($pp_profile in $pp_profiles) {
    pac auth create --name $pp_profile.name --environment $pp_profile.url
}