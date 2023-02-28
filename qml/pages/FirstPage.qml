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
import Nemo.Configuration 1.0
import Nemo.Notifications 1.0
import Nemo.KeepAlive 1.2

Page {
    id: firstPage
    allowedOrientations: Orientation.All
    property string tid
    property string category
    property string topic_template
    property int pageno: 0
    property int timerv
    property string lastnotv
    property var tags
    property string fancy_title
    property string orig_name
    property string disp_name
    property bool checkemb
    property bool read
    property string login
    property string viewmode
    property string textname
    property string combined: application.source + (tid ? "c/" + tid : viewmode) + ".json?page=" + pageno
    property string combined2: application.source + "notifications.json"
    property bool networkError: false
    property bool loadedMore: false


    function newtopic(raw, title, category){
        var xhr = new XMLHttpRequest;
        const json = {
            "raw": raw,
            "title": title,
            "category": category
        };
        xhr.open("POST", "https://forum.sailfishos.org/posts/");
        xhr.setRequestHeader("User-Api-Key", loggedin.value);
        xhr.setRequestHeader("Content-Type", 'application/json');
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE){
                if(xhr.statusText !== "OK"){
                    pageStack.completeAnimation();
                    pageStack.push("Error.qml", {errortext: xhr.responseText});
                } else {

                    console.log(xhr.responseText);
                    clearview();
                }
            }
        }
        xhr.send(JSON.stringify(json));
    }

    function newPM(raw, title, target_recipients){
        var xhr = new XMLHttpRequest;
        const json = {
            "raw": raw,
            "title": title,
            "target_recipients": target_recipients,
            "archetype": "private_message"
        };
        xhr.open("POST", "https://forum.sailfishos.org/posts/");
        xhr.setRequestHeader("User-Api-Key", loggedin.value);
        xhr.setRequestHeader("Content-Type", 'application/json');
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE){
                if(xhr.statusText !== "OK"){
                    pageStack.completeAnimation();
                    pageStack.push("Error.qml", {errortext: xhr.responseText});
                } else {

                    console.log(xhr.responseText);
                    var data = JSON.parse(xhr.responseText);
                    pageStack.push("ThreadView.qml", {
                                       "topicid": data.topic_id,
                                       "post_number": 0
                                   });
                    //   clearview();
                }
            }
        }
        xhr.send(JSON.stringify(json));
    }
    function clearview(){
        list.model.clear();
        pageno = 0;
        loadedMore = false;
        updateview();
    }

    function updateview() {
        var xhr = new XMLHttpRequest;

        xhr.open("GET", combined);
        if (loggedin.value !== "-1") xhr.setRequestHeader("User-Api-Key", loggedin.value);
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.responseText === "") {
                    list.model.clear();
                    networkError = true;
                    return;
                } else {
                    networkError = false;
                }

                var data = JSON.parse(xhr.responseText);
                var topics = data.topic_list.topics;

                // Filter bumped if required
                if (viewmode === "latest" && tid === ""){
                    topics = topics.filter(function(t) {
                        return t.bumped
                    })
                }

                var topics_length = topics.length;
                for (var i=0;i<topics_length;i++) {
                    var topic = topics[i];
                    tags = ""
                    if(topic.tags){
                        for(var t=0;t<topic.tags.length;t++){
                            tags = tags + topic.tags[t] + " "
                        }
                    }
                    list.model.append({ title: topic.title,
                                          topicid: topic.id,
                                          posts_count: topic.posts_count,
                                          bumped: topic.bumped_at,
                                          category_id: topic.category_id,
                                          ttags: tags,
                                          has_accepted_answer: topic.has_accepted_answer,
                                          highest_post_number: topic.highest_post_number
                                      });
                }

                if (data.topic_list.more_topics_url){
                    pageno++;
                } else {
                    pageno = 0;
                }
            }
        }

        xhr.send();
    }

    function checknotifications(){
        var xhr2 = new XMLHttpRequest;
        xhr2.open("GET", combined2);
        xhr2.setRequestHeader("User-Api-Key", loggedin.value);
        xhr2.onreadystatechange = function() {
            if (xhr2.readyState === XMLHttpRequest.DONE){
                if(xhr2.statusText !== "OK"){
                    pageStack.completeAnimation();
                    pageStack.push("Error.qml", {errortext: xhr2.responseText});
                } else {
                    var data2 = JSON.parse(xhr2.responseText);
                    var notifications = data2.notifications;
                    var notific = notifications[0];
                    if (notific.notification_type != 12){
                        var notid = notific.id

                        orig_name = notific.data.original_username
                        disp_name = notific.data.display_username
                        read = notific.read
                        fancy_title = notific.data.topic_title
                        if(notid != lastnot.value && lastnot.value != "-1" && !read){
                            notification.publish();
                        }
                        mainConfig.setValue("lastnot", notid);

                    }
                }
            }
        }
        xhr2.send();
    }
    function showLatest() {
        tid = "";
        textname = qsTr("Latest");
        viewmode = "latest";
        clearview();
    }

    function showTop() {
        viewmode = "top";
        tid = "";
        textname = qsTr("Top");
        clearview();
    }

    function showCategory(showTopic, showTextname, template, cat) {
        viewmode = "";
        tid = showTopic;
        textname = showTextname;
        topic_template = template;
        category = cat;
        clearview();

    }

    ConfigurationValue {
        id: loggedin
        key: "/apps/harbour-sfos-forum-viewer/key"
    }

    ConfigurationValue {
        id: checkem
        key: "/apps/harbour-sfos-forum-viewer/checkem"
    }
    ConfigurationValue {
        id: timer
        key: "/apps/harbour-sfos-forum-viewer/timer"
    }
    ConfigurationValue {
        id: lastnot
        key: "/apps/harbour-sfos-forum-viewer/lastnot"
    }
    onStatusChanged: {
        if (status === PageStatus.Active){
            pageStack.pushAttached(Qt.resolvedUrl("CategorySelect.qml"));
        }
    }

    ConfigurationGroup {
        id: mainConfig
        path: "/apps/harbour-sfos-forum-viewer"

        // We save metadata for every thread the user opened. We
        // have a nested ConfigurationGroup for every value
        // we track. The key is always the id (topicid).

        ConfigurationGroup {
            id: postCountConfig
            path: "/highest_post_number"
        }

        ConfigurationGroup {
            // We don't use this yet. We can use it to perform
            // some cleanup in the future, e.g. deleting all entries
            // that haven't been updated for 30 days.
            id: bumpedConfig
            path: "/bumped_at"
        }
    }
    Notification {
        id: notification
        category: "x-nemo.messaging.im"
        appName: "SFOS Forum Viewer"
        replacesId: 0
        appIcon: "/usr/share/icons/hicolor/86x86/apps/harbour-sfos-forum-viewer.png"
        summary: qsTr("New notification")
        urgency: Notification.Normal
        body: orig_name ? orig_name + " - " + fancy_title : disp_name  + " - " + fancy_title
        remoteActions: [ {"name": "default"}]
        onClicked: {
            application.activate()
            pageStack.push("Notifications.qml", {loggedin: loggedin.value});
        }
    }
    Connections {
        target: application
        onReload: {
            if (!loadedMore || viewmode === "latest"){
                pageno = 0;
                list.model.clear();
                firstPage.updateview();
            }
        }
    }

    SilicaListView {
        id:list
        anchors.fill: parent

        header: PageHeader {
            id: header
            title: textname === "" ? viewmode : textname
            description: qsTr("SailfishOS Forum")
        }

        footer: Item {
            width: parent.width
            height: Theme.horizontalPageMargin
        }

        PullDownMenu {
            id: pulley
            busy: application.fetching

            MenuItem {
                text: qsTr("About")
                onClicked: pageStack.push("About.qml");
            }

            MenuItem {
                text: qsTr("Login")
                visible:  loggedin.value != "-1" ? false : true
                onClicked: pageStack.push("LoginPage.qml");
            }

            MenuItem {
                text: qsTr("Logout")
                visible: loggedin.value != "-1" ? true : false
                onClicked: mainConfig.setValue("key", "-1");
            }
            MenuItem {
                text: qsTr("New thread")
                visible: loggedin.value != "-1" && tid ? true : false
                onClicked: pageStack.push("NewThread.qml", {category: category, raw: topic_template});
            }

            MenuItem {
                text: qsTr("Search")
                onClicked: pageStack.push("SearchPage.qml");

            }
            MenuItem {
                text: qsTr("Notifications")
                visible: loggedin.value != "-1"
                onClicked: pageStack.push("Notifications.qml", {loggedin: loggedin.value});
            }
            MenuItem {
                text: qsTr("Reload")
                onClicked: {
                    pulley.close()
                    clearview()

                }
            }
        }

        BusyIndicator {
            visible: running
            running: model.count === 0 && !networkError
            anchors.centerIn: parent
            size: BusyIndicatorSize.Large
        }

        ViewPlaceholder {
            enabled: model.count === 0 && networkError
            text: qsTr("Nothing to show")
            hintText: qsTr("Is the network enabled?")
        }

        model: ListModel { id: model}
        VerticalScrollDecorator {}
        Component.onCompleted: {
            login = mainConfig.value("key", "-1");
            mainConfig.setValue("key", login);
            checkemb = mainConfig.value("checkem", false);
            mainConfig.setValue("checkem", checkemb);
            timerv = mainConfig.value("timer", "10");
            mainConfig.setValue("timer", timerv);
            lastnotv = mainConfig.value("lastnot", "-1");
            mainConfig.setValue("lastnot", lastnotv);
            showLatest();
        }

        delegate: BackgroundItem {
            id: item
            width: parent.width
            height: delegateCol.height + Theme.paddingLarge

            property int lastPostNumber: postCountConfig.value(topicid, -1)
            property bool hasNews: (lastPostNumber > 0 && lastPostNumber < highest_post_number)

            Column {
                id: delegateCol
                height: childrenRect.height
                width: parent.width - 2*Theme.horizontalPageMargin
                spacing: Theme.paddingSmall
                anchors {
                    verticalCenter: parent.verticalCenter
                    horizontalCenter: parent.horizontalCenter
                }

                Row {
                    width: parent.width
                    spacing: 1.5*Theme.paddingMedium

                    Column {
                        width: postsLabel.width
                        height: childrenRect.height
                        anchors.top: parent.top
                        spacing: Theme.paddingSmall

                        Label {
                            id: postsLabel
                            text: posts_count
                            minimumPixelSize: Theme.fontSizeTiny
                            fontSizeMode: "Fit"
                            font.pixelSize: Theme.fontSizeSmall
                            color: item.lastPostNumber < 0 ?
                                       Theme.primaryColor :
                                       (item.hasNews ?
                                            Theme.highlightColor :
                                            Theme.secondaryColor)
                            opacity: Theme.opacityHigh
                            height: 1.2*Theme.fontSizeSmall; width: height
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter

                            Rectangle {
                                anchors.centerIn: parent
                                width: parent.width+Theme.paddingSmall; height: parent.height
                                radius: 20
                                opacity: item.lastPostNumber < highest_post_number ?
                                             Theme.opacityLow :
                                             Theme.opacityFaint
                                color: item.hasNews ?
                                           Theme.secondaryHighlightColor :
                                           Theme.secondaryColor
                            }
                        }

                        Icon {
                            visible: has_accepted_answer
                            source: "image://theme/icon-s-accept"
                            width: Theme.iconSizeSmall
                            height: width
                            opacity: Theme.opacityLow
                        }
                    }

                    Column {
                        width: parent.width - postsLabel.width - parent.spacing

                        Label {
                            text: title
                            width: parent.width
                            wrapMode: Text.Wrap
                            font.pixelSize: Theme.fontSizeSmall
                            color: highlighted || item.hasNews
                                   ? Theme.highlightColor
                                   : (item.lastPostNumber < highest_post_number
                                      ? Theme.primaryColor
                                      : Theme.secondaryColor)
                        }

                        Row {
                            width: parent.width
                            spacing: Theme.paddingMedium

                            Label {
                                id: dateLabel
                                text: formatJsonDate(bumped)
                                wrapMode: Text.Wrap
                                elide: Text.ElideRight
                                width: (parent.width - 2*parent.spacing - catRect.width)/2
                                color: highlighted || item.hasNews ? Theme.secondaryHighlightColor
                                                                   : Theme.secondaryColor
                                font.pixelSize: Theme.fontSizeSmall
                                horizontalAlignment: Text.AlignLeft
                            }

                            Label {
                                visible: catRect.visible
                                text: categories.lookup[category_id].name
                                wrapMode: Text.Wrap
                                elide: Text.ElideRight
                                width: dateLabel.width
                                color: highlighted || item.hasNews ? Theme.secondaryHighlightColor
                                                                   : Theme.secondaryColor
                                font.pixelSize: Theme.fontSizeSmall
                                horizontalAlignment: Text.AlignRight
                            }

                            Rectangle {
                                id: catRect
                                visible: tid === ""
                                color: '#'+categories.lookup[category_id].color
                                width: 2*Theme.horizontalPageMargin
                                height: Theme.horizontalPageMargin/3
                                radius: 45
                                anchors.verticalCenter: parent.verticalCenter
                                opacity: Theme.opacityLow
                            }

                        }
                        Row {
                            visible: ttags
                            width: parent.width
                            spacing: Theme.paddingMedium
                            Label {
                                id: tags
                                visible: ttags
                                text: qsTr("tags") + ": " + ttags
                                wrapMode: Text.Wrap
                                elide: Text.ElideRight
                                width: parent.width
                                color: highlighted || item.hasNews ? Theme.secondaryHighlightColor
                                                                   : Theme.secondaryColor
                                font.pixelSize: Theme.fontSizeSmall
                                horizontalAlignment: Text.AlignLeft
                            }
                        }

                    }
                }
            }

            onClicked: {
                var name = list.model.get(index).name
                postCountConfig.setValue(topicid, highest_post_number);
                var oldLast = lastPostNumber;
                lastPostNumber = highest_post_number;
                pageStack.push("ThreadView.qml", {
                                   "aTitle": title,
                                   "topicid": topicid,
                                   "posts_count": posts_count,
                                   "post_number": oldLast,
                                   "highest_post_number": highest_post_number
                               });
            }
        }
        BackgroundJob {
            id: wakeup
            triggeredOnEnable: true
            enabled: checkem.value && loggedin.value != "-1"
            frequency: BackgroundJob.ThirtySeconds * 2 * timer.value
            onTriggered: {
                checknotifications();
                wakeup.finished();
            }
        }

        PushUpMenu {
            id: pupmenu
            visible: pageno != 0;
            MenuItem {
                text: qsTr("Load more")
                onClicked: {
                    pupmenu.close();
                    loadedMore = true;
                    firstPage.updateview();
                }
            }

        }
    }
}
