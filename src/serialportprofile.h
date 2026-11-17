#ifndef BLUETOOTHDATA
#define BLUETOOTHDATA

//#include <BluezQt/Profile>
#include <KF5/BluezQt/bluezqt/profile.h>

#include <QLocalSocket>
#include <QSharedPointer>

class SerialPortProfile : public BluezQt::Profile
{
    Q_OBJECT

public:
    explicit SerialPortProfile(QObject *parent);

    QDBusObjectPath objectPath() const override;
    QString uuid() const override;

    void newConnection(BluezQt::DevicePtr device,
                       const QDBusUnixFileDescriptor &fd,
                       const QVariantMap &properties,
                       const BluezQt::Request<> &request) override;

    void
    requestDisconnection(BluezQt::DevicePtr device, const BluezQt::Request<> &request) override;
    void release() override;

    Q_INVOKABLE void sendHex(QString sString);

private Q_SLOTS:
    void socketReadyRead();
    void socketDisconnected();
    void errorSocket(QLocalSocket::LocalSocketError);

signals:
    void dataReady(QString sData);
    void error(QString sError);
    void connected();
    void disconnected();

private:
    QSharedPointer<QLocalSocket> m_socket;
};


//#include <QObject>
//#include <QtBluetooth/QBluetoothSocket>
//#include <QtBluetooth/QBluetoothAddress>
//
//class BluetoothData : public QObject
//{
//    Q_OBJECT
//public:
//    explicit BluetoothData(QObject *parent = 0);
//    ~BluetoothData();
//    Q_INVOKABLE void connect(QString address, int port);
//    Q_INVOKABLE void sendHex(QString sString);
//    Q_INVOKABLE void disconnect();
//private slots:
//    void readData();
//    void connected();
//    void disconnected();
//    void error(QBluetoothSocket::SocketError errorCode);
//private:
//    QBluetoothSocket *_socket;
//    int _port;
//    qint64 write(QByteArray data);
//signals:
//    void sigReadDataReady(QString sData);
//    void sigConnected();
//    void sigDisconnected();
//    void sigError(QString sError);
//};


#endif // BLUETOOTHDATA
