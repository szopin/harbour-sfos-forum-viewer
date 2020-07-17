import QtQuick 2.0
import Sailfish.Silica 1.0

CoverBackground {
    Label {
        id: label
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        text: qsTr("SFOS Forum Viewer")
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.Wrap
    }
}
