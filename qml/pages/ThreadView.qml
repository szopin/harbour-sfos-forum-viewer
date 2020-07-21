import QtQuick 2.2
import Sailfish.Silica 1.0

Page {
    id: commentpage
    allowedOrientations: Orientation.All
    property int likes
    property string source: "https://forum.sailfishos.org/t/"
    property string loadmore: source + topicid + "/posts.json?post_ids[]="
    property int topicid
    property string url
    property string aTitle
    property int posts_count


         function getcomments(){
            var xhr = new XMLHttpRequest;
            xhr.open("GET", source +  topicid + ".json");
            xhr.onreadystatechange = function() {
                if (xhr.readyState === XMLHttpRequest.DONE) {
                    var data = JSON.parse(xhr.responseText);
                    list.model.clear();

                for (var i=0;i<data.post_stream.posts.length;i++) {
                    if(data.post_stream.posts[i]["actions_summary"][0] && data.post_stream.posts[i]["actions_summary"][0]["id"] === 2){
                         likes = data.post_stream.posts[i]["actions_summary"][0]["count"];
                         } else likes = 0;
                        list.model.append({cooked: data.post_stream.posts[i]["cooked"], username: data.post_stream.posts[i]["username"], updated_at: data.post_stream.posts[i]["updated_at"], likes: likes, created_at: data.post_stream.posts[i]["created_at"], version: data.post_stream.posts[i]["version"]});
                }

                if (posts_count >= 20){
                    for(var j=20;j<posts_count;j++)
                    loadmore = loadmore + data.post_stream.stream[j] + "&post_ids[]="

                }
                }
            }
            xhr.send();
    }

         function morecomments(){
            var xhr = new XMLHttpRequest;
            xhr.open("GET", loadmore);
            xhr.onreadystatechange = function() {
                if (xhr.readyState === XMLHttpRequest.DONE) {
                    var data = JSON.parse(xhr.responseText);
                for (var i=0;i<data.post_stream.posts.length;i++) {
                    if(data.post_stream.posts[i]["actions_summary"][0] && data.post_stream.posts[i]["actions_summary"][0]["id"] === 2){
                         likes = data.post_stream.posts[i]["actions_summary"][0]["count"];
                         } else likes = 0;
                      list.model.append({cooked: data.post_stream.posts[i]["cooked"], username: data.post_stream.posts[i]["username"], updated_at: data.post_stream.posts[i]["updated_at"], likes: likes, created_at: data.post_stream.posts[i]["created_at"], version: data.post_stream.posts[i]["version"]});

                }
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
        PullDownMenu{
        MenuItem {
            text: "Open in browser"
            onClicked: Qt.openUrlExternally(source + topicid)
            }
        MenuItem {
            text: "Open in webview"
            onClicked: pageStack.push("webView.qml", {"pageurl": source + topicid });

            }
        }
        ViewPlaceholder {
            id: vplaceholder
            enabled: commodel.count == 0
            text: "Loading..."
            }

        model: ListModel { id: commodel}
          delegate: Item {
            width: list.width
            height: extras.visible ? cid.height + Theme.paddingMedium + extras.height : cid.height + Theme.paddingMedium

            anchors  {
                left: parent.left
                right: parent.right

                }

            Label {
                id:  cid
                text: "<style>a {color:" + Theme.highlightColor + " } </style>" +
                      "<p> <b>" + username + "</b> (" + created_at.substring(0,10) + " " + created_at.substring(11,19) + ")</p><p><i>" + cooked + "</i></p>\n"
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
            Label {
                id: extras
                visible: likes > 0 || (version > 1 && updated_at !== created_at)
                horizontalAlignment: Text.AlignRight
                text: likes > 0 ? (version > 1 ? "(✍️: " + updated_at.substring(0,10) + " " + updated_at.substring(11,19) + ") (❤:" + likes + ")" : "(❤:" + likes + ")") : (version > 1 ? "(✍️: " + updated_at.substring(0,10) + " " + updated_at.substring(11,19) + ")" : "")
                font.pixelSize: Theme.fontSizeSmall
                anchors {
                    top: cid.bottom
                    leftMargin: Theme.paddingMedium
                    rightMargin: Theme.paddingSmall
                    left: parent.left
                    right: parent.right
                }
            }
          }
        Component.onCompleted: commentpage.getcomments();
        PushUpMenu {
            id: pupmenu

            visible: loadmore != source + topicid + "/posts.json?post_ids[]=";

            MenuItem {

                text: "Load more"
                onClicked: {
                    pupmenu.close();
                    commentpage.morecomments();
                    loadmore = source + topicid + "/posts.json?post_ids[]="
                }
            }

        }
    }
}


