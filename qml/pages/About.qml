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
                title: "About"
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
                text: "SFOS Forum Viewer"
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
                text: qsTr("SFOS Forum Viewer for Sailfish OS v0.7.6\n" +
                           "By szopin\n" +
                           "Licensed under MIT\n\n" +
                           "App icon by dseight\n" +
                           "AboutPage art by Hanibu\n\n" +
                           "Special thanks to contributors:\n") +
                      ["carlosgonz", "elros34", "ichthyosaurus", "Moppa5"].join(
                          qsTr(", ", "contributors list separator"));
            }
            Item {
                width: parent.width
                height: 1.5*Theme.paddingLarge
            }

            Button {
                id: github
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Github"
                onClicked: Qt.openUrlExternally("https://github.com/szopin/harbour-sfos-forum-viewer");
            }

            Item {
                width: 1
                height: Theme.paddingLarge
            }

            Button {
                id: license
                anchors.horizontalCenter: parent.horizontalCenter
                text: "License"
                onClicked: Qt.openUrlExternally("https://github.com/szopin/harbour-sfos-forum-viewer/blob/master/LICENSE");
            }

            Item {
                width: 1
                height: Theme.paddingMedium
            }
        }
    }
}
