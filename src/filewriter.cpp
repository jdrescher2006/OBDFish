#include "filewriter.h"
#include <QFile>
#include <QTextStream>
#include <QStandardPaths>
#include <QDir>
#include <QTime>

FileWriter::FileWriter(QObject *parent) : QObject(parent)
{
}

void FileWriter::vWriteStart(const QString &msg)
{
    const QString directory = QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation);
    if (directory.isEmpty() || !QDir().mkpath(directory)) return;
    QFile file(QDir(directory).filePath(QStringLiteral("obd_log.txt")));

    if(file.open(QIODevice::WriteOnly))
    {
        QTextStream stream(&file);
        stream << msg << '\n';
    }

    file.flush();   //write at once!
    file.close();   //close file!

    return;
}

void FileWriter::vWriteData(const QString &msg)
{
    const QString directory = QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation);
    if (directory.isEmpty() || !QDir().mkpath(directory)) return;
    QFile file(QDir(directory).filePath(QStringLiteral("obd_log.txt")));

    //if(file.open(QIODevice::WriteOnly))
    if(file.open(QIODevice::Append))
    {
        QTextStream stream(&file);
        stream << QTime::currentTime().toString() << " " << msg << '\n';
    }

    file.flush();   //write at once!
    file.close();   //close file!

    return;
}
