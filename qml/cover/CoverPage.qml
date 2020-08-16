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

CoverBackground {
    SilicaListView {
        id: view
        clip: true

        anchors {
            top: parent.top; bottom: coverActionArea.top
            left: parent.left; right: parent.right
            margins: Theme.paddingMedium
        }

        VerticalScrollDecorator { id: scrollBar; flickable: view }

        header: Label {
            text: qsTr("Latest posts")
            font.pixelSize: Theme.fontSizeSmall
            visible: view.model.count > 0 && !application.fetching
        }

        model: application.latest
        delegate: ListItem {
            id: item
            anchors.topMargin: Theme.paddingSmall
            height: postsLabel.height + Theme.paddingSmall
            opacity: 1.0 - ((item.y - view.contentY)/view.height * 0.3)

            Row {
                width: parent.width
                spacing: Theme.paddingSmall

                Item {
                    id: postsLabel
                    anchors.verticalCenter: entryLabel.verticalCenter
                    height: 1.3*Theme.fontSizeTiny; width: height

                    Label {
                        anchors.centerIn: parent
                        width: 0.9*parent.width; height: 0.9*parent.height
                        text: posts_count
                        minimumPixelSize: 0.6*Theme.fontSizeTiny
                        fontSizeMode: Text.Fit
                        font.pixelSize: Theme.fontSizeTiny
                        color: Theme.primaryColor
                        opacity: Theme.opacityHigh
                        horizontalAlignment: Text.AlignHCenter
                    }

                    Rectangle {
                        radius: 10
                        color: Theme.secondaryColor
                        anchors.fill: parent
                        opacity: Theme.opacityFaint
                    }
                }

                Label {
                    id: entryLabel
                    color: Theme.primaryColor
                    font.pixelSize: Theme.fontSizeExtraSmall
                    text: title
                    truncationMode: TruncationMode.Fade
                    elide: Text.ElideNone
                    width: parent.width - postsLabel.width - parent.spacing
                }
            }
        }

        Column {
            id: placeholderColumn
            visible: view.count === 0

            spacing: Theme.paddingSmall
            anchors {
                left: parent.left; right: parent.right
                verticalCenter: parent.verticalCenter
            }

            Label {
                width: parent.width; horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere; font.pixelSize: Theme.fontSizeLarge
                //: part of 'SailfishOS Forum Viewer'
                text: qsTr("SailfishOS")
                color: Theme.highlightColor
                opacity: 1.0
            }

            Label {
                width: parent.width; horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap; font.pixelSize: Theme.fontSizeMedium
                opacity: Theme.opacityHigh
                //: part of 'SailfishOS Forum Viewer'
                text: qsTr("Forum Viewer")
                color: Theme.highlightColor
                maximumLineCount: 5
                truncationMode: TruncationMode.Fade
                elide: Text.ElideRight
            }

            Item { width: parent.width; height: 2*Theme.paddingMedium }

            BusyIndicator {
                anchors.horizontalCenter: parent.horizontalCenter
                running: true
                Behavior on opacity { NumberAnimation { duration: 100 } }
                opacity: application.fetching ? 1.0 : 0.0

                // BusyIndicator animations are normally disabled
                // on the cover page, so we have to animate it manually
                NumberAnimation on rotation {
                    from: 0; to: 360
                    duration: 2500
                    loops: Animation.Infinite
                    running: application.fetching
                }
            }
        }
    }

    CoverActionList {
        id: coverAction
        CoverAction {
            iconSource: "image://theme/icon-cover-refresh"
            onTriggered: {
                application.reload()
            }
        }
    }
}
