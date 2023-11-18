#include "httprequest.h"

HttpRequest::HttpRequest(QObject *parent)
    : QObject{parent}
{
    //为manager状态赋值
    for (int i=0; i<3; i++) {
        statusSignal[i] = true;
    }

    manager[0] = new QNetworkAccessManager(this);
    manager[1] = new QNetworkAccessManager(this);
    manager[2] = new QNetworkAccessManager(this);

    connect(manager[0], &QNetworkAccessManager::finished, this, &HttpRequest::replyFinished1);
    connect(manager[1], &QNetworkAccessManager::finished, this, &HttpRequest::replyFinished2);
    connect(manager[2], &QNetworkAccessManager::finished, this, &HttpRequest::replyFinished3);
}

//三个槽函数
void HttpRequest::replyFinished1(QNetworkReply *reply)
{
    if (reply->error() != QNetworkReply::NoError) {
        qDebug() << "Reply error: " << reply->errorString();
        //传递一个空，用于判断请求失败
        emit replySignal1("");
    } else {
        emit replySignal1(reply->readAll());
    }

    reply->deleteLater();  //需要手动释放
}
void HttpRequest::replyFinished2(QNetworkReply *reply)
{
    if (reply->error() != QNetworkReply::NoError) {
        qDebug() << "Reply error: " << reply->errorString();
        //传递一个空，用于判断请求失败
        emit replySignal2("");
    } else {
        emit replySignal2(reply->readAll());
    }

    reply->deleteLater();  //需要手动释放
}
void HttpRequest::replyFinished3(QNetworkReply *reply)
{
    if (reply->error() != QNetworkReply::NoError) {
        qDebug() << "Reply error: " << reply->errorString();
        //传递一个空，用于判断请求失败
        emit replySignal3("");
    } else {
        emit replySignal3(reply->readAll());
    }

    reply->deleteLater();  //需要手动释放
}

//请求数据
void HttpRequest::getData(QString url, int i)
{
    manager[i]->get(QNetworkRequest(QUrl(BASE_URL + url)));
}

//得到一个空闲的Manager
int HttpRequest::getFreeManager()
{
    //是个死循环，直到找到空闲的Manager
    for (int i = 0; (i+3)%3 < 3; i++) {
        switch ((i+3)%3) {
        case 0:
            if (statusSignal[0] == true) {
                statusSignal[0] = false;
                return 0;
            }
            break;
        case 1:
            if (statusSignal[1] == true) {
                statusSignal[1] = false;
                return 1;
            }
            break;
        case 2:
            if (statusSignal[2] == true) {
                statusSignal[2] = false;
                return 2;
            }
            break;
        }
    }

    return 0;
}

//重置Manager的状态
void HttpRequest::reSetStatus(int i)
{
    statusSignal[i] = true;
}

//得到分秒标准格式时间
QString HttpRequest::getTime(int total)
{
    int hh = total / (60 * 60);
    int mm = (total- (hh * 60 * 60)) / 60;
    int ss = (total - (hh * 60 * 60)) - mm * 60;

    QString hour = QString::number(hh, 10);  //转字符串，十进制
    QString min = QString::number(mm, 10);
    QString sec = QString::number(ss, 10);

    if (hour.length() == 1)
        hour = "0" + hour;
    if (min.length() == 1)
        min = "0" + min;
    if (sec.length() == 1)
        sec = "0" + sec;

    QString strTime = min + ":" + sec;
    return strTime;
}
