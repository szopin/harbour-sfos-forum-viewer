import QtQuick 2.2
import Sailfish.Silica 1.0

Page {
    id: posthistory
    allowedOrientations: Orientation.All
    property int postid
    property int vmode
    property int curRev
    property string prevRev
    property string nexRev
    property string cooked
    property string aTitle
    property string revisions
    property string titles
    property string username 

    function getcomments(i){
            var xhr = new XMLHttpRequest;
        xhr.open("GET", application.source + "posts/" + postid + "/revisions/" + i + ".json");
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                var data = JSON.parse(xhr.responseText);
             //   prevRev = data.previous_revision
                curRev = data.current_revision
                nexRev = data.last_revision
                revisions = data.body_changes.side_by_side_markdown
                titles = data.title_changes.inline
            }
        }
        xhr.send();
    }

    BusyIndicator {
        id: vplaceholder
        anchors.centerIn: parent
        running: !revisions && !cooked
        size: BusyIndicatorSize.Large
    }

    SilicaFlickable {
        id: flickable
        anchors.fill: parent
        visible: revisions || cooked
        contentHeight: content.height

        Component.onCompleted: posthistory.getcomments(curRev);

        VerticalScrollDecorator {}
    PullDownMenu{
        visible: (curRev > prevRev && curRev > 2) || curRev < nexRev

            MenuItem {
                visible: curRev < nexRev
                text: qsTr("Next")

                onClicked: getcomments(curRev +1)
            }
            MenuItem {
                visible: curRev > prevRev && curRev > 2
                text: qsTr("Previous")

                onClicked: getcomments(curRev -1)
            }
        }
        Column {
            id: content
            width: parent.width

            PageHeader {
                id: pageHeader
                title: cooked ? username ? username : qsTr("Alternative formatting") : qsTr("Revision history")
                description: cooked ? "" : aTitle
            }

            Label {
                id: cid
                anchors {
                    leftMargin: Theme.paddingMedium
                    rightMargin: Theme.paddingSmall
                    left: parent.left
                    right: parent.right
                }
                text: cooked ? cooked : "<style> " +
                            "del { color:" + Theme.secondaryColor + "};</style><style> " +
                            "ins { " +
                            "  color: " + Theme.highlightColor + ";" +
                            "} " +
                            "</style>" +titles + "</p>" +revisions
                textFormat: cooked ? username ? Text.RichText : Text.StyledText : Text.RichText
                wrapMode: Text.Wrap
                font.pixelSize: Theme.fontSizeSmall
                onLinkActivated: pageStack.push("OpenLink.qml", {link: link});
            }
        }
    }
}
