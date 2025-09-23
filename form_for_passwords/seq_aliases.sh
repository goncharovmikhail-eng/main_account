function passwdc() {
    local decrypted_file="~/.seq/passwd"
    gpg --quiet --batch --yes --decrypt --output $decrypted_file ~/.seq/passwd.gpg
    cat $decrypted_file | grep $1
    shred -u $decrypted_file
}

function passwdw() {
    local decrypted_file="~/.seq/passwd"
    local encrypt_file="~/.seq/passwd.gpg"
    sudo chattr -i $encrypt_file
    gpg --quiet --batch --yes --decrypt --output $decrypted_file $encrypt_file
    nano $decrypted_file
    gpg --symmetric --batch --yes --output $encrypt_file $decrypted_file
    shred -u $decrypted_file
    chmod 700 $encrypt_file
    sudo chattr +i $encrypt_file
}
function nrem {
    chmod 700 $1
    sudo chattr +i $1
}
alias yrem="sudo chattr -i $1"
function newsecret() {
    local file="$1"
    nano $1
    gpg --quiet --batch --yes --encrypt --recipient "your_email_of_gpgkey" --output $file.gpg $file
    shred -u $file
    chmod 700 $file.gpg
}
