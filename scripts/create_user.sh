#!/bin/bash

# Define users and their passwords
declare -A users=(
    ["lced1"]='$2b$12$IXJfsc0HayuW/Y.sNotmr.g6fHusH31/fUE5m5hQFIqsCItaA4kMy'
    ["lced2"]='$2b$12$aKF71ZmdeGz3SwdJcWvltOMoobj3wDoisTbWsj.SdkWhbGEysCH9.'
    ["lced3"]='$2b$12$pF39kO9gLzSjXKTk7cOSX.1uCijCqOr1kmMj6E6Uf0hV0xRBVyUQG'
    ["lced4"]='$2b$12$iBdGg7RB1SsBLYEkIqE3Q.Smnb2Xikuxea6RP87x6mvtkvx7gG2U6'
    ["lced5"]='$2b$12$roFuf39AIeyY1w/.tqhK3ONUkdDBqwyC5H4TYc4UYCi3DlR9uOxWK'
    ["lced6"]='$2b$12$VBjqPtWEZBQ.qKTjuNcFsOntDZsSqcVjteZLh8enVSCEUo6DTDxjW'
)

# Loop through all users and create them
for user in "${!users[@]}"; do
    password=${users[$user]}
    # Check if the user already exists
    if id "$user" &>/dev/null; then
        echo "User $user already exists, skipping..."
    else
        # Create the user with the specified password and shell
        useradd -m -s /bin/bash "$user"
        # Setting the user password
        echo "$user:$password" | chpasswd -e
        echo "User $user created successfully."
    fi
done
