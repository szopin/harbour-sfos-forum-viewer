import QtQuick 2.0
import Sailfish.Silica 1.0


Dialog {
    id: openLink
    property string link

    onAccepted: {

                pageStack.replace("webView.qml", {"pageurl": link });

    }

    DialogHeader {
        id: dialogHeader
    }

    Flickable {
        id: flickable
        anchors { top: dialogHeader.bottom; bottom: parent.bottom; left: parent.left; right: parent.right }
        contentHeight: mainColumn.height
        clip: true

        Column {
            id: mainColumn
            anchors { top: parent.top; left: parent.left; right: parent.right }
            spacing: Theme.paddingLarge


            Label {
                anchors { left: parent.left; right: parent.right }
                horizontalAlignment: Text.AlignHCenter

                wrapMode: Text.WrapAnywhere
                text: qsTr("Open URL in webview?")
            }

            Label {
                anchors { left: parent.left; right: parent.right }
                horizontalAlignment: Text.AlignHCenter
                color: Theme.highlightColor
                wrapMode: Text.WrapAnywhere

                text: link
            }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter

                Button {
                    text: qsTr("Open externally")

                    onClicked: {
                        Qt.openUrlExternally(link);
                        openLink.reject();
                    }
                }
                }
            }
        }
    }
