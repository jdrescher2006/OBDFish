# NOTICE:
#
# Application name defined in TARGET has a corresponding QML filename.
# If name defined in TARGET is changed, the following needs to be done
# to match new name:
#   - corresponding QML filename must be changed
#   - desktop icon filename must be changed
#   - desktop filename must be changed
#   - icon definition filename in desktop file must be changed
#   - translation filenames have to be changed

# The name of your application
TARGET = harbour-obdfish

CONFIG += sailfishapp

QMAKE_CXXFLAGS += -std=c++0x
QMAKE_LFLAGS += -std=c++0x

DEFINES += APP_VERSION=\"\\\"$${VERSION}\\\"\"

SOURCES += src/harbour-obdfish.cpp \
    src/serialportprofile.cpp \
    src/filewriter.cpp \
    src/projectsettings.cpp \
    src/plotwidget.cpp

OTHER_FILES += qml/harbour-obdfish.qml \
    qml/cover/CoverPage.qml \
    rpm/harbour-obdfish.changes.in \
    rpm/harbour-obdfish.spec \
    rpm/harbour-obdfish.yaml \
    translations/*.ts \
    harbour-obdfish.desktop

SAILFISHAPP_ICONS = 86x86 108x108 128x128 256x256

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n

# German translation is enabled as an example. If you aren't
# planning to localize your app, remember to comment out the
# following TRANSLATIONS line. And also do not forget to
# modify the localized app name in the the .desktop file.
TRANSLATIONS += translations/harbour-obdfish-de.ts

HEADERS += \
    src/serialportprofile.h \
    src/filewriter.h \
    src/projectsettings.h \
    src/plotwidget.h

QT += dbus

DISTFILES += \
    qml/pages/DynPage.qml \
    rpm/harbour-obdfish.spec \
    qml/pages/SharedResources.js \
    qml/pages/OBDDataObject.js \
    qml/pages/GeneralInfo.qml \
    qml/pages/MainPage.qml \
    qml/tools/Messagebox.qml \
    qml/pages/AboutPage.qml \
    qml/obdfish.png \
    qml/pages/SettingsPage.qml \
    qml/icon-lock-error.png \
    qml/icon-lock-info.png \
    qml/icon-lock-ok.png \
    qml/icon-lock-warning.png \
    qml/elm327.png \
    qml/jp_logo.png \
    qml/pages/GeneralSettingsPage.qml \
    qml/pages/ErrorPage.qml \
    qml/obd_ok.png \
    qml/obd_error.png \
    rpm/harbour-obdfish.changes

unix: PKGCONFIG += KF5BluezQt
