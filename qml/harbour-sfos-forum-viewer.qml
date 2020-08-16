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
import "pages"

ApplicationWindow
{
    id: application
    initialPage: Component { FirstPage { } }
    cover: Qt.resolvedUrl("cover/CoverPage.qml")
    property bool fetching: false
    property var latest: ListModel{id: latest}
    property string source: "https://forum.sailfishos.org/"
    readonly property string dateTimeFormat: qsTr("d/M/yyyy '('hh':'mm')'", "date format including date and time but no weekday")

    signal reload()
    onReload: fetchLatestPosts()

    function formatJsonDate(date) {
        return new Date(date).toLocaleString(Qt.locale(), dateTimeFormat);
    }

    function fetchLatestPosts() {
        application.latest.clear()
        fetching = true
        var xhr = new XMLHttpRequest;
        xhr.open("GET", source + "latest.json");
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.responseText !== "") {
                    var data = JSON.parse(xhr.responseText);

                    for (var i=0;i<data.topic_list.topics.length;i++) {
                        if ("bumped" in data.topic_list.topics[i] && data.topic_list.topics[i]["bumped"] === true){
                            if (i <= 10) {
                                application.latest.append({title: data.topic_list.topics[i]["title"], posts_count: data.topic_list.topics[i]["posts_count"]})
                            }
                        }
                    }
                }

                fetching = false
            }
        }
        xhr.send();
    }
}
