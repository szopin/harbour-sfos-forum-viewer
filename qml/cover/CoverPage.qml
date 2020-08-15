import QtQuick 2.0
import Sailfish.Silica 1.0

CoverBackground {
    SilicaListView {
        id: view
        clip: true

        anchors {
            top: parent.top; bottom: coverActionArea.top
            left: parent.left; right: parent.right
            margins: Theme.paddingMedium
        }

        VerticalScrollDecorator { id: scrollBar; flickable: view }

        header: Label {
            text: qsTr("Latest posts")
            font.pixelSize: Theme.fontSizeSmall
            visible: !application.fetching
        }

        model: application.latest
        delegate: ListItem {
            id: item
            anchors.topMargin: Theme.paddingSmall
            height: postsLabel.height + Theme.paddingSmall
            opacity: 1.0 - ((item.y - view.contentY)/view.height * 0.3)

            Row {
                width: parent.width
                spacing: Theme.paddingSmall

                Item {
                    id: postsLabel
                    anchors.verticalCenter: entryLabel.verticalCenter
                    height: 1.3*Theme.fontSizeTiny; width: height

                    Label {
                        anchors.centerIn: parent
                        width: 0.9*parent.width; height: 0.9*parent.height
                        text: posts_count
                        minimumPixelSize: 0.6*Theme.fontSizeTiny
                        fontSizeMode: "Fit"
                        font.pixelSize: Theme.fontSizeTiny
                        color: Theme.primaryColor
                        opacity: Theme.opacityHigh
                        horizontalAlignment: "AlignHCenter"
                    }

                    Rectangle {
                        radius: 10
                        color: Theme.secondaryColor
                        anchors.fill: parent
                        opacity: Theme.opacityFaint
                    }
                }

                Label {
                    id: entryLabel
                    color: Theme.primaryColor
                    font.pixelSize: Theme.fontSizeExtraSmall
                    text: title
                    truncationMode: TruncationMode.Fade
                    elide: Text.ElideNone
                    width: parent.width - postsLabel.width - parent.spacing
                }
            }
        }

        Column {
            id: placeholderColumn
            visible: view.count === 0 && !application.fetching

            spacing: Theme.paddingSmall
            anchors {
                left: parent.left; right: parent.right
                verticalCenter: parent.verticalCenter
            }

            Label {
                width: parent.width; horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere; font.pixelSize: Theme.fontSizeLarge
                text: qsTr("SailfishOS")
                color: Theme.highlightColor
                opacity: 1.0
            }

            Label {
                width: parent.width; horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap; font.pixelSize: Theme.fontSizeMedium
                opacity: Theme.opacityHigh
                text: qsTr("Forum Viewer")
                color: Theme.highlightColor
                maximumLineCount: 5
                truncationMode: TruncationMode.Fade
                elide: Text.ElideRight
            }
        }
    }

    BusyIndicator {
        anchors.centerIn: parent
        running: true
        Behavior on opacity { NumberAnimation { duration: 100 } }
        opacity: application.fetching ? 1.0 : 0.0

        // BusyIndicator animations are normally disabled
        // on the cover page, so we have to animate it manually
        NumberAnimation on rotation {
            from: 0; to: 360
            duration: 2500
            loops: Animation.Infinite
            running: application.fetching
        }
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
