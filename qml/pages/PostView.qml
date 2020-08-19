import QtQuick 2.2
import Sailfish.Silica 1.0

Page {
    id: posthistory
    allowedOrientations: Orientation.All
    property int postid
    property string aTitle
    property string revisions

    function getcomments(){
        var xhr = new XMLHttpRequest;
        xhr.open("GET", application.source + "posts/" + postid + "/revisions/latest.json");
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                var data = JSON.parse(xhr.responseText);
                revisions = data.body_changes.side_by_side_markdown
            }
        }
        xhr.send();
    }

    BusyIndicator {
        id: vplaceholder
        anchors.centerIn: parent
        running: !revisions
        size: BusyIndicatorSize.Large
    }

    SilicaFlickable {
        id: flickable
        anchors.fill: parent
        visible: revisions
        contentHeight: content.height

        Component.onCompleted: posthistory.getcomments();

        VerticalScrollDecorator {}

        Column {
            id: content
            width: parent.width

            PageHeader {
                id: pageHeader
                title: qsTr("Revision history")
                description: aTitle
            }

            Label {
                id: cid
                anchors {
                    leftMargin: Theme.paddingMedium
                    rightMargin: Theme.paddingSmall
                    left: parent.left
                    right: parent.right
                }
                text: revisions
                textFormat: Text.RichText
                wrapMode: Text.Wrap
                font.pixelSize: Theme.fontSizeSmall
                onLinkActivated: pageStack.push("OpenLink.qml", {link: link});
            }
        }
    }
}
