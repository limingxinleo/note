#!/usr/bin/expect -f

set user root
set host xxxxx
set password xxxxx
set timeout 1

spawn ssh $user@$host
expect {
    "(yes/no)?"
    {
        send "yes\n"
        expect "*assword:" { send "$password\n"}
    }
    "*assword:"
    {
        send "$password\n"
    }
}
interact
expect eof