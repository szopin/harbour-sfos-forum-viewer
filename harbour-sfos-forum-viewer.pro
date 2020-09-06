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
TARGET = harbour-sfos-forum-viewer

CONFIG += sailfishapp_qml

DISTFILES += qml/harbour-sfos-forum-viewer.qml \
    qml/img/harbour-sfos-forum-viewer.png \
    qml/cover/CoverPage.qml \
    qml/pages/About.qml \
    qml/pages/CategorySelect.qml \
    qml/pages/FirstPage.qml \
    qml/pages/OpenLink.qml \
    qml/pages/SearchPage.qml \
    qml/pages/ThreadView.qml \
    qml/pages/webView.qml \
    rpm/harbour-sfos-forum-viewer.changes.in \
    rpm/harbour-sfos-forum-viewer.changes.run.in \
    rpm/harbour-sfos-forum-viewer.spec \
    rpm/harbour-sfos-forum-viewer.yaml \
    translations/*.ts \
    harbour-sfos-forum-viewer.desktop

SAILFISHAPP_ICONS = 86x86 108x108 128x128 172x172

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n

# German translation is enabled as an example. If you aren't
# planning to localize your app, remember to comment out the
# following TRANSLATIONS line. And also do not forget to
# modify the localized app name in the the .desktop file.
TRANSLATIONS += \
    translations/harbour-sfos-forum-viewer-de.ts \
    translations/harbour-sfos-forum-viewer-en.ts \
    translations/harbour-sfos-forum-viewer-es.ts \
    translations/harbour-sfos-forum-viewer-ru.ts \
    translations/harbour-sfos-forum-viewer-sv.ts \
    translations/harbour-sfos-forum-viewer-zh_CN.ts

