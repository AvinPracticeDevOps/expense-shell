#!/bin/bash

#getting userid, creating timestamp, getting scriptname, creating log file
USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPTNAME=$(echo "$0" | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPTNAME-$TIMESTAMP.log

#Assigning colors
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\0[m"

#user prompt for sql credentials
echo "please enter user:"
read USER

echo "please enter password:"
read SQL_PASSWORD

#Checking root user
if [ $USERID -ne 0 ]
then
    echo -e "$R you don't have super user access, please access with super user access $N"
    exit 1
else
    echo -e "you are super user"
fi 

#creating function for checking exit status
check_exit(){
    if [ $1 -ne 0 ]
    then
        echo -e "$R $2....is FAILED"
        exit 1
    else
        echo -e "$G $2....is SUCCESS"
    fi 
}

#installing mysql-server
dnf install mysql-server -y &>>$LOGFILE
check_exit $? "Installing mysql-server"

#Enabling mysql server service
systemctl enable mysqld &>>$LOGFILE
check_exit $? "Enabling mysql server service"

#Restarting mysql server service
systemctl restart mysqld &>>$LOGFILE
check_exit $? "Restarting mysql server"

#setting root password
# mysql_secure_installation --set-root-pass ExpenseApp@1 &>>$LOGFILE
# check_exit $? "setting root password"

mysql -h 172.31.35.253 -u "${USER}" -p"${SQL_PASSWORD}" -e 'show databases' &>>$LOGFILE
if [ $? -ne 0 ]
then
    mysql_secure_installation --set-root-pass ExpenseApp@1 &>>$LOGFILE
    check_exit $? "setting root password"
else
    echo -e "$R sql root password is already set $N"
fi
