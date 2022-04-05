import QtQuick 2.2
import Sailfish.Silica 1.0
import Nemo.Configuration 1.0

Page {
    id: notificationsPage
    allowedOrientations: Orientation.All
    property var notif
    property string loggedin
    property string fancy_title
    property string combined: application.source + "site.json" // x-discourse-username
    property string combined2: application.source + "notifications.json"
    property bool networkError: false
    property bool loadedMore: false

    function updateView() {
        var xhr = new XMLHttpRequest;
        xhr.open("GET", combined);
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.responseText === "") {
                    list.model.clear();
                    networkError = true;
                    return;
                } else {
                    networkError = false;
                }

                var data = JSON.parse(xhr.responseText);
                notif = data.notification_types;
            }
        }
        xhr.send();
        getnotifications();
    }
    function getnotifications(){
        var xhr2 = new XMLHttpRequest;

        xhr2.open("GET", combined2);
        xhr2.setRequestHeader("User-Api-Key", loggedin);
        xhr2.onreadystatechange = function() {
            if (xhr2.readyState === XMLHttpRequest.DONE){
                if(xhr2.statusText !== "OK"){
                    pageStack.completeAnimation();
                    pageStack.push("Error.qml", {errortext: xhr2.responseText});
                } else {
                    var data2 = JSON.parse(xhr2.responseText);
                    var notifications = data2.notifications;
                    var notlen = notifications.length;
                    for (var i=0;i<notlen;i++) {
                        var notific = notifications[i];
                        fancy_title = notific.data.topic_title
                        var orig_name = notific.data.original_username
                        var disp_name = notific.data.display_username
                        list.model.append({ type: notific.notification_type,
                                              read: notific.read, bumped: notific.created_at, post_number: notific.post_number, topic_id: notific.topic_id, fancy_title: fancy_title, username: orig_name ? orig_name : disp_name});
                    }
                    console.log("ok");//xhr2.responseText);
                }
            }
        }
        xhr2.send();
    }

    SilicaListView {
        id:list
        anchors.fill: parent
        header: PageHeader {
            id: header
            title: qsTr("Notifications")
            description: qsTr("SailfishOS Forum")
        }

        footer: Item {
            width: parent.width
            height: Theme.horizontalPageMargin
        }

        BusyIndicator {
            visible: running
            running: model.count === 0 && !networkError
            anchors.centerIn: parent
            size: BusyIndicatorSize.Large
        }

        ViewPlaceholder {
            enabled: model.count === 0 && networkError
            text: qsTr("Nothing to show")
            hintText: qsTr("Is the network enabled?")
        }

        model: ListModel { id: model}
        VerticalScrollDecorator {}
        Component.onCompleted: {
            updateView();
        }

        delegate: BackgroundItem {
            id: item
            width: parent.width
            height: delegateCol.height + Theme.paddingLarge

            Column {
                id: delegateCol
                height: childrenRect.height
                width: parent.width - 2*Theme.horizontalPageMargin
                spacing: Theme.paddingSmall
                anchors {
                    verticalCenter: parent.verticalCenter
                    horizontalCenter: parent.horizontalCenter
                }

                Row {
                    width: parent.width
                    spacing: 1.5*Theme.paddingMedium

                    Column {
                        width: parent.width - parent.spacing

                        Label {
                            text: username + " - " + Object.keys(notif)[type - 1] + " - " + fancy_title
                            width: parent.width
                            wrapMode: Text.Wrap
                            font.pixelSize: Theme.fontSizeSmall
                            color: read ? Theme.primaryColor : Theme.highlightColor
                        }

                        Row {
                            width: parent.width
                            spacing: Theme.paddingMedium

                            Label {
                                id: dateLabel
                                text: formatJsonDate(bumped)
                                wrapMode: Text.Wrap
                                elide: Text.ElideRight
                                color: read ? Theme.primaryColor : Theme.highlightColor
                                font.pixelSize: Theme.fontSizeSmall
                                horizontalAlignment: Text.AlignLeft
                            }

                        }
                    }
                }
            }

            onClicked: {

                if(topic_id){
                    pageStack.push("ThreadView.qml", {
                                       "topicid": topic_id,
                                       "post_number": post_number
                                   });
                }
            }
        }
    }
}
