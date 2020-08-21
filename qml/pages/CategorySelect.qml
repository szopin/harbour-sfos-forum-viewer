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

    function findFirstPage() {
        return pageStack.find(function(page) { return (page._depth === 0); });
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
           width: parent.width
           contentHeight: contentCol.height
           onClicked: {
               findFirstPage().showCategory(topic, name);
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
               anchors {
                   right: parent.right
                   rightMargin: Theme.horizontalPageMargin
               }

               Label {
                   width: parent.width
                   text: name
                   wrapMode: Text.Wrap
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
