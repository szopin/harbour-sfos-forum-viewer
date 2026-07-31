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

import QtQuick 2.6
import Sailfish.Silica 1.0

Page {
    id: categorySelectPage
    allowedOrientations: Orientation.All

    function findFirstPage() {
        return pageStack.find(function(page) { return page.hasOwnProperty('viewmode') });
    }

    /* FIXME: all the notification stuff is a 1:1 copy of the same for topics/threads in FirstPage.qml.
     *        This should be consolidated, as the only differemce is the PUT
     *        url, and the source of the current setting.
     */
    readonly property var watchlevel: [
        { "name": qsTr("Muted",    "Category watch level (state)"),
            "action": qsTr("Mute",   "Category watch action (verb)"),
            "smallicon": "image://theme/icon-m-speaker-mute",
            "icon": "image://theme/icon-m-speaker-mute"
        },
        { "name": qsTr("Normal",   "Category watch level (state)"),
            "action": qsTr("Normal", "Category watch action (verb)"),
            "smallicon": "",
            "icon": "image://theme/icon-m-favorite"
        },
        { "name": qsTr("Tracking", "Category watch level (state)"),
            "action": qsTr("Track",  "Category watch action (verb)"),
            "smallicon": "image://theme/icon-m-favorite",
            "icon": "image://theme/icon-m-favorite-selected"
        },
        { "name": qsTr("Watching", "Category watch level (state)"),
            "action": qsTr("Watch",  "Category watch action (verb)"),
            "smallicon": "image://theme/icon-m-alarm",
            "icon": "image://theme/icon-m-alarm"
        }
    ]
    // level being one of 0, 1, 2, 3; representing muted, normal, tracking, watching
    // !! payload wants a string so "0", not 0
    function setNotificationLevel(index, catid, level){
        if (loggedin.value == "-1") return
        console.debug("Setting watch level to", level, ",", watchlevel[Number(level)].name)
        var xhr = new XMLHttpRequest;
        const json = {
            "notification_level": level
        };
        xhr.open("POST", application.source + "/category/" + catid + "/notifications.json");
        xhr.setRequestHeader("User-Api-Key", loggedin.value);
        xhr.setRequestHeader("Content-Type", 'application/json');
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE){
                if(xhr.statusText !== "OK"){
                    pageStack.completeAnimation();
                    pageStack.push("Error.qml", {errortitle: xhr.status + " " + xhr.statusText, errortext: xhr.responseText});
                } else {
                    console.log(xhr.responseText);
                    // update the topic properties
                    list.model.setProperty(index, "notification_level", level)
                }
            }
        }
        xhr.send(JSON.stringify(json));
    }


   SilicaListView {
       id:list

       BusyIndicator {
           visible: running
           running: categories.model.count === 0 && !categories.networkError
           anchors.centerIn: parent
           size: BusyIndicatorSize.Large
       }

       ViewPlaceholder {
           enabled: categories.model.count === 0 && categories.networkError
           text: qsTr("Nothing to show")
           hintText: qsTr("Is the network enabled?")
       }

       header: Column {
           width: list.width; height: childrenRect.height
           spacing: 0

           PageHeader {
               id: pageHeader
               title: qsTr("Categories")
           }

           Row {
               anchors.horizontalCenter: pageHeader.horizontalCenter
               spacing: Theme.paddingSmall

               Button {
                   text: qsTr("Latest")
                   onClicked: {
                       findFirstPage().showLatest();
                       pageStack.navigateBack();
                   }
               }
               Button {
                   text: qsTr("Top")
                   onClicked: {
                       findFirstPage().showTop();
                       pageStack.navigateBack();
                   }
               }
           }

           Item { width: parent.width; height: 2*Theme.paddingMedium }
       }

       footer: Item { width: parent.width; height: Theme.horizontalPageMargin }

       anchors.top: header.bottom
       width: parent.width
       height: parent.height

       VerticalScrollDecorator {}
       model: categories.model
       spacing: Theme.paddingLarge

       delegate: ListItem {
           id: item
           width: ListView.view.width
           contentHeight: contentCol.height

           menu: ContextMenu { id: ctxmenu
                property int wantLevel: notification_level
                onClosed: if (wantLevel != notification_level) {
                              setNotificationLevel(index, topic, wantLevel)
                          }
                MenuLabel { height: buttons.height
                    visible: loggedin.value !== "-1"
                    anchors.horizontalCenter: parent.horizontalCenter
                    Grid{ id: buttons
                        rows: 1
                        columns: watchlevel.length
                        spacing: Theme.paddingLarge
                        anchors.centerIn: parent
                        Repeater { id: rep
                            model: watchlevel
                            delegate: BackgroundItem { id: bitem
                                height: iconcol.height + Theme.paddingSmall
                                width: iconcol.height
                                Column { id: iconcol
                                    width: parent.width
                                    spacing: Theme.paddingSmall
                                    anchors.verticalCenter: parent.verticalCenter
                                    Icon { id: icon
                                        width: Theme.iconSizeSmallPlus
                                        height: width
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        source: modelData.icon + "?" + (highlighted ? Theme.highlightColor : Theme.primaryColor)
                                        highlighted: bitem.down || (index == ctxmenu.wantLevel)
                                    }
                                    Label {
                                        anchors.horizontalCenter: icon.horizontalCenter
                                        text: modelData.action
                                        font.pixelSize: Theme.fontSizeExtraSmall
                                        color: icon.highlighted ? Theme.highlightColor : Theme.primaryColor
                                        highlighted: icon.highlighted
                                    }
                                }
                                // only change value when menu is closed
                                onClicked: ctxmenu.wantLevel = index
                            }
                        }
                    }
                }
                MenuItem { text: qsTr("Copy RSS feed link")
                    onClicked: Clipboard.text = "https://forum.sailfishos.org/c/" + topic + ".rss"
                }
                /*
                MenuItem { text: qsTr("Open RSS feed")
                    onClicked: Qt.openUrlExternally("https://forum.sailfishos.org/c/" + topic + ".rss")
                }
                */
           }
           onClicked: {
               findFirstPage().showCategory( ((is_subcategory) ? categories.lookup[parent_category_id].slug + "/" : "") + slug + "/" + topic, name, topic_template, topic);
               pageStack.navigateBack();
           }
           Rectangle {
               id: rect
               anchors {
                   left: parent.left; leftMargin: Theme.horizontalPageMargin
                   verticalCenter: contentCol.verticalCenter
               }
               height: contentCol.height*0.95
               width: Theme.horizontalPageMargin/3
               color: '#'+model.color
               radius: 30
           }

           Column {
               id: contentCol
               width: parent.width - 2*Theme.horizontalPageMargin - rect.width - Theme.paddingMedium
               bottomPadding: Theme.paddingSmall
               anchors {
                   right: parent.right
                   rightMargin: Theme.horizontalPageMargin
               }
               Row {
                   width: parent.width
                   spacing: Theme.paddingSmall
                   Label {
                       text: (is_subcategory ? categories.lookup[parent_category_id].name + ": " : "" ) + name
                       wrapMode: Text.Wrap
                       anchors.bottom: parent.bottom
                   }
                   Icon {
                       visible: source != ""
                       anchors.bottom: parent.bottom
                       source: ((notification_level >= 0 && loggedin.value !== "-1")
                                  ? watchlevel[notification_level].smallicon
                                  : "")
                       width: Theme.iconSizeSmall
                       height: width
                   }
               }

               Label {
                   width: parent.width
                   elide: Text.ElideRight
                   textFormat: Text.RichText
                   text: description_text
                   wrapMode: Text.Wrap
                   font.pixelSize: Theme.fontSizeExtraSmall
                   color: Theme.secondaryColor
               }
           }
       }
   }
}
