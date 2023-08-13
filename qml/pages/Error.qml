import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: errors
    property string errortext: qsTr("An unknown Error occurred.")

    PageHeader {
        id: pageHeader
        title: qsTr("Error:");
    }
    TextArea {
        id: errorbody
        text: errortext
        anchors.top: pageHeader.bottom
        anchors.left: parent.left
        anchors.right: parent.right
    }
}
