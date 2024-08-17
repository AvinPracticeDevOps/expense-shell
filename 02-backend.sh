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
N="\e[0m"

#credentials for backend.sql
echo "please enter user:"
read USER

echo "please enter password:"
read PASSWORD

#checking root user
if [ $USERID -ne 0 ]
then
    echo -e "$R you don't have root access, please access with root access $N"
    exit
else
    echo -e "$G you are root user $N"
fi

#Creating check_exit function to check exit status of given command
check_exit(){
if [ $1 -ne 0 ]
then 
    echo -e "$R $2....is FAILED $N"
    exit
else
    echo -e "$G $2....is SUCCESS $N"
fi
}

#Disabiling nodejs version
dnf module disable nodejs -y &>>$LOGFILE
check_exit $? "Disabling nodejs"

#Enabiling nodejs 20v
dnf module enable nodejs:20 -y &>>$LOGFILE
check_exit $? "Enabiling nodejs 20 version"

#Installing nodejs
dnf install nodejs -y &>>$LOGFILE
check_exit $? "Installing nodejs"

#creating user
# useradd expense &>>$LOGFILE
# check_exit $? "Creating expense user"
id expense &>>$LOGFILE
if [ $? -ne 0 ]
then
    useradd expense &>>$LOGFILE
    check_exit $? "creating expense user"
else
    echo -e "$G expense user is already there $N"
fi

#creating app directory
mkdir -p /app &>>$LOGFILE
check_exit $? "Creating app directory"

#Downloading backend.zip file in tmp location
curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOGFILE

#change directory to app
cd /app &>>$LOGFILE
check_exit $? "Changing directory to app"

#unzipping backen.zip in app dir
unzip /tmp/backend.zip &>>$LOGFILE
check_exit $? "Unzipping backend.zip in app directory"

#installing nodejs dependencies
npm install &>>$LOGFILE
check_exit $? "installing npm dependencies"

#Daemon reloading
systemctl daemon-reload &>>$LOGFILE
check_exit $? "Daemon reloading"

#starting backend service
systemctl start backend &>>$LOGFILE
check_exit $? "Starting backend service"

#Enabling backend service
systemctl enable backend &>>$LOGFILE
check_exit $? "Enabling backend service"

#Installing mysql client
dnf install mysql -y &>>$LOGFILE
check_exit $? "Installing mysql client"

#Loading backend.sql file
mysql -h <MYSQL-SERVER-IPADDRESS> -u"${USER}" -p"${PASSWORD}" < /app/schema/backend.sql &>>$LOGFILE
check_exit $? "Loaing backend.sql"

#Restarting backend service
systemctl restart backend &>>LOGFILE
check_exit $? "Restarting backend service"