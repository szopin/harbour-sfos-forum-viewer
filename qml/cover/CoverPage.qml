import QtQuick 2.0
import Sailfish.Silica 1.0

CoverBackground {

    Column {
        id: col
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: Theme.paddingSmall
        spacing: Theme.paddingSmall

        Label {
            id: header
            text: "Latest posts"
            font.pixelSize: Theme.fontSizeSmall
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

    BusyIndicator {
        anchors.centerIn: parent
        visible: application.fetching
    }

    Label {
        anchors.centerIn: parent
        visible: application.latest.count === 0 && !application.fetching
        text: "No posts found"
    }

    CoverActionList {
        id: coverAction

        CoverAction {
            iconSource: "image://theme/icon-cover-refresh"

            onTriggered: {
                application.fetchLatestPosts()
            }
        }

    }
}
