import QtQuick 2.0
import Sailfish.Silica 1.0


Dialog {
    id: dialog2

    property string category
    property string raw

    function findFirstPage() {
        return pageStack.find(function(page) { return page.hasOwnProperty('viewmode'); });
    }
    canAccept: postbody.text.length >19 && ttitle.text.length >14

        onAccepted: {
              findFirstPage().newtopic(postbody.text, ttitle.text, category);
    }
                SilicaFlickable{
        id: flick
        anchors.fill: parent


                PageHeader {
                    id: pageHeader
                    title: qsTr("Enter thread");
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
