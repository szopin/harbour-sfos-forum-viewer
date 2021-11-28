import QtQuick 2.0
import Sailfish.Silica 1.0

Dialog {
    id: dialog

    property string topicid
    property string post_number
    property string username
    property string postid
    property string raw

    function findFirstPage() {
        return pageStack.find(function(page) { return page.hasOwnProperty('loadmore'); });
    }

            function getraw(postid){
        var xhr = new XMLHttpRequest;
        xhr.open("GET", "https://forum.sailfishos.org/posts/" + postid + ".json");
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE){   var data = JSON.parse(xhr.responseText);
            raw = data["raw"];
                postbody.text = "[quote=\"" + username +", post:" + post_number + ", topic:" + topicid +"\"]\n" + raw + "\n[/quote]\n";
                return raw;
            }
        }
        xhr.send();
    }
    canAccept: postbody.text.length >19

        onAccepted: {
        if(username){
        findFirstPage().replytopost(postbody.text, topicid, post_number);
    } else {
        findFirstPage().reply(postbody.text, topicid);
    }
    }
                SilicaFlickable{
        id: flick
        anchors.fill: parent
                PageHeader {
                    id: pageHeader
                    title: qsTr("Enter post");
                }
                TextArea {
                    id: postbody
                    text: raw
        anchors.top: pageHeader.bottom
        width: parent.width

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        softwareInputPanelEnabled: true
                 placeholderText: qsTr("Body");


                    }

    }
Component.onCompleted: getraw(postid);
    }
