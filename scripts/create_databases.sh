#!/bin/bash

# Declare an associative array for databases and users
declare -A databases_users=(
    ["db1"]="user1:password1"
    ["db2"]="user2:password2"
    ["db3"]="user3:password3"
    ["db4"]="user4:password4"
    ["db5"]="user5:password5"
    ["db6"]="user6:password6"
)

# Login to MySQL and run commands
for db in "${!databases_users[@]}"; do
    IFS=':' read -r user pass <<< "${databases_users[$db]}"

    # Ensure the database exists
    mysql -e "CREATE DATABASE IF NOT EXISTS $db;"

    # Ensure the user exists and grant privileges
    mysql -e "CREATE USER IF NOT EXISTS '$user'@'localhost' IDENTIFIED BY '$pass';"
    mysql -e "GRANT ALL PRIVILEGES ON $db.* TO '$user'@'localhost';"
    mysql -e "FLUSH PRIVILEGES;"
done
