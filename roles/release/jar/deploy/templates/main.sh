#!/bin/bash
PATH=/usr/local/jdk/bin:/usr/local/jdk/jre/bin:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/opt/aws/bin:/root/bin
PROJECT_NAME="{{ project }}"
JAR_FILE=`ls {{ pkgroot }}/*.jar`
PIDFILE="{{ pkgroot }}/{{ project }}.pid"
JAVA_OPTS="{{ javaargs }}"
STDOUT_FILE="{{ pkgroot }}/stdout.log"


if ! [ -f "$JAR_FILE" ]; then
    echo "ERROR: $JAR_FILE is not exits."
    exit 1
fi

stop(){
    if [ -s $PIDFILE ]; then
        PID=`cat $PIDFILE`
        for ((i=1;i<100;i++));do
            if [ -x /proc/$PID ]; then
                echo "INFO: Waiting for ${PROJECT_NAME} stopped ..."
                if [ "$i" == "30" ]; then
                    echo "ERROR: Stop timeout, Quit."
                    exit 1
                fi
                kill $PID; sleep 1
            else
                echo "Stopped {{ project }}."
                > $PIDFILE
                break
            fi
        done
    fi
}

start() {
    nohup java -jar $JAR_FILE $JAVA_OPTS  > $STDOUT_FILE 2>&1 &
    sleep 1
    echo "Started {{ project }}."
    PID=$!
    printf $PID > $PIDFILE
}

restart(){
    if [ -s $PIDFILE ];then
        PID=`cat $PIDFILE`
        for ((i=1;i<100;i++));do
            if [ -x /proc/$PID ]; then
                echo "INFO: Waiting for ${PROJECT_NAME} stopped ..."
                if [ "$i" == "30" ]; then
                    echo "ERROR: Stop timeout, Quit."
                    exit 1
                fi
                kill $PID; sleep 1
            else
                echo "Stopped {{ project }}."
                > $PIDFILE
                break
            fi
        done
        start
    else
        start
    fi  
}

case "$1" in
stop) stop;;
restart) restart;;
*) echo $"Usage: $0 { stop | restart }";exit 1;;
esac
