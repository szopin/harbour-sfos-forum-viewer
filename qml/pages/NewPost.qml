import QtQuick 2.6
import Sailfish.Silica 1.0
import Nemo.Configuration 1.0
import Sailfish.Pickers 1.0

Dialog {
    id: dialog

    allowedOrientations: Orientation.All

    property string topicid
    property string post_number
    property string username
    property string postid
    property string raw
    property string cooked
    property string loggedin

    property bool haveDraft: false
    readonly property string _draftKey: "drafts/v1/" // version in case we change something and must migrate
                             // a litte obfuscation
                             + Qt.md5( "draft" + postid + username + topicid)

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
    function findFirstPage() {
        return pageStack.find(function(page) { return page.hasOwnProperty('loadmore'); });
    }

    function getraw(postid, quote){
        var xhr = new XMLHttpRequest;
        xhr.open("GET", "https://forum.sailfishos.org/posts/" + postid + ".json");
        xhr.setRequestHeader("User-Api-Key", loggedin);
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE){   var data = JSON.parse(xhr.responseText);
                cooked = data["cooked"];
                if (quote) {
                    var oldraw = postbody.text;
                    var curpos = postbody.cursorPosition;
                    var oldlen = oldraw.length
                    raw = data["raw"];
                    if(username){
                        postbody.text = "[quote=\"" + username +", post:" + post_number + ", topic:" + topicid +"\"]\n" + raw + "\n[/quote]\n" + oldraw;
                        postbody.cursorPosition = postbody.text.length - oldlen + curpos
                    } else {
                        postbody.text = raw;
                    }
                }
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
        mainConfig.setValue(_draftKey, undefined)
        mainConfig.sync()
    }

    ConfigurationGroup {
        id: mainConfig
        path: "/apps/harbour-sfos-forum-viewer"
    }

    SilicaFlickable{
        id: flick
        anchors.fill: parent

        PullDownMenu{
            MenuItem{
                text: qsTr("Cancel and discard draft")
                enabled: haveDraft
                onClicked: {
                    var confirm = pageStack.push(confirmDlg, { "acceptDestination": pageStack.previousPage(), "key": _draftKey } )
                }
            }
            MenuItem{
                text: qsTr("Upload image (through ImgBB)")
                onClicked: pageStack.push(filePickerPage)
            }
            MenuItem{
                visible: postid && username
                text: qsTr("Show parent")
                onClicked: {
                     if(!cooked) getraw(postid, false)
                     panel.open = !panel.open
                }
            }
            MenuItem{
                visible: postid && username
                text: qsTr("Insert quote")
                onClicked: getraw(postid, true)
            }
        }

        PageHeader {
            id: pageHeader
            title: username ? qsTr("Enter reply") : !postid ? qsTr("Enter post") : qsTr("Edit post");
            description: username ? qsTr("Replying to %1").arg(username) : ""
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
            label: haveDraft ? qsTr("Draft saved. (%1)").arg( new Date().toLocaleTimeString(Qt.locale(), Locale.NarrowFormat )) : ""
            onTextChanged: if (text.length > 20 ) draftTimer.start()
            onFocusChanged: if (!focus && (text.length > 20)) draftTimer.start()
            Timer { id: draftTimer
                interval: 1000*13
                onTriggered: {
                    mainConfig.setValue(_draftKey, Qt.btoa(postbody.text) );
                    if (mainConfig.value(_draftKey, "") !== "") {
                        dialog.haveDraft = true
                    }
                }
            }

        }
    }

    DockedPanel { id: panel
        width: parent.width
        // add the height of the header:
        height: Math.min(op.height + (dialog.isLandscape ? Theme.itemSizeSmall : Theme.itemSizeLarge), dialog.height - Theme.itemSizeLarge)
        contentHeight: op.height

        dock: Dock.Top
        modal: true
        focus: open

        background: Component {
            PanelBackground { palette.highlightBackgroundColor: "black" } // used in bg gradient
        }

        Column { id: op
            anchors {
                //bottom: parent.bottom
                left: parent.left
                right: parent.right
                topMargin: (dialog.isLandscape ? Theme.itemSizeSmall : Theme.itemSizeLarge)
            }
            bottomPadding: Theme.paddingLarge
            spacing: Theme.paddingSmall

            SectionHeader { text: username; font.pixelSize: Theme.fontSizeMedium }
            Label {
                anchors {
                    margins: Theme.paddingLarge
                    left: parent.left
                    right: parent.right
                }
                text: cooked
                textFormat: Text.RichText
                wrapMode: Text.Wrap
                font.pixelSize: Theme.fontSizeSmall
            }
            Item { height: Theme.paddingLarge; width: parent.width; visible: !raw }
            ButtonLayout {
                Button {
                    text: qsTr("Insert quote")
                    visible: !raw
                    onClicked: { getraw(postid, true); panel.hide() }
                }
            }
        }
    }

    Component.onCompleted: {
        // restore draft
        var d = mainConfig.value(_draftKey, "")
        if (d!=="") {
                raw = Qt.atob(d)
                dialog.haveDraft = true
        // get parent post
        } else if(!username && postid){
            getraw(postid, true);
        }
    }

    Component {
        id: confirmDlg
        Dialog {
            allowedOrientations: Orientation.All
            acceptDestinationAction: PageStackAction.Pop
            property string key
            property bool clearAll: false
            onAccepted: {
                config.setValue(key, undefined)
                if(clearAll) drafts.clear()
            }
            ConfigurationGroup {
                id: config
                path: "/apps/harbour-sfos-forum-viewer"
            }
            ConfigurationGroup {
                id: drafts
                path: "/apps/harbour-sfos-forum-viewer/drafts"
            }
            DialogHeader { id: header; title: qsTr("Discard draft?") }
            Column {
                width: parent.width
                anchors.top: header.bottom
                spacing: Theme.paddingLarge
                Label {
                    font.pixelSize: Theme.fontSizeLarge
                    text: qsTr("You have %Ln character(s) saved").arg(config.value(key).length)
                    horizontalAlignment: Text.AlignHCenter
                }
                TextSwitch {
                    checked: clearAll
                    text: qsTr("Delete all drafts")
                    description: qsTr("Delete all other saved drafts as well as this one.")
                    onCheckedChanged: clearAll = !clearAll
                }
            }
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
