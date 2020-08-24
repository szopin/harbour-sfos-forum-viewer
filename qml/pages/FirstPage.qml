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

Page {
    id: firstPage
    allowedOrientations: Orientation.All
    property string tid
    property int pageno: 0
    property string viewmode
    property string textname
    property string combined: application.source + (tid ? "c/" + tid : viewmode) + ".json?page=" + pageno
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
                    list.model.append({ title: topic.title,
                                          topicid: topic.id,
                                          posts_count: topic.posts_count,
                                          bumped: topic.bumped_at,
                                          category_id: topic.category_id,
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
                text: qsTr("Search")
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
        }

        delegate: BackgroundItem {
            id: item
            width: parent.width
            height: delegateCol.height + Theme.paddingLarge

            property int lastPostNumber: postCountConfig.value(topicid, -1)
            // Component.onCompleted: console.debug("lastPostNumber [%1]:\tlast=%2\tnow=%3".arg(topicid).arg(lastPostNumber).arg(highest_post_number))

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
                                       (item.lastPostNumber < highest_post_number ?
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
                                color: (item.lastPostNumber > 0 && item.lastPostNumber < highest_post_number) ?
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
                               color: highlighted ? Theme.secondaryHighlightColor
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
                               color: highlighted ? Theme.secondaryHighlightColor
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

                    }
                }
            }

            onClicked: {
                var name = list.model.get(index).name
                postCountConfig.setValue(topicid, highest_post_number);
                lastPostNumber = highest_post_number;
                pageStack.push("ThreadView.qml", {
                                   "aTitle": title,
                                   "topicid": topicid,
                                   "posts_count": posts_count,
                                   "last_seen": lastPostNumber
                               });
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
