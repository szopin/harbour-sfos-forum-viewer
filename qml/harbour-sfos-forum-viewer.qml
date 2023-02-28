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
import Nemo.Configuration 1.0
import "pages"

ApplicationWindow
{
    id: application
    initialPage: Component { FirstPage { } }
    cover: Qt.resolvedUrl("cover/CoverPage.qml")

    // ================================
    // ATTENTION: UPDATE BEFORE RELEASE
    // --------------------------------
    readonly property string appVersion: "1.8.1"
    // ================================

    property bool fetching: false
    property string login
    property bool checkemb
    property var latest: ListModel{id: latest}
    readonly property string source: "https://forum.sailfishos.org/"
    //: date format including date and time but no weekday
    readonly property string dateTimeFormat: qsTr("d/M/yyyy '('hh':'mm')'")
    ConfigurationGroup {
        id: mainConfig
        path: "/apps/harbour-sfos-forum-viewer"
    }
    ConfigurationValue {
        id: checkem
        key: "/apps/harbour-sfos-forum-viewer/checkem"
    }
    ConfigurationValue {
        id: loggedin
        key: "/apps/harbour-sfos-forum-viewer/key"
    }

    property QtObject categories: QtObject {
        property bool networkError: false
        property var model: ListModel { id: categoriesModel }
        property var lookup: ({})

        function fetch() {
            var xhr = new XMLHttpRequest;
            xhr.open("GET", application.source + "categories.json?include_subcategories=true");
            if (loggedin.value && (loggedin.value != -1)) xhr.setRequestHeader("User-Api-Key", loggedin.value);
            xhr.onreadystatechange = function() {
                if (xhr.readyState === XMLHttpRequest.DONE) {
                    if (xhr.responseText === "") {
                        model.clear();
                        networkError = true;
                        return;
                    }

                    var data = JSON.parse(xhr.responseText);
                    model.clear();
                    lookup = {};

                    function addCategory(item, isSub) {
                        var append = {
                            name: item['name'],
                            topic: item['id'],
                            color: item['color'],
                            topic_count: item['topic_count'],
                            description_text: item['description_text'],
                            slug: item['slug'],
                            topic_template: item['topic_template'],
                            is_subcategory: (!!isSub),
                            parent_category_id: isSub ? item['parent_category_id'] : -1
                        };
                        lookup[item['id']] = append;
                        model.append(append);
                    }

                    for (var i = 0; i < data.category_list.categories.length; i++) {
                        var item = data.category_list.categories[i];
                        addCategory(item, false);
                        if (item['has_children']) {
                            for (var j = 0; j < item.subcategory_list.length; j++) {
                                addCategory(item.subcategory_list[j], true);
                            }
                        }

                    }

                    lookupChanged();
                }
            }
            xhr.send();
        }
    }

    signal reload()
    onReload: {
        fetchLatestPosts();

        if (categories.model.count === 0) {
            categories.fetch();
        }
    }

    function formatJsonDate(date) {
        return new Date(date).toLocaleString(Qt.locale(), dateTimeFormat);
    }

    function fetchLatestPosts() {
        application.latest.clear()
        fetching = true
        var xhr = new XMLHttpRequest;
        xhr.open("GET", source + "latest.json");
        if (loggedin.value && (loggedin.value != -1)) xhr.setRequestHeader("User-Api-Key", loggedin.value);
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.responseText !== "") {
                    var data = JSON.parse(xhr.responseText);
                    var topics = data.topic_list.topics;
                    var topics_length = Math.min(topics.length, 11);

                    for (var i=0;i<topics_length;i++) {
                        var topic = topics[i];
                        if (topic.bumped){
                            application.latest.append({title: topic.title, posts_count: topic.posts_count})
                        }
                    }
                }

                fetching = false
            }
        }
        xhr.send();
    }

    Component.onCompleted: {
        login = mainConfig.value("key", "-1");
        mainConfig.setValue("key", login);
        checkemb = mainConfig.value("checkem", false);
        mainConfig.setValue("checkem", checkemb);
        console.log(checkem.value, loggedin.value)
        categories.fetch();
        fetchLatestPosts();
    }
}
