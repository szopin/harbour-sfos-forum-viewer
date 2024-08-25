import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: errors
    property string errortext: ''
    property string errortitle: ''

    PageHeader {
        id: pageHeader
        title: qsTr("Error:") + ( (errortitle != '') ? ' ' + errortitle : errortitle)
    }
    TextArea {
        id: errorbody
        text: (errortext != '') ? errortext : qsTr("An unknown Error occurred.")
        readOnly: true
        anchors.top: pageHeader.bottom
        anchors.left: parent.left
        anchors.right: parent.right
    }
}
