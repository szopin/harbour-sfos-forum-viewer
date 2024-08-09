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
    id: aboutPage

    SilicaFlickable {
        id: flickable
        anchors.fill: parent
        contentWidth: column.width
        contentHeight: column.height

        Column {
            id: column
            width: flickable.width

            PageHeader {
                id: header;
                title: qsTr("About")
            }

            Image {
                id: appIcon
                fillMode: Image.PreserveAspectFit
                smooth: true
                source: "../img/harbour-sfos-forum-viewer.png"
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Item {
                width: parent.width
                height: Theme.paddingLarge
            }

            Label {
                id: appName
                text: "SFOS Forum Viewer" // not to be translated for now
                anchors.horizontalCenter: parent.horizontalCenter
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeLarge
            }

            Item {
                width: parent.width
                height: Theme.paddingMedium
            }

            Text {
                id: desc
                anchors {
                    left: parent.left;
                    right: parent.right;
                    margins: Theme.horizontalPageMargin
                }
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.primaryColor
                wrapMode: Text.Wrap
                text: qsTr("SFOS Forum Viewer for Sailfish OS v%1\n" +
                           "By szopin\n" +
                           "Licensed under MIT\n\n" +
                           "App icon by dseight\n" +
                           "AboutPage art by Hanibu\n\n" +
                           "Special thanks to contributors:\n").arg(application.appVersion) +
                      ["247", "Åke Engelbrektson", "Black Sheep", "carlosgonz", "ccontino84", "elros34", "ichthyosaurus", "mentaljam", "Moppa5", "nephros", "pherjung", "vige", "友橘 (Youju)"].join(
                          //: contributors list separator
                          qsTr(", "));
            }
            Item {
                width: parent.width
                height: 1.5*Theme.paddingLarge
            }

            Button {
                id: github
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Source code")
                onClicked: Qt.openUrlExternally("https://github.com/szopin/harbour-sfos-forum-viewer");
            }

            Item {
                width: 1
                height: Theme.paddingLarge
            }

            Button {
                id: license
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("License")
                onClicked: Qt.openUrlExternally("https://github.com/szopin/harbour-sfos-forum-viewer/blob/master/LICENSE");
            }

            Item {
                width: 1
                height: Theme.paddingMedium
            }
        }
    }
}
