import QtQuick 2.2
import QtGraphicalEffects 1.0
import Sailfish.Silica 1.0
import Nemo.Configuration 1.0


Page {
    id: replypage
    allowedOrientations: Orientation.All
    property var commodel
    property string loggedin
    property string raw
    property string topicid
    property string url
    property string aTitle
    property var reply_to
    property int last_post: 0
    property int posts_count
    property bool tclosed
    property string stafftag: ""
    property string tags
    property string avatar
    property bool acted
    property bool can_act
    property bool can_undo
    property bool accepted_answer
    property bool busy: true
    property int xi
    property int yi
    property int zi
    property variant currentModel: commodel
    property int replyindex
    property bool spam: false


    function getRedirect(link){
        var xhr = new XMLHttpRequest;
        xhr.open("GET", link);
        if (loggedin.value != "-1") xhr.setRequestHeader("User-Api-Key", loggedin.value);
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                var xhrlocation = xhr.getResponseHeader("location");
                var testa =  /^https:\/\/forum.sailfishos.org\/t\/[\w-]+\/(\d+)\/?(\d+)?$/.exec(xhrlocation);
                pageStack.push("ThreadView.qml", { "topicid":  testa[1]});
            }
        }
        xhr.send();
    }


    ConfigurationGroup {
        id: filterlist
        path: "/apps/harbour-sfos-forum-viewer/filterlist"
    }


    ConfigurationValue {
        id: loggedin
        key: "/apps/harbour-sfos-forum-viewer/key"
    }


    SilicaListView {
        id: list
        header: PageHeader {
            id: pageHeader
            title: tclosed ? "🔐" + aTitle : aTitle
            description: tags ? qsTr("tags") + ": " + tags : ""
            wrapMode: Text.Wrap
        }
        footer: Item {
            width: parent.width
            height: Theme.horizontalPageMargin
        }
        width: parent.width
        height: parent.height
        anchors.top: header.bottom
        VerticalScrollDecorator {}
        PullDownMenu{
            id: pdmenu

            MenuItem {
                text: qsTr("Back to full thread")

                onClicked:{
                    pageStack.pop()
                }
            }
        }
        PushUpMenu{
            id: pumenu

            MenuItem {
                text: qsTr("Back to full thread")

                onClicked: {
                    pumenu.close()
                    pageStack.pop()
                }
            }

        }



        model: commodel // ListModel { id: commodel}
        delegate: ListItem {
            id: delegateItem
            property int postindex: index

            width: parent.width
            visible: !spam
            contentHeight: !spam ? delegateCol.height + Theme.paddingLarge : 0
            anchors.horizontalCenter: parent.horizontalCenter

            Column {
                id: delegateCol
                width: parent.width - 2*Theme.horizontalPageMargin
                height: childrenRect.height
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    verticalCenter: parent.verticalCenter
                }
                spacing: Theme.paddingMedium

                Separator {
                    color: Theme.highlightColor
                    width: parent.width
                    horizontalAlignment: Qt.AlignHCenter
                }

                Row {
                    width: parent.width
                    spacing: Theme.paddingSmall
                    Column {
                        Image {
                            id: ava
                            height:  3* Theme.paddingLarge
                            width:  3* Theme.paddingLarge
                            source: application.source + avatar.replace("{size}",  3* Theme.paddingLarge)
                            layer.enabled: true
                            layer.effect: OpacityMask {
                                maskSource: Item {
                                    width: ava.width
                                    height: ava.height

                                    Rectangle {
                                        anchors.centerIn: parent
                                        width: Math.min(ava.width, ava.height)
                                        height: ava.height
                                        radius: Math.min(width, height)
                                    }
                                }
                            }
                        }
                    }
                    Column {
                        width: parent.width - subMetadata.width - ava.width
                        Label {
                            id: mainMetadata
                            text: loggedin.value != "-1" ? "<style>" +
                                                           "a { color: %1 }".arg(Theme.highlightColor) +
                                                           "</style>" + "<a href=\"https://forum.sailfishos.org/u/\"" + username + "/card.json\">" + username + stafftag + "</a>" : username + stafftag
                            onLinkActivated: pageStack.push("UserCard.qml", {username: username, loggedin: loggedin.value});
                            textFormat: Text.RichText
                            truncationMode: TruncationMode.Fade
                            elide: Text.ElideRight
                            width: parent.width
                            font.pixelSize: Theme.fontSizeMedium
                        }


                        Label {
                            visible: likes > 0
                            text: !acted ? likes + "♥" : likes + "💘"
                            color: Theme.secondaryColor
                            font.pixelSize: Theme.fontSizeSmall

                        }
                    }

                    Column {
                        id: subMetadata
                        Label {
                            text: formatJsonDate(created_at)
                            color: Theme.secondaryColor
                            font.pixelSize: Theme.fontSizeSmall
                            anchors.right: parent.right
                        }
                        Label {
                            text: (version > 1 && updated_at !== created_at) ?
                                      qsTr("✍️: %1").arg(formatJsonDate(updated_at)) : ""
                            color: Theme.secondaryColor
                            font.pixelSize: Theme.fontSizeSmall
                            anchors.right: parent.right
                        }
                        Label {
                            text: reply_to >0 && reply_to !== last_postid ?  "💬"  : ""
                            color: Theme.secondaryColor
                            font.pixelSize: Theme.fontSizeSmall
                            anchors.right: parent.right
                        }
                        Icon {
                            visible: accepted_answer
                            source: "image://theme/icon-s-accept"
                            width: Theme.iconSizeSmall
                            height: width
                            anchors.right: parent.right
                            opacity: Theme.opacityLow
                        }
                    }
                }
                Label { id: pollHeaderTop
                    visible: has_polls && (delegateItem.height > list.height)
                    width: parent.width - x
                    x: 3* Theme.paddingLarge + Theme.paddingSmall // align to  width
                    text: (has_polls > 1 )
                          ? qsTr("This post contains polls.")
                          : qsTr("This post contains a poll.")
                            + " " + qsTr("See the bottom of the post to participate.")
                    wrapMode: Text.Wrap
                    font.pixelSize: Theme.fontSizeTiny
                    color: Theme.highlightColor
                }

                Label {
                    text: "<style>" +
                          "a { color: %1 }".arg(Theme.highlightColor) +
                          "</style>" +
                          "<p>" + cooked + "</p>"
                    width: parent.width
                    baseUrl: application.source
                    textFormat: Text.RichText
                    wrapMode: Text.Wrap
                    font.pixelSize: Theme.fontSizeSmall
                    onLinkActivated:{
                        var link1= /^https:\/\/forum.sailfishos.org\/t\/([\w-]*[a-z-]+[\w-]+\/)?(\d+)\/?(\d+)*/.exec(link)
                        if (!link1 && /^https:\/\/forum.sailfishos.org\/t\/[\w-]+?\/?/.exec(link)){
                            getRedirect(link);
                        } else if ( !link1){
                            if (link.indexOf("/") === 0){
                                if (link.indexOf("/t/") === 0){
                                    link = "https://forum.sailfishos.org" + link
                                    var link2= /^https:\/\/forum.sailfishos.org\/t\/([\w-]*[a-z-]+[\w-]+\/)?(\d+)\/?(\d+)*/.exec(link)
                                    var post_number2 = link2[3] ? link2[3] : -1
                                    pageStack.push("ThreadView.qml", { "topicid": link2[2], "post_number": post_number2 });
                                }

                                link = "https://forum.sailfishos.org" + link
                            }
                            pageStack.push("OpenLink.qml", {link: link});

                        }  else {
                            var post_number = link1[3] ? link1[3] : -1
                            pageStack.push("ThreadView.qml", { "topicid": link1[2], "post_number": post_number });
                        }
                    }
                }
                Flow { id: pollsItem
                    visible: has_polls
                    property int cols: 3
                    width: parent.width
                    Label { id: pollHeader
                        width: parent.width
                        text: (has_polls > 1 )
                              ? qsTr("This post contains polls.")
                              : qsTr("This post contains a poll.")
                                + " " + qsTr("Click to view and vote:")
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.highlightColor
                    }
                    Repeater {
                        model: has_polls
                        delegate: ValueButton { id: pollButt
                            property int pollindex: index
                            onClicked: {
                                const pd = polldata.get(pollindex)
                                //console.debug("Opening poll no", pollindex, "for post", postid, ", data:", JSON.stringify(pd,null,2))
                                pageStack.push("PollView.qml",
                                               { "key": loggedin.value, "postid": postid,
                                                   "polldata": pd["poll"],
                                                   "submitted_votes": pd["votes"]["list"]
                                               }
                                               );
                            }
                            label: qsTr("Poll")
                            value: '#' + Number(pollindex + 1)
                            width: Math.floor(pollsItem.width/pollsItem.cols)
                        }
                    }
                }
            }
        }

        Component.onCompleted: list.positionViewAtEnd()

    }
}
