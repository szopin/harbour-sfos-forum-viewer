import QtQuick 2.2
import Sailfish.Silica 1.0

Page {
    id: commentpage
    allowedOrientations: Orientation.All
    property int likes
    property int post_id
    property int highest_post_number
    property int post_number
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
           if (posts_count >= 20){
               for(var j=20;j<posts_count;j++)
               loadmore = loadmore + data.post_stream.stream[j] + "&post_ids[]="

           }
           var xhr2 = new XMLHttpRequest;
       xhr2.open("GET", loadmore);
       xhr2.onreadystatechange = function() {
           if (xhr2.readyState === XMLHttpRequest.DONE) {
               var data2 = JSON.parse(xhr2.responseText);



               list.model.clear();

           for (var i=0;i<data.post_stream.posts.length;i++) {
               if(data.post_stream.posts[i]["actions_summary"][0] && data.post_stream.posts[i]["actions_summary"][0]["id"] === 2){
                    likes = data.post_stream.posts[i]["actions_summary"][0]["count"];
                    } else likes = 0;
                   list.model.append({cooked: data.post_stream.posts[i]["cooked"], username: data.post_stream.posts[i]["username"], updated_at: data.post_stream.posts[i]["updated_at"], likes: likes, created_at: data.post_stream.posts[i]["created_at"], version: data.post_stream.posts[i]["version"], postid: data.post_stream.posts[i]["id"]});
           }
for (var j=0;j<data2.post_stream.posts.length;j++) {
               if(data2.post_stream.posts[j]["actions_summary"][0] && data2.post_stream.posts[j]["actions_summary"][0]["id"] === 2){
                    likes = data2.post_stream.posts[j]["actions_summary"][0]["count"];
                    } else likes = 0;
                 list.model.append({cooked: data2.post_stream.posts[j]["cooked"], username: data2.post_stream.posts[j]["username"], updated_at: data2.post_stream.posts[j]["updated_at"], likes: likes, created_at: data2.post_stream.posts[j]["created_at"], version: data2.post_stream.posts[j]["version"], postid: data2.post_stream.posts[j]["id"]});

           }
           }
           }
       xhr2.send();

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

        BusyIndicator {
            id: vplaceholder
            running: commodel.count == 0
            anchors.centerIn: parent
            size: BusyIndicatorSize.Large
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

            Separator {
                color: Theme.highlightColor
                height: 3
                width: parent.width
                anchors.margins: Theme.paddingLarge
                horizontalAlignment: Qt.AlignHCenter
            }
          }
        Component.onCompleted: commentpage.getcomments();
        onCountChanged: {
              // Lets not parse the whole thread but only suspect posts from the search, ~33% speed improvement in a thread with 57 posts
              for(var i=post_number - (highest_post_number - posts_count) - 1;i<=post_number;i++){
                  if (post_id !== "" && list.model.get(i) !== undefined && list.model.get(i).postid === post_id){
          positionViewAtIndex(i, ListView.Beginning);
                  }
          }
      }
    }
}


