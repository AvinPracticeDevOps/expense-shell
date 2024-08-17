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

#Installing nginx server
dnf install nginx -y &>>$LOGFILE
check_exit $? "Installing nginx server"

#Enabiling nginx server
systemctl enable nginx &>>$LOGFILE
check_exit $? "Enabiling nginx server"

#Starting nginx server
systemctl start nginx &>>$LOGFILE
check_exit $? "Starting nginx server"

#Deleting all files in html location
rm -rf /usr/share/nginx/html/* &>>$LOGFILE
check_exit $? "Deleting all file in html folder"

#Downloading frontend.zip in tmp folder
curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$LOGFILE
check_exit $? "Downloading forntend.zip in tmp folder"

#change to html directory
cd /usr/share/nginx/html &>>$LOGFILE
check_exit $? "change dir to html"

#unzippin frontend.zip
unzip /tmp/frontend.zip &>>$LOGFILE
check_exit $? "unarchieving frontend.zip fiile to html dir"

#copying conf file
cp /home/ec2-user/expense-shell/expense.conf /etc/nginx/default.d/expense.conf &>>$LOGFILE
check_exit $? "copying conf file"

#Restarting nginx server
systemctl restart nginx &>>$LOGFILE
check_exit $? "Restarting nginx server"