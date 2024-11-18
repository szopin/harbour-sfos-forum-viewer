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
import QtGraphicalEffects 1.0
import Sailfish.Silica 1.0
import Nemo.Configuration 1.0


Page {
    id: commentpage
    allowedOrientations: Orientation.All
    property int likes
    property int post_id: -1
    property int highest_post_number
    property int post_number: -1
    readonly property string source: application.source + "t/" + topicid
    property string loadmore: source + "/posts.json?post_ids[]="
    property string loadmore2: source + "/posts.json?post_ids[]="
    property string loggedin
    property string raw
    property string topicid
    property string url
    property string aTitle
    property var reply_to
    property int last_post: 0
    property int posts_count
    property bool tclosed
    property string stafftag: ""
    property string tags
    property string avatar
    property bool acted
    property bool can_act
    property bool can_undo
    property bool accepted_answer
    property bool busy: true
    property int xi
    property int yi
    property int zi

    function getRedirect(link){
        var xhr = new XMLHttpRequest;
        xhr.open("GET", link);
        if (loggedin.value != "-1") xhr.setRequestHeader("User-Api-Key", loggedin.value);
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                var xhrlocation = xhr.getResponseHeader("location");
                var testa =  /^https:\/\/forum.sailfishos.org\/t\/[\w-]+\/(\d+)\/?(\d+)?$/.exec(xhrlocation);
                pageStack.push("ThreadView.qml", { "topicid":  testa[1]});
            }
        }
        xhr.send();
    }

    function findOP(filter){
        for (var j=0; j < commodel.count; j++){
            if (commodel.get(j).post_number == filter){
                pageStack.push(Qt.resolvedUrl("PostView.qml"), {postid: commodel.get(j).postid, aTitle: "Replied to post", cooked: commodel.get(j).cooked, username: commodel.get(j).username});
            }
        }
    }
    function uncensor(postid, index){
        var xhr3 = new XMLHttpRequest;
        xhr3.open("GET", "https://forum.sailfishos.org/posts/" + postid + "/cooked.json");
        xhr3.onreadystatechange = function() {
            if (xhr3.readyState === XMLHttpRequest.DONE)   var data = JSON.parse(xhr3.responseText);
            list.model.setProperty(index, "cooked", data.cooked);
            list.model.setProperty(index, "cooked_hidden", false);
        }
        xhr3.send();
    }
    function getraw(postid, oper){
        var xhr = new XMLHttpRequest;
        xhr.open("GET", "https://forum.sailfishos.org/posts/" + postid + ".json");
        if (loggedin.value != "-1") xhr.setRequestHeader("User-Api-Key", loggedin.value);
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE){   var data = JSON.parse(xhr.responseText);
                raw = data["raw"];
                if (oper == 1) Clipboard.text = raw;
                return raw;
            }
        }
        xhr.send();
    }
    //onRawChanged: Clipboard.text = raw;

    function like(postid, index){
        var xhr4 = new XMLHttpRequest;
        xhr4.open("POST", "https://forum.sailfishos.org/post_actions?id=" + postid + "&post_action_type_id=2&flag_topic=false");
        xhr4.setRequestHeader("User-Api-Key", loggedin.value);
        xhr4.onreadystatechange = function() {
            if (xhr4.readyState === XMLHttpRequest.DONE){
                if(xhr4.statusText !== "OK"){
                    pageStack.completeAnimation();
                    pageStack.push("Error.qml", {errortitle: xhr4.status + " " + xhr4.statusText, errortext: xhr4.responseText});
                } else {
                    var data = JSON.parse(xhr4.responseText);

                    list.model.setProperty(index, "likes", data["actions_summary"][0]["count"]);
                    list.model.setProperty(index, "can_undo", data["actions_summary"][0]["can_undo"]);
                    list.model.setProperty(index, "acted", true);
                }
            }
        }
        xhr4.send();
    }

    function unlike(postid, index){
        var xhr4 = new XMLHttpRequest;
        xhr4.open("DELETE", "https://forum.sailfishos.org/post_actions/" + postid + "?post_action_type_id=2");
        xhr4.setRequestHeader("User-Api-Key", loggedin.value);
        xhr4.onreadystatechange = function() {
            if (xhr4.readyState === XMLHttpRequest.DONE){
                if(xhr4.statusText !== "OK"){
                    pageStack.completeAnimation();
                    pageStack.push("Error.qml", {errortitle: xhr4.status + " " + xhr4.statusText, errortext: xhr4.responseText});
                } else {
                    var data = JSON.parse(xhr4.responseText);

                    list.model.setProperty(index, "likes", list.model.get(index).likes - 1);
                    list.model.setProperty(index, "acted", false);
                }
            }
        }
        xhr4.send();
    }
    function newpost(){
        var dialog = pageStack.push("NewPost.qml", {topicid: topicid});
    }
    function postreply(topicid, post_number, postid, username){

        var dialog = pageStack.push("NewPost.qml", {topicid: topicid, post_number: post_number, postid: postid, username: username, loggedin: loggedin.value});
    }
    function newedit(postid){

        var dialog = pageStack.push("NewPost.qml", {postid: postid, loggedin: loggedin.value});
    }
    function reply(raw, topicid){
        var xhr = new XMLHttpRequest;
        const json = {
            "topic_id": topicid ,
            "raw": raw
        };
        console.log(JSON.stringify(json), raw, topicid);
        xhr.open("POST", "https://forum.sailfishos.org/posts");
        xhr.setRequestHeader("User-Api-Key", loggedin.value);
        xhr.setRequestHeader("Content-Type", 'application/json');
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE){
                if(xhr.statusText !== "OK"){
                    pageStack.completeAnimation();
                    pageStack.push("Error.qml", {errortitle: xhr.status + " " + xhr.statusText, errortext: xhr.responseText});
                } else {
                    console.log(xhr.responseText);
                    list.model.clear();
                    commentpage.getcomments();
                }
            }
        }
        xhr.send(JSON.stringify(json));
    }
    function replytopost(raw, topicid, post_number){
        var xhr = new XMLHttpRequest;
        const json = {
            "topic_id": topicid ,
            "raw": raw,
            "reply_to_post_number": post_number
        };
        console.log(JSON.stringify(json), raw, topicid);
        xhr.open("POST", "https://forum.sailfishos.org/posts");
        xhr.setRequestHeader("User-Api-Key", loggedin.value);
        xhr.setRequestHeader("Content-Type", 'application/json');
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE){
                if(xhr.statusText !== "OK"){
                    pageStack.completeAnimation();
                    pageStack.push("Error.qml", {errortitle: xhr.status + " " + xhr.statusText, errortext: xhr.responseText});
                } else {
                    console.log(xhr.responseText);
                    list.model.clear();
                    commentpage.getcomments();
                }

            }
        }
        xhr.send(JSON.stringify(json));
    }
    function refresh(){
        list.model.clear();
        commentpage.getcomments();
    }
    function del(postid, index){
        var xhr = new XMLHttpRequest;
        xhr.open("DELETE", "https://forum.sailfishos.org/posts/" + postid);
        xhr.setRequestHeader("User-Api-Key", loggedin.value);
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE){
                if(xhr.statusText !== "OK"){
                    pageStack.completeAnimation();
                    pageStack.push("Error.qml", {errortitle: xhr.status + " " + xhr.statusText, errortext: xhr.responseText});
                } else {
                    list.model.setProperty(index, "cooked", "(post withdrawn by author, will be automatically deleted in 24 hours unless flagged)");
                    list.model.setProperty(index, "can_delete", false);
                }
            }
        }
        xhr.send();
    }
    function edit(raw, postid){
        var xhr = new XMLHttpRequest;
        const json = { "post": { "raw": raw} };
        console.log(JSON.stringify(json));
        xhr.open("PUT", "https://forum.sailfishos.org/posts/" +postid);
        xhr.setRequestHeader("User-Api-Key", loggedin.value);
        xhr.setRequestHeader("Content-Type", 'application/json');
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE){
                if(xhr.statusText !== "OK"){
                    pageStack.completeAnimation();
                    pageStack.push("Error.qml", {errortitle: xhr.status + " " + xhr.statusText, errortext: xhr.responseText});
                } else {
                    console.log(xhr.responseText);
                    list.model.clear();
                    commentpage.getcomments();
                }
            }
        }
        xhr.send(JSON.stringify(json));
    }
    ConfigurationGroup {
        id: filterlist
        path: "/apps/harbour-sfos-forum-viewer/filterlist"
    }
    WorkerScript {
        id: worker
        source: "worker.js"
        onMessage: {
            var data2 = JSON.parse(messageObject.data);
            appendPosts(data2.post_stream.posts)
            busy = !messageObject.last

            if (messageObject.last) busy = false// list.positionViewAtIndex(post_number - 1, ListView.Beginning);
        }
    }

    function appendPosts(posts) {
        var posts_length = posts.length;
        console.log(posts_length);
        for (var i=0;i<posts_length;i++) {
            var post = posts[i];
            var yours =  (loggedin.value == "-1") ? false : post.yours
            var spam = false
            var cooked_hidden = false
            if (post.staff){
                stafftag = " - Jolla"
            } else {
                stafftag = ""
            }
            var has_polls = !!post.polls  ? post.polls.length : 0
            var polldata = []

                // reorganize the poll data into an array of objects, so we only
                // have to result with the JSObject->ListModel conversion once:
                // See also: Flow { id: pollsItem } below
                for (var pi = 0; pi<has_polls; ++pi) {
                    var pd = { "poll": {}, "votes": {} }
                    pd["poll"] = post.polls[pi]
                    // polls_vote is only in the data if the user has voted already
                    if (!!post["polls_votes"]) {
                        if (post.polls_votes[post.polls[pi].name]) {
                            pd["votes"] = { "list": post.polls_votes[post.polls[pi].name] }
                        }
                        } else {
                            pd["votes"] = { "list": [] }
                        }
                 //   }
                    polldata.push(pd)
                }

            if (post.actions_summary.length > 0){
                var action = post.actions_summary[0];
                likes = (loggedin.value == "-1") ? ((action && action.id === 2)
                                                    ? action.count : 0) : (action.count && action.id === 2
                                                                           ? action.count : 0);

                can_undo = (loggedin.value == "-1") ? false : action && action.id === 2 && action.can_undo
                                                      ? action.can_undo : false
                acted = loggedin.value !== "-1" ? (action.id === 2 && action.acted ? action.acted : false) : false;
                cooked_hidden = post.cooked_hidden ? post.cooked_hidden : false
                spam = (filterlist.value(post.user_id, -1)  < 0) ? false : true
            }
            list.model.append({
                                  cooked: post.cooked,
                                  username: post.username,
                                  avatar: post.avatar_template,//.replace("{size}", 2* Theme.paddingLarge),
                                  updated_at: post.updated_at,
                                  likes: likes,
                                  acted: acted,
                                  can_undo: can_undo,
                                  yours: yours,
                                  can_edit: post.can_edit,
                                  can_delete: post.can_delete,
                                  created_at: post.created_at,
                                  version: post.version,
                                  postid: post.id,
                                  user_id: post.user_id,
                                  spam: spam,
                                  post_number: post.post_number,
                                  reply_to: post.reply_to_post_number,
                                  last_postid: last_post,
                                  cooked_hidden: cooked_hidden,
                                  accepted_answer: post.accepted_answer,
                                  stafftag: stafftag,
                                  has_polls: has_polls,
                                  polldata: polldata
                              });
            last_post = post.post_number;
        }
    }

    function getcomments(){
        var xhr = new XMLHttpRequest;
        xhr.open("GET", source + ".json");
        if (loggedin.value != "-1") xhr.setRequestHeader("User-Api-Key", loggedin.value);
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                var data = JSON.parse(xhr.responseText);
                if (data.tags) tags = data.tags.join(" ");
                tclosed = data.closed;
                if (aTitle == "") aTitle = data.title;
                posts_count = data.posts_count;
                var post_stream = data.post_stream;
                list.model.clear();
                appendPosts(post_stream.posts);
                var stream = post_stream.stream;
                if (posts_count >= 20){
                    xi = Math.floor((posts_count - 20) / 400)
                    yi = (posts_count - 20) % 400
                    for( zi = 0;zi<xi;zi++){
                        loadmore =  source + "/posts.json?post_ids[]="
                        for (var v = (20 + (zi * 400)); v < (20 +( (zi+1)*400));v++){
                            loadmore += stream[v] + "&post_ids[]="
                        }
                        busy = true

                        var msg = {
                            'loadmore': loadmore,
                            'login': loggedin.value,
                            'last': false
                        };

                        worker.sendMessage(msg)
                    }
                } else {
                    busy = false
                }

                if( zi == xi && posts_count >= 20) {
                    busy = true
                    loadmore =  source + "/posts.json?post_ids[]="
                    for(yi<posts_count - (zi*400);yi>0;yi--){
                        loadmore += stream[posts_count - yi] + "&post_ids[]="
                    }

                    var msg = {
                        'loadmore': loadmore,
                        'login': loggedin.value,
                        'last': true
                    };
                    worker.sendMessage(msg)

                }
            }


        }



        xhr.send();
    }
    ConfigurationValue {
        id: loggedin
        key: "/apps/harbour-sfos-forum-viewer/key"
    }
    SilicaListView {
        id: list
        header: PageHeader {
            id: pageHeader
            title: tclosed ? "🔐" + aTitle : aTitle
            description: tags ? qsTr("tags") + ": " + tags : ""
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
                text: qsTr("Copy link to clipboard")
                onClicked: Clipboard.text = source
            }
            MenuItem {
                text: qsTr("Open in external browser")
                onClicked: Qt.openUrlExternally(source)
            }
            MenuItem {
                text: qsTr("Open directly")
                onClicked: pageStack.push("webView.qml", {"pageurl": source});

            }
            MenuItem {
                text: qsTr("Search thread")
                onClicked: pageStack.push("SearchPage.qml", {"searchid": topicid, "aTitle": aTitle });

            }
            MenuItem {
                text: qsTr("Post reply")
                visible: loggedin.value != "-1" && !tclosed
                onClicked: newpost();
            }
        }
        PushUpMenu{
            visible: loggedin.value != "-1" && !tclosed
            MenuItem {
                text: qsTr("Post reply")
                visible: loggedin.value != "-1" && !tclosed
                onClicked: newpost();
            }
        }

        BusyIndicator {
            id: vplaceholder
            running: busy //commodel.count == 0
            anchors.centerIn: parent
            size: BusyIndicatorSize.Large
        }

        model: ListModel { id: commodel}
        delegate: ListItem {
            property int postindex: index
            enabled: menu.hasContent
            width: parent.width
            visible: !spam
            contentHeight: !spam ? delegateCol.height + Theme.paddingLarge : 0
            anchors.horizontalCenter: parent.horizontalCenter

            Column {
                id: delegateCol
                width: parent.width - 2*Theme.horizontalPageMargin
                height: childrenRect.height
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    verticalCenter: parent.verticalCenter
                }
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
                        Image {
                            id: ava
                            height:  3* Theme.paddingLarge
                            width:  3* Theme.paddingLarge
                            source: application.source + avatar.replace("{size}",  3* Theme.paddingLarge)
                            layer.enabled: true
                            layer.effect: OpacityMask {
                                maskSource: Item {
                                    width: ava.width
                                    height: ava.height

                                    Rectangle {
                                        anchors.centerIn: parent
                                        width: Math.min(ava.width, ava.height)
                                        height: ava.height
                                        radius: Math.min(width, height)
                                    }
                                }
                            }
                        }
                    }
                    Column {
                        width: parent.width - subMetadata.width - ava.width
                        Label {
                            id: mainMetadata
                            text: loggedin.value != "-1" ? "<style>" +
                                                           "a { color: %1 }".arg(Theme.highlightColor) +
                                                           "</style>" + "<a href=\"https://forum.sailfishos.org/u/\"" + username + "/card.json\">" + username + stafftag + "</a>" : username + stafftag
                            onLinkActivated: pageStack.push("UserCard.qml", {username: username, loggedin: loggedin.value});
                            textFormat: Text.RichText
                            truncationMode: TruncationMode.Fade
                            elide: Text.ElideRight
                            width: parent.width
                            font.pixelSize: Theme.fontSizeMedium
                        }


                        Label {
                            visible: likes > 0
                            text: !acted ? likes + "♥" : likes + "💘"
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
                        Label {
                            text: reply_to >0 && reply_to !== last_postid ?  "💬"  : ""
                            color: Theme.secondaryColor
                            font.pixelSize: Theme.fontSizeSmall
                            anchors.right: parent.right
                        }
                        Icon {
                            visible: accepted_answer
                            source: "image://theme/icon-s-accept"
                            width: Theme.iconSizeSmall
                            height: width
                            anchors.right: parent.right
                            opacity: Theme.opacityLow
                        }
                    }
                }

                Label {
                    text: "<style>" +
                          "a { color: %1 }".arg(Theme.highlightColor) +
                          "</style>" +
                          "<p>" + cooked + "</p>"
                    width: parent.width
                    baseUrl: application.source
                    textFormat: Text.RichText
                    wrapMode: Text.Wrap
                    font.pixelSize: Theme.fontSizeSmall
                    onLinkActivated:{
                        var link1= /^https:\/\/forum.sailfishos.org\/t\/([\w-]*[a-z-]+[\w-]+\/)?(\d+)\/?(\d+)*/.exec(link)
                        if (!link1 && /^https:\/\/forum.sailfishos.org\/t\/[\w-]+?\/?/.exec(link)){
                            getRedirect(link);
                        } else if ( !link1){
                            if (link.indexOf("/") === 0)
                                link = "https://forum.sailfishos.org" + link
                            pageStack.push("OpenLink.qml", {link: link});

                        }  else {
                            var post_number = link1[3] ? link1[3] : -1
                            pageStack.push("ThreadView.qml", { "topicid": link1[2], "post_number": post_number });
                        }
                    }
                }
                Flow { id: pollsItem
                    visible: has_polls
                    property int cols: 3
                    width: parent.width
                    Label { id: pollHeader
                        width: parent.width
                        text: (has_polls > 1 )
                            ? qsTr("This post contains polls.")
                            : qsTr("This post contains a poll.")
                            + " " + qsTr("Click to view and vote:")
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.highlightColor
                    }
                    Repeater {
                        model: has_polls
                        delegate: ValueButton { id: pollButt
                            property int pollindex: index
                            onClicked: {
                                const pd = polldata.get(pollindex)
                                console.debug("Opening poll no", pollindex, "for post", postid, ", data:", JSON.stringify(pd,null,2))
                                pageStack.push("PollView.qml",
                                    { "key": loggedin.value, "postid": postid,
                                      "polldata": pd["poll"],
                                      "submitted_votes": pd["votes"]["list"]
                                    }
                                );
                            }
                            label: qsTr("Poll")
                            value: '#' + Number(pollindex + 1)
                            width: Math.floor(pollsItem.width/pollsItem.cols)
                        }
                    }
                }
            }
            menu: ContextMenu {

                MenuItem{
                    text: qsTr("Copy to clipboard");
                    onClicked: getraw(postid, 1);
                }
                MenuItem {
                    text: qsTr("Copy link to clipboard")
                    onClicked: Clipboard.text = source + "/" + post_number
                }

                MenuItem {
                    visible: version > 1 && updated_at !== created_at
                    text: qsTr("Revision history")
                    onClicked: pageStack.push(Qt.resolvedUrl("PostView.qml"), {postid: postid, aTitle: aTitle, curRev: version, vmode: 0});
                }
                MenuItem {
                    visible: cooked.indexOf("<code") !== -1
                    text: qsTr("Alternative formatting")
                    onClicked: pageStack.push(Qt.resolvedUrl("PostView.qml"), {postid: postid, aTitle: aTitle, curRev: version, cooked: cooked});
                }
                MenuItem {
                    visible: reply_to > 0 && reply_to !== last_postid
                    text: qsTr("Show replied to post")
                    onClicked: findOP(reply_to);

                }
                MenuItem {
                    visible: cooked_hidden
                    text: qsTr("Uncensor post")
                    onClicked: uncensor(postid, index);
                }
                MenuItem {
                    visible: loggedin.value != "-1" && !acted && !yours
                    text: qsTr("Like")
                    onClicked: like(postid, index);
                }
                MenuItem {
                    visible: loggedin.value != "-1" && !tclosed
                    text: qsTr("Reply")
                    onClicked: postreply(topicid, post_number, postid, username);
                }
                MenuItem {
                    visible: loggedin.value != "-1" && acted && !yours && can_undo
                    text: qsTr("Unlike")
                    onClicked: unlike(postid, index);
                }
                MenuItem {
                    visible: loggedin.value != "-1"  && can_edit
                    text: qsTr("Edit")
                    onClicked: newedit(postid);
                }
                MenuItem {
                    visible: loggedin.value != "-1"  && yours && can_delete
                    text: qsTr("Delete")
                    onClicked: del(postid, index);
                }
                MenuItem { text: qsTr("Filter user")

                    onClicked: {
                        //         getusername(user_id);
                        filterlist.setValue(user_id, username);
                        filterlist.setValue("set", 1);
                    }
                }

            }
        }

        Component.onCompleted: commentpage.getcomments();

    }
    onBusyChanged: {
        if(busy == false){
            if (post_number < 0) return;
            var comment;

            if (post_id === -1 && post_number >= 0 && post_number !== highest_post_number) {
                for (var j = 0; j < list.count; j++) {
                    comment = list.model.get(j);
                    if (comment && comment.post_number === post_number) {
                        if (highest_post_number){
                            list.positionViewAtIndex(j + 1, ListView.Beginning);
                        } else {
                            list.positionViewAtIndex(j, ListView.Beginning);
                        }
                    }
                }
            } else if (post_id >= 0) {
                for(var i=post_number - (highest_post_number - posts_count) - 1;i<=post_number;i++){
                    comment = list.model.get(i)
                    if (post_id && comment && comment.postid === post_id){
                        list.positionViewAtIndex(i, ListView.Beginning);
                    }
                }
            }


        }
    }
}
