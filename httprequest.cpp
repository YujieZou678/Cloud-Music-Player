#include "httprequest.h"
#include "mysubthread.h"

#include <QThread>

HttpRequest::HttpRequest(QObject *parent)
    : QObject{parent}
{
    //为manager状态赋值
    for (int i=0; i<3; i++) {
        statusSignal[i] = true;
    }
    //网络请求
    manager[0] = new QNetworkAccessManager(this);
    manager[1] = new QNetworkAccessManager(this);
    manager[2] = new QNetworkAccessManager(this);

    connect(manager[0], &QNetworkAccessManager::finished, this, &HttpRequest::replyFinished1);
    connect(manager[1], &QNetworkAccessManager::finished, this, &HttpRequest::replyFinished2);
    connect(manager[2], &QNetworkAccessManager::finished, this, &HttpRequest::replyFinished3);
    //子线程执行某操作
    sub1Thread = new QThread();  //需要手动清理，RAII结构
    classAtSub1Thread = new MySubThread();  //需要手动清理，RAII结构
    classAtSub1Thread->moveToThread(sub1Thread);

    connect(this, &HttpRequest::getSongsFF_Signal, classAtSub1Thread, &MySubThread::getSongsFromFolders);
    connect(classAtSub1Thread, &MySubThread::closeSub1Signal, this, &HttpRequest::closeSub1Thread);

}

HttpRequest::~HttpRequest()
{
    //析构不允许发生异常，如果有异常就吞掉
    try {
        if (sub1Thread->isRunning()) {  //上保险，如果退出程序而子线程没关闭
            sub1Thread->quit();
            sub1Thread->wait();
            qDebug() << "析构函数: 子线程1号已关闭";
        }
    } catch (std::exception e) {
        qDebug() << "析构函数: 子线程关闭异常！";
    }

    delete sub1Thread;
    delete classAtSub1Thread;
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

void HttpRequest::getSongsFF_AtSub1Thread(const QStringList& paths)
{
    sub1Thread->start();  //启动子线程
    emit getSongsFF_Signal(paths);  //在子线程开始执行
}

void HttpRequest::closeSub1Thread(const QStringList& data)
{
    sub1Thread->quit();  //关闭子线程1号
    sub1Thread->wait();
    //qDebug() << "子线程1号已关闭";
    emit getSongsFFEnd_Signal(data);  //将值传递给qml
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
