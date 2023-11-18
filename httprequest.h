#ifndef HTTPREQUEST_H
#define HTTPREQUEST_H

#include <QObject>
#include <QNetworkRequest>
#include <QNetworkAccessManager>
#include <QNetworkReply>

class HttpRequest : public QObject
{
    Q_OBJECT
public:
    explicit HttpRequest(QObject *parent = nullptr);
    //暴露给qml的函数
    Q_INVOKABLE void getData(QString, int);
    Q_INVOKABLE QString getTime(int);
    Q_INVOKABLE int getFreeManager();
    Q_INVOKABLE void reSetStatus(int);
    //请求数据完成后执行的函数
    void replyFinished1(QNetworkReply *reply);
    void replyFinished2(QNetworkReply *reply);
    void replyFinished3(QNetworkReply *reply);

signals:
    //传递给qml的信号
    void replySignal1(QString data);
    void replySignal2(QString data);
    void replySignal3(QString data);

private:
    QString BASE_URL{"http://localhost:3000"};
    QNetworkAccessManager *manager[3];
    bool statusSignal[3];

};

#endif // HTTPREQUEST_H
