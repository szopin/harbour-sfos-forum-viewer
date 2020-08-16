/*
 * This file is part of harbour-sfos-forum-viewer.
 *
 * MIT License
 *
 * Copyright (c) 2020 szopin
 * Copyright (C) 2020 Mirian Margiani
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

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
            id: pageHeader
            title: aTitle
            wrapMode: Text.Wrap
        }
        footer: Item {
            width: parent.width
            height: Theme.horizontalPageMargin
        }
        width: parent.width
        height: parent.height
        anchors.top: header.bottom
        VerticalScrollDecorator {}
        PullDownMenu{
        MenuItem {
            text: qsTr("Open in external browser")
            onClicked: Qt.openUrlExternally(source + topicid)
            }
        MenuItem {
            text: qsTr("Open directly")
            onClicked: pageStack.push("webView.qml", {"pageurl": source + topicid });

            }
        MenuItem {
            text: qsTr("Search thread")
            onClicked: pageStack.push("SearchPage.qml", {"searchid": topicid, "aTitle": aTitle });

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
            width: parent.width - 2*Theme.horizontalPageMargin
            height: delegateCol.height + Theme.paddingLarge
            anchors.horizontalCenter: parent.horizontalCenter

            Column {
                id: delegateCol
                width: parent.width
                height: childrenRect.height
                anchors.verticalCenter: parent.verticalCenter
                spacing: Theme.paddingMedium

                Separator {
                    color: Theme.highlightColor
                    width: parent.width
                    horizontalAlignment: Qt.AlignHCenter
                }

                Row {
                    width: parent.width
                    spacing: Theme.paddingSmall

                    Column {
                        width: parent.width - subMetadata.width

                        Label {
                            id: mainMetadata
                            text: username
                            textFormat: Text.RichText
                            truncationMode: TruncationMode.Fade
                            elide: Text.ElideRight
                            width: parent.width
                            font.pixelSize: Theme.fontSizeMedium
                        }
                        Label {
                            visible: likes > 0
                            text: qsTr("%n like(s)", "", likes)
                            color: Theme.secondaryColor
                            font.pixelSize: Theme.fontSizeSmall
                        }
                    }

                    Column {
                        id: subMetadata
                        Label {
                            text: formatJsonDate(created_at)
                            color: Theme.secondaryColor
                            font.pixelSize: Theme.fontSizeSmall
                            anchors.right: parent.right
                        }
                        Label {
                            text: (version > 1 && updated_at !== created_at) ?
                                      qsTr("✍️: %1").arg(formatJsonDate(updated_at)) : ""
                            color: Theme.secondaryColor
                            font.pixelSize: Theme.fontSizeSmall
                            anchors.right: parent.right
                        }
                    }
                }

                Label {
                    text: "<style>" +
                          "a { color: %1 }".arg(Theme.highlightColor) +
                          "</style>" +
                          "<p>" + cooked + "</p>"
                    width: parent.width
                    textFormat: Text.RichText
                    wrapMode: Text.Wrap
                    font.pixelSize: Theme.fontSizeSmall
                    onLinkActivated: {
                        var dialog = pageStack.push("OpenLink.qml", {link: link});
                    }
                }
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


