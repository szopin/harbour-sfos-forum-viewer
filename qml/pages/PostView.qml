import QtQuick 2.2
import Sailfish.Silica 1.0

Page {
    id: posthistory
    allowedOrientations: Orientation.All
    property int likes
    property int postid
    property int highest_post_number
    property int post_number
    property string source: "https://forum.sailfishos.org/posts/"

    property string loadmore: source + topicid + "/posts.json?post_ids[]="
    property int topicid
    property string url
    property string aTitle
    property int posts_count


    function getcomments(){
        var xhr = new XMLHttpRequest;
        xhr.open("GET", source +  postid + "/revisions/latest.json");
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                var data = JSON.parse(xhr.responseText);

                list.model.append({cooked: data.body_changes["side_by_side_markdown"]});


            }
        }
        xhr.send();
    }

    SilicaListView {
        id: list
        header: PageHeader {
            title: aTitle
            id: pageHeader
        }
        width: parent.width
        height: parent.height
        anchors.top: header.bottom
        VerticalScrollDecorator {}


        BusyIndicator {
            id: vplaceholder
            running: commodel.count == 0
            anchors.centerIn: parent
            size: BusyIndicatorSize.Large
        }

        model: ListModel { id: commodel}
        delegate: Item {
            width: list.width
            height: cid.height
            anchors  {
                left: parent.left
                right: parent.right

            }

            Label {
                id:  cid
                text: cooked
                textFormat: Text.RichText
                wrapMode: Text.Wrap
                font.pixelSize: Theme.fontSizeSmall
                anchors {
                    leftMargin: Theme.paddingMedium// * indent
                    rightMargin: Theme.paddingSmall
                    left: parent.left
                    right: parent.right
                }
                onLinkActivated: {
                    var dialog = pageStack.push("OpenLink.qml", {link: link});
                }
            }

        }
        Component.onCompleted: posthistory.getcomments();

    }
}


