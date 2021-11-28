import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: errors
    property string errortext

                PageHeader {
                    id: pageHeader
                    title: qsTr("Error:");
                }
                TextArea {
                    id: errorbody
                    text: errortext
                    anchors.top: pageHeader.bottom

                    }



    }
