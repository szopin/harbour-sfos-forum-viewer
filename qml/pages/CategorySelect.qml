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
    id: categorySelectPage
    allowedOrientations: Orientation.All
    property bool networkError: false

    property var categoryTranslations: [
        QT_TR_NOOP("Get Started"),
        QT_TR_NOOP("Announcements"),
        QT_TR_NOOP("Applications"),
        QT_TR_NOOP("Platform Development"),
        QT_TR_NOOP("Localisation"),
        QT_TR_NOOP("Hardware Adaptation"),
        QT_TR_NOOP("Design"),
        QT_TR_NOOP("Bug Reports"),
        QT_TR_NOOP("Store QA"),
        QT_TR_NOOP("General"),
        QT_TR_NOOP("Site Feedback"),
    ]

    function findFirstPage() {
        return pageStack.find(function(page) { return (page._depth === 0); });
    }

   SilicaListView {
       id:list

       BusyIndicator {
           visible: running
           running: catmodel.count === 0 && !networkError
           anchors.centerIn: parent
           size: BusyIndicatorSize.Large
       }

       ViewPlaceholder {
           enabled: catmodel.count === 0 && networkError
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

           Item { width: parent.width; height: Theme.paddingSmall }
       }

       footer: Item { width: parent.width; height: Theme.horizontalPageMargin }

       anchors.top: header.bottom
       width: parent.width
       height: parent.height

       VerticalScrollDecorator {}
       model: ListModel { id: catmodel}

       Connections {
           target: application
           onReload: {
               if (catmodel.count === 0) {
                   list.reload();
               }
           }
       }

       Component.onCompleted: reload()

       function reload() {
           var xhr = new XMLHttpRequest;
           xhr.open("GET", "https://forum.sailfishos.org/categories.json");
           xhr.onreadystatechange = function() {
               if (xhr.readyState === XMLHttpRequest.DONE) {
                   if (xhr.responseText === "") {
                       catmodel.clear();
                       networkError = true;
                       return;
                   }

                   var data = JSON.parse(xhr.responseText);
                   catmodel.clear();

                   var categories = data.category_list.categories
                   var categories_length = categories.length
                   for (var i=0;i<categories_length;i++) {
                       var cat = categories[i]
                       catmodel.append({textname: qsTr(cat.name), topic: cat.id});
                   }
               }
           }
           xhr.send();
       }

       delegate: BackgroundItem {
           width: parent.width
           height: Theme.itemSizeSmall
           onClicked: {
               findFirstPage().showCategory(topic, textname);
               pageStack.navigateBack();
           }

           Label {
               id: theTitle
               text: textname
               wrapMode: Text.Wrap
               anchors {
                   left: parent.left; leftMargin: Theme.horizontalPageMargin
                   right: parent.right; rightMargin: Theme.horizontalPageMargin
                   verticalCenter: parent.verticalCenter
               }
           }
       }
   }
}
