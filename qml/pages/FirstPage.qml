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
    id: firstPage
    allowedOrientations: Orientation.All
    property string source: "https://forum.sailfishos.org/"
    property string tid
    property int pageno: 0
    property string viewmode
    property string textname
    property string combined: tid == "" ? source + viewmode + ".json?page=" + pageno : source + "c/" + tid + ".json?page=" + pageno
    property bool networkError: false
    property bool loadedMore: false

    function clearview(){
        list.model.clear();
        pageno = 0;
        loadedMore = false;
        updateview();
    }
    function updateview() {
        var xhr = new XMLHttpRequest;

        xhr.open("GET", combined);
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

                if (viewmode === "latest" && tid === ""){

                    for (var i=0;i<data.topic_list.topics.length;i++) {
                        if ("bumped" in data.topic_list.topics[i] && data.topic_list.topics[i]["bumped"] === true){
                            list.model.append({title: data.topic_list.topics[i]["title"], topicid: data.topic_list.topics[i]["id"], posts_count: data.topic_list.topics[i]["posts_count"], bumped: data.topic_list.topics[i]["bumped_at"]});


                        }
                    }

                } else {
                    for (var j=0;j<data.topic_list.topics.length;j++) {
                        list.model.append({title: data.topic_list.topics[j]["title"], topicid: data.topic_list.topics[j]["id"], posts_count: data.topic_list.topics[j]["posts_count"], bumped: data.topic_list.topics[j]["bumped_at"]});

                    }

                }
                var more = 'more_topics_url';
                if (data.topic_list[more]){
                    pageno++;

                } else {
                    pageno = 0;

                }
            }
        }

        xhr.send();
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

    function showCategory(showTopic, showTextname) {
        viewmode = "";
        tid = showTopic;
        textname = showTextname;
        clearview();
    }

    onStatusChanged: {
        if (status === PageStatus.Active){
            pageStack.pushAttached(Qt.resolvedUrl("CategorySelect.qml"));
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
                text: "About"
                onClicked: pageStack.push("About.qml");
            }
            MenuItem {
                text: "Search"
                onClicked: pageStack.push("SearchPage.qml");

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
            showLatest();
            application.fetchLatestPosts();
        }

        delegate: BackgroundItem {
            width: parent.width
            height: delegateCol.height + Theme.paddingLarge

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
                    Label {
                        id: postsLabel
                        text: posts_count
                        minimumPixelSize: Theme.fontSizeTiny
                        fontSizeMode: "Fit"
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.primaryColor
                        opacity: Theme.opacityHigh
                        height: 1.2*Theme.fontSizeSmall; width: height
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        anchors.top: parent.top

                        Rectangle {
                            anchors.centerIn: parent
                            width: parent.width+Theme.paddingSmall; height: parent.height
                            radius: 20
                            opacity: Theme.opacityLow
                            color: Theme.secondaryColor
                        }
                    }

                    Column {
                        width: parent.width - postsLabel.width - parent.spacing

                        Label {
                            text: title
                            width: parent.width
                            wrapMode: Text.Wrap
                            font.pixelSize: Theme.fontSizeSmall
                        }
                        Label {
                            text: formatJsonDate(bumped)
                            wrapMode: Text.Wrap
                            elide: Text.ElideRight
                            width: parent.width
                            color: highlighted ? Theme.secondaryHighlightColor
                                               : Theme.secondaryColor
                            font.pixelSize: Theme.fontSizeSmall
                            horizontalAlignment: Text.AlignLeft
                        }
                    }
                }
            }

            onClicked: {
                var name = list.model.get(index).name
                pageStack.push("ThreadView.qml", {"aTitle": title, "topicid": topicid, "posts_count": posts_count});
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
