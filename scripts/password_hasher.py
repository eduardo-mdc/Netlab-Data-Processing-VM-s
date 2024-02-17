from passlib.hash import bcrypt

with open('passwords.txt', 'r') as file:  # Open the file in read mode
    for line in file:  # Read each line from the file
        unhashed_password = line.strip()  # Each line is a password
        print(bcrypt.hash(unhashed_password)) 

