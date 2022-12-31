import QtQuick 2.2
import Sailfish.Silica 1.0

Page {
    id: page
    allowedOrientations: Orientation.All
    property string username
    property string loggedin
    property string uname
    property string avatar
    property string bio_excerpt
    property string clocation
    property string website
    property string website_name
    property string ctitle
    property string card_bg
    property bool profile_hidden
    property bool can_pm

    SilicaFlickable {
        anchors.fill: parent
        PageHeader {
            id: header;
            width: parent.width -header.height - Theme.paddingMedium
            title: username

            description: uname
        }

        Image {
            id: pic
            anchors.top: header.top
            anchors.left: header.right
            anchors.topMargin: Theme.paddingMedium
            anchors.rightMargin: Theme.paddingMedium
            source: application.source + avatar

        }

        Label {
            id: bio
            visible: bio_excerpt !== ""
            height: bio_excerpt !== ""  ? contentHeight : 0
            anchors.margins: Theme.paddingMedium
            anchors.top: header.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: Theme.horizontalPageMargin
            anchors.rightMargin: Theme.horizontalPageMargin
            width: parent.width
            textFormat: Text.RichText
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.primaryColor
            wrapMode: Text.WordWrap
            text: "       <style>" +
                  "a { color: %1 }".arg(Theme.highlightColor) +
                  "</style>" + bio_excerpt
            onLinkActivated: pageStack.push("OpenLink.qml", {link: link});
        }
        Label {
            id: ctit
            visible: ctitle
            height: ctitle !== "" && ctitle !== null ? contentHeight : 0
            anchors.margins: Theme.paddingMedium
            anchors.top: bio.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: Theme.horizontalPageMargin
            anchors.rightMargin: Theme.horizontalPageMargin
            width: parent.width
            textFormat: Text.RichText
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.primaryColor
            wrapMode: Text.WordWrap
            text: ctitle
        }
        Label {
            id: loc
            visible: clocation != ""
            height: clocation != ""? contentHeight : 0
            anchors.margins: Theme.paddingMedium
            anchors.top: ctit.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: Theme.horizontalPageMargin
            anchors.rightMargin: Theme.horizontalPageMargin
            width: parent.width
            textFormat: Text.RichText
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.primaryColor
            wrapMode: Text.WordWrap
            text: "?? " + clocation
        }
        Label {
            id: www
            visible: website != ""
            height: website != "" ? contentHeight : 0
            anchors.margins: Theme.paddingMedium
            anchors.top: loc.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: Theme.horizontalPageMargin
            anchors.rightMargin: Theme.horizontalPageMargin
            width: parent.width
            textFormat: Text.RichText
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.primaryColor
            wrapMode: Text.WordWrap
            text:"<style>" +
                 "a { color: %1 }".arg(Theme.highlightColor) +
                 "</style>" +  "?? <a href=\"" + website + "\">" + website_name + "</a>"
            onLinkActivated: pageStack.push("OpenLink.qml", {link: website});
        }
        Image {
            id: bg
            anchors.fill: parent
            source: application.source + card_bg
            opacity: 0.25
        }


        function getcard(username){
            var xhr = new XMLHttpRequest;
            xhr.open("GET", application.source + "u/" + username + "/card.json");
            xhr.setRequestHeader("User-Api-Key", loggedin);
            xhr.onreadystatechange = function() {
                if (xhr.readyState === XMLHttpRequest.DONE) {
                    //   console.log(xhr.responseText);
                    var data = JSON.parse(xhr.responseText);
                    var d = data.user
                    if (d.profile_hidden) profile_hidden = d.profile_hidden
                    if(d.can_send_private_message_to_user) can_pm = d.can_send_private_message_to_user
                    uname = d.name
                    avatar = d.avatar_template.replace("{size}", header.height)
                    if(d.title != null) ctitle = d.title
                    if(d.bio_excerpt) bio_excerpt = d.bio_excerpt
                    if(d.card_background_upload_url) card_bg = d.card_background_upload_url
                    if(d.website) website = d.website
                    if(d.website_name) website_name = d.website_name
                    if(d.location) clocation = d.location
                    //   console.log(can_pm)
                }
            }
            xhr.send()

        }
        Component.onCompleted: getcard(username)
        PullDownMenu{
            visible: can_pm
            MenuItem {
                //    visible: can_pm
                text: qsTr("PM")

                onClicked: pageStack.push("NewThread.qml", {target_recipients: username});
            }
        }
    }
}
