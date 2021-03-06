/*
 * Copyright (C) 2016 Jens Drescher, Germany
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#ifndef BLUETOOTHCONNECTION
#define BLUETOOTHCONNECTION

#include <QObject>
#include <QtBluetooth/QBluetoothDeviceDiscoveryAgent>

class BluetoothConnection : public QObject
{
    Q_OBJECT
public:
    explicit BluetoothConnection(QObject *parent = 0);
    ~BluetoothConnection();
    Q_INVOKABLE void vStartDeviceDiscovery();
    Q_INVOKABLE void vStopDeviceDiscovery();       
private:
    QBluetoothDeviceDiscoveryAgent *discoveryAgent;
private slots:
    void vDeviceDiscovered(const QBluetoothDeviceInfo &device);
    void vDiscoveryFinished();
signals:
    void deviceFound(QString sName, QString sAddress);
    void scanFinished();
};

#endif // BLUETOOTHCONNECTION
