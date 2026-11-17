#include "serialportprofile.h"

#include "serialportprofile.h"

#include <KF5/BluezQt/bluezqt/device.h>
//#include <BluezQt/Device>
#include <QCoreApplication>
#include <QDBusConnection>
#include <QDBusObjectPath>
#include <QDBusUnixFileDescriptor>
#include <QDebug>
#include <QTimer>

SerialPortProfile::SerialPortProfile(QObject *parent)
    : BluezQt::Profile(parent)
{
    setName(QStringLiteral("Serial Port"));
    setChannel(22);
    setLocalRole(LocalRole::ClientRole);
    setAutoConnect(true);
}

QDBusObjectPath
SerialPortProfile::objectPath() const
{
    return QDBusObjectPath(QStringLiteral("/SerialPortProfile"));
}

QString
SerialPortProfile::uuid() const
{
    return QStringLiteral("00001101-0000-1000-8000-00805f9b34fb");
}

void
SerialPortProfile::newConnection(BluezQt::DevicePtr device,
                                 const QDBusUnixFileDescriptor &fd,
                                 const QVariantMap &properties,
                                 const BluezQt::Request<> &request)
{
    qDebug() << "Connect" << device->name() << properties;

    m_socket = createSocket(fd);
    if (!m_socket->isValid()) {
        request.cancel();
        return;
    }

    connect(m_socket.data(), &QLocalSocket::readyRead, this, &SerialPortProfile::socketReadyRead);
    connect(
                m_socket.data(), &QLocalSocket::disconnected, this, &SerialPortProfile::socketDisconnected);
    connect(m_socket.data(), static_cast<void(QLocalSocket::*)(QLocalSocket::LocalSocketError)>(&QLocalSocket::error), this, &SerialPortProfile::errorSocket);


    request.accept();

    emit connected();
}

void
SerialPortProfile::requestDisconnection(BluezQt::DevicePtr device,
                                        const BluezQt::Request<> &request)
{
    qDebug() << "Disconnect" << device->name();

    m_socket.clear();

    request.accept();

    emit disconnected();
}

void
SerialPortProfile::release()
{
    qDebug() << "Release";
}

void SerialPortProfile::socketReadyRead()
{
    qDebug("Entering readData...");

    QByteArray data = m_socket->readAll();

    qDebug() << "Data size:" << data.size()
     << "\nData[" << m_socket->socketDescriptor() << "]:" << data.toHex()

     << "\nText: " << data;

    emit this->dataReady(data);
}

void SerialPortProfile::socketDisconnected()
{
    m_socket.clear();
    emit disconnected();
}

void SerialPortProfile::errorSocket(QLocalSocket::LocalSocketError errorCode)
{
    if (this->m_socket) {
        qDebug() << "Error: " << this->m_socket->errorString();
        qDebug() << "Errorcode: " << errorCode;

        emit this->error(this->m_socket->errorString());
    }
}

void SerialPortProfile::sendHex(QString sString)
{
    if (!m_socket)
        return;

    QByteArray data = sString.toUtf8();

    data.append("\r");

    qDebug() << "Writing:" << data.toHex();


    qint64 ret = this->m_socket->write(data);

    qDebug() << "Write returned:" << ret;
}

