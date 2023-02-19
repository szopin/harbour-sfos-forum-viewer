import QtQuick 2.0
import Sailfish.Silica 1.0


Dialog {
    id: dialog2

    allowedOrientations: Orientation.All

    property string category
    property string raw
    property string target_recipients

    function findFirstPage() {
        return pageStack.find(function(page) { return page.hasOwnProperty('viewmode'); });
    }
    canAccept: postbody.text.length >19 && ttitle.text.length >14

    onAccepted: {
        if(!target_recipients){
            findFirstPage().newtopic(postbody.text, ttitle.text, category);
        } else {
            findFirstPage().newPM(postbody.text, ttitle.text, target_recipients);
        }
    }
    SilicaFlickable{
        id: flick
        anchors.fill: parent


        PageHeader {
            id: pageHeader
            title: !target_recipients ? qsTr("Enter thread") : qsTr("Enter PM to ") + target_recipients
        }

        TextField {
            id: ttitle
            width: parent.width
            anchors.top: pageHeader.bottom
            placeholderText: qsTr("Title");
        }
        TextArea {
            id: postbody
            text: raw
            width: parent.width
            anchors.top: ttitle.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            softwareInputPanelEnabled: true
            placeholderText: qsTr("Body");


        }
        VerticalScrollDecorator { flickable: flick }
    }

    // }
}
