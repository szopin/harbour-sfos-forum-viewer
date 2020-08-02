import QtQuick 2.0
import Sailfish.Silica 1.0

CoverBackground {

    Column {
        id: col
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: Theme.paddingLarge
        spacing: Theme.paddingLarge

        Label {
            text: "Latest posts"
            font.pixelSize: Theme.fontSizeSmall
        }

        Label {
            id: busy
            visible: false
            text: "Loading..."
            font.pixelSize: Theme.fontSizeTiny
        }

        Repeater {
            model: application.latest

            Column {
                width: col.width
                spacing: Theme.paddingSmall

                Label {
                    width: col.width
                    elide: Text.ElideRight
                    text: title
                    font.pixelSize: Theme.fontSizeTiny
                }
            }
        }
    }

    /* Possible implementation later when connected to updateView

    CoverActionList {
        id: coverAction

        CoverAction {
            iconSource: "image://theme/icon-cover-refresh"

            onTriggered: {
                application.fetchLatestPosts()
            }
        }

    } */
}
