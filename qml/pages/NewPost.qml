import QtQuick 2.0
import Sailfish.Silica 1.0
import Nemo.Configuration 1.0
import Sailfish.Pickers 1.0

Dialog {
    id: dialog

    property string topicid
    property string post_number
    property string username
    property string postid
    property string raw
    property string loggedin

    function gen_multipart(image) {

    var multi =  ['--END_OF_PART\nContent-Disposition: form-data; name="expiration"\n\n1200\n','--END_OF_PART\nContent-Disposition: form-data; name="key"\n\nAPI-KEY-HERE\n','--END_OF_PART\nContent-Disposition: form-data; name="image"\n\n', image, '\n--END_OF_PART--' ].join('');
        return multi;
    }

    function upload(b64) {

        var request = gen_multipart(b64);
        var xhr = new XMLHttpRequest;
            xhr.open("POST", "https://api.imgbb.com/1/upload");

            xhr.setRequestHeader("Content-Type", "multipart/form-data; boundary=END_OF_PART");
            xhr.onreadystatechange = function() {
                if (xhr.readyState === XMLHttpRequest.DONE){
                    if(xhr.statusText !== "OK"){
                        pageStack.completeAnimation();
                        pageStack.push("Error.qml", {errortitle: xhr.status + " " + xhr.statusText, errortext: xhr.responseText});
                    } else {
                    var data = JSON.parse(xhr.responseText);
                    mainConfig.setValue("uploads/" + data.data.title,data.data.delete_url);
                        postbody.text = postbody.text + "![](" + data.data.url + ")\n";
                    }
                }
            }
        xhr.send(request);
    }

    function getfile(filepath){
            var xhr = new XMLHttpRequest;
            xhr.open("GET", "file://" + filepath);
             xhr.responseType = 'arraybuffer';
            xhr.onreadystatechange = function() {
                if (xhr.readyState === XMLHttpRequest.DONE){
                    var response = new Uint8Array(xhr.response);
                        var raw = "";
                        for (var i = 0; i < response.byteLength; i++) {
                            raw += String.fromCharCode(response[i]);
                        }

                        function base64Encode (input) {
                            var chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=';
                            var str = String(input);
                            for (
                                var block, charCode, idx = 0, map = chars, output = '';
                                str.charAt(idx | 0) || (map = '=', idx % 1);
                                output += map.charAt(63 & block >> 8 - idx % 1 * 8)
                                ) {
                                charCode = str.charCodeAt(idx += 3/4);
                                if (charCode > 0xFF) {
                                    throw new Error("Base64 encoding failed: The string to be encoded contains characters outside of the Latin1 range.");
                                }
                                block = block << 8 | charCode;
                            }
                            return output;
                        }
                    upload(base64Encode(raw));
                }
            }
            xhr.send();
    }

            ConfigurationGroup {
            id: mainConfig
            path: "/apps/harbour-sfos-forum-viewer"
        }
    function findFirstPage() {
        return pageStack.find(function(page) { return page.hasOwnProperty('loadmore'); });
    }

    function getraw(postid){
        var xhr = new XMLHttpRequest;
        xhr.open("GET", "https://forum.sailfishos.org/posts/" + postid + ".json");
        xhr.setRequestHeader("User-Api-Key", loggedin);
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE){   var data = JSON.parse(xhr.responseText);
                raw = data["raw"];
                if(username){
                    postbody.text = "[quote=\"" + username +", post:" + post_number + ", topic:" + topicid +"\"]\n" + raw + "\n[/quote]\n";
                } else {
                    postbody.text = raw;
                }
                return raw;
            }
        }
        xhr.send();
    }
    canAccept: postbody.text.length >19

    onAccepted: {
        if(username){
            findFirstPage().replytopost(postbody.text, topicid, post_number);
        } else if (!postid){
            findFirstPage().reply(postbody.text, topicid);
        } else {
            findFirstPage().edit(postbody.text, postid);
        }
    }
    SilicaFlickable{
        id: flick
        anchors.fill: parent

        PullDownMenu{

            MenuItem{
                text: qsTr("Upload image (through ImgBB)")
                onClicked: pageStack.push(filePickerPage)
            }
            MenuItem{
                visible: postid && username
                text: qsTr("Insert quote")
                onClicked: getraw(postid)
            }
        }

        PageHeader {
            id: pageHeader
            title: username ? qsTr("Enter post") : !postid ? qsTr("Enter post") : qsTr("Edit post");
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
    Component.onCompleted: {
        if(!username && postid){
            getraw(postid);
        }
    }

    Component {
        id: filePickerPage
        ImagePickerPage {
            onSelectedContentPropertiesChanged: {
                var filepath = selectedContentProperties.filePath
                getfile(filepath);
            }
        }
    }
}
