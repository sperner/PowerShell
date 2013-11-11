# Script to convert a passphrase to a hash usable in (login-)scripts
#

# Read password secure via inputbox
$password = read-host "Enter password" -AsSecureString

# Convert to hash
$hash = $password | ConvertFrom-SecureString

# Print hash
return $hash
