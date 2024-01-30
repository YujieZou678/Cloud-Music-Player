#ifndef HTTPREQUEST_H
#define HTTPREQUEST_H

#include <QObject>
#include <QNetworkRequest>
#include <QNetworkAccessManager>
#include <QNetworkReply>

class QThread;
class MySubThread;

class HttpRequest : public QObject
{
    Q_OBJECT
public:
    explicit HttpRequest(QObject *parent = nullptr);
    ~HttpRequest();
    //暴露给qml的函数
    Q_INVOKABLE void getData(QString, int);
    Q_INVOKABLE QString getTime(int);
    Q_INVOKABLE int getFreeManager();
    Q_INVOKABLE void reSetStatus(int);

    //请求数据完成后执行的函数
    void replyFinished1(QNetworkReply *reply);
    void replyFinished2(QNetworkReply *reply);
    void replyFinished3(QNetworkReply *reply);

    Q_INVOKABLE void getSongsFF_AtSub1Thread(const QStringList&);  //启动子线程1号并执行遍历文件夹得到音乐文件的操作
    void closeSub1Thread(const QStringList&);  //关闭子线程1号

signals:
    //传递给qml的信号
    void replySignal1(QString data);
    void replySignal2(QString data);
    void replySignal3(QString data);

    void getSongsFF_Signal(const QStringList&);  //执行子线程查找音乐的操作的信号
    void getSongsFFEnd_Signal(const QStringList&);  //传递给qml的信号

private:
    QString BASE_URL{"http://localhost:3000"};
    QNetworkAccessManager *manager[3];
    bool statusSignal[3];

    QThread* sub1Thread;  //子线程1号
    MySubThread* classAtSub1Thread;  //在子线程1号的类对象

};

#endif // HTTPREQUEST_H
