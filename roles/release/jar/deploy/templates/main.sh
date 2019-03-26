#!/bin/bash
PATH=/usr/local/jdk/bin:/usr/local/jdk/jre/bin:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/opt/aws/bin:/root/bin
PROJECT_NAME="{{ project }}"
JAR_FILE=`ls {{ pkgroot }}/*.jar`
PIDFILE="/data/app/run/{{ project }}.pid"
JAVA_OPTS="{{ javaargs }}"


if ! [ -f "$JAR_FILE" ]; then
    echo "$JAR_FILE is not exits."
    exit 1
fi

stop(){
    if [ -s $PIDFILE ]; then
        PID=`cat $PIDFILE`
        for ((i=1;i<5;i++));do
            if [ -x /proc/$PID ]; then
                echo "INFO: Waiting for ${PROJECT_NAME} stopped ..."
                if [ "$count" == "5" ]; then
                    echo "Maximum number of retries exceeded, Quit."
                    exit 1
                fi
                kill $PID; sleep 1
            else
                echo "INFO: Stoped."
                > $PIDFILE
                break
            fi
        done
    fi
}

restart(){
    if [ -s $PIDFILE ];then
        PID=`cat $PIDFILE`
        for ((i=1;i<5;i++));do
            if [ -x /proc/$PID ]; then
                echo "INFO: Waiting for ${PROJECT_NAME} stopped ..."
                if [ "$count" == "5" ]; then
                    echo "Maximum number of retries exceeded, Quit."
                    exit 1
                fi
                kill $PID; sleep 1
            else
                echo "INFO: Stoped."
                > $PIDFILE
                break
            fi
        done
        nohup java -jar $JAR_FILE $JAVA_OPTS > /dev/null 2>&1 &
        sleep 1
        PID="$!"
        printf "$PID" > $PIDFILE
    else
        nohup java -jar $JAR_FILE $JAVA_OPTS  > /dev/null 2>&1 &
        sleep 1
        PID="$!"
        printf "$PID" > $PIDFILE
    fi  
}

case "$1" in
stop) stop;;
restart) restart;;
*) echo $"Usage: $0 { stop | restart }";exit 1;;
esac
