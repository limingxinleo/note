## shell
### 利用expect 登录服务器
~~~
#!/usr/bin/expect -f

set user root
set host your_host
set password your_password
set timeout -1

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

~~~