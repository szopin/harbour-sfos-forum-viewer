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

import QtQuick 2.0
import Sailfish.Silica 1.0


Page {
    property string initialSearch
    property int searchid
    property string aTitle
    readonly property string searchstring: {
        var res = application.source + "search.json?"
        if (searchid) {
            res += "context=topic&context_id=" + searchid + "&"
        }
        res += "q="
        return res
    }
    property bool haveResults: false

    function _reset() {
        list.headerItem.searchField.text = ""
        list.model.clear()

        viewPlaceholder.text = ""
        viewPlaceholder.hintText = aTitle && qsTr("Searching in “%1”").arg(aTitle)
        list.headerItem.searchField.forceActiveFocus()
    }

    function getcomments(text){
        busyIndicator.running = true;
        var xhr = new XMLHttpRequest;
        xhr.open("GET", searchstring + text);
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                busyIndicator.running = false;
                var data   = JSON.parse(xhr.responseText);
                var posts  = data.posts;
                var topics = data.topics;
                var firstTopic = topics[0];
                list.model.clear();
                if(posts[0]){
                    haveResults = true;
                    var posts_length = posts.length
                    for (var i=0;i<posts_length;i++) {
                        var post = posts[i]
                        var topic = searchid ? firstTopic : topics[i]
                        list.model.append({blurb: post.blurb, topicid: post.topic_id, title: topic.title, post_number: post.post_number, posts_count: topic.posts_count, post_id: post.id, highest_post_number: topic.highest_post_number});
                    }
                } else {
                    //: part of 'No results in "foo"'
                    viewPlaceholder.text = qsTr("No results");
                    //: part of 'No results in "foo"'
                    viewPlaceholder.hintText = aTitle && qsTr("in “%1”").arg(aTitle)
                    haveResults = false;
                }
            }
        }
        xhr.send();
    }

    function _search(text) {
        list.headerItem.searchField.text = text
        viewPlaceholder.text = ""
        getcomments(text);
        forceActiveFocus()
    }

    id: page
    allowedOrientations: defaultAllowedOrientations

    onStatusChanged: {
        if (status === PageStatus.Active) {
            if (initialSearch) {
                list.headerItem.searchField.text = initialSearch
                _search(initialSearch)
            } else if (!list.headerItem.searchField.text) {
                _reset()
            }
        }
    }

    SilicaListView
    {
        id: list
        anchors.fill: parent
        model: ListModel { id: model}

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

                Label {
                    text: title
                    wrapMode: Text.Wrap
                    maximumLineCount: 2
                    elide: Text.ElideRight
                    width: parent.width
                    font.pixelSize: Theme.fontSizeSmall
                }

                Label {
                    text: blurb
                    wrapMode: Text.Wrap
                    elide: Text.ElideRight
                    width: parent.width
                    color: highlighted ? Theme.secondaryHighlightColor
                                       : Theme.secondaryColor
                    font.pixelSize: Theme.fontSizeSmall
                }
            }

            onClicked: {
                var name = list.model.get(index).name
                if(haveResults) {
                    pageStack.push("ThreadView.qml", {"aTitle": title, "topicid": topicid, "post_number": post_number, "posts_count": posts_count, "post_id": post_id, "highest_post_number": highest_post_number});
                }
            }
        }

        header: Column {
            property alias searchField: searchField

            width: parent.width

            PageHeader {

                title: qsTr("Search")
            }

            SearchField {
                id: searchField
                width: parent.width

                placeholderText: aTitle === "" ? qsTr("Search in all threads")
                                               : qsTr("Search in the current thread")

                EnterKey.enabled: text.length > 2
                EnterKey.iconSource: "image://theme/icon-m-enter-accept"
                EnterKey.onClicked: _search(text)

                onTextChanged: if (!text) _reset()
            }
        }



        VerticalScrollDecorator { }

        ViewPlaceholder {
            id: viewPlaceholder
            enabled: list.count === 0 && !busyIndicator.running
        }

        BusyIndicator {
            id: busyIndicator
            size: BusyIndicatorSize.Large
            anchors.centerIn: parent
            running: false
        }
    }
}
