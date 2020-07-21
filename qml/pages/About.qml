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

            Label {
                id: appName
                text: "SFOS Forum Viewer"
                anchors.horizontalCenter: parent.horizontalCenter
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeLarge
            }

            Item {
                width: 1
                height: Theme.paddingMedium
            }

            Text {
                id: desc
                anchors {
                    left: parent.left;
                    right: parent.right;
                    margins: Theme.paddingMedium
                }
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: Theme.fontSizeExtraSmall
                color: Theme.primaryColor
                wrapMode: Text.Wrap
                text: "SFOS Forum Viewer for Sailfish OS v0.5\nBy szopin\nLicensed under MIT\n\nSpecial thanks to contributors:\n\nelros34\n";
            }
            Item {
                width: 1
                height: Theme.paddingMedium
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
