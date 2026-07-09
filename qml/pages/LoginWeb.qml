import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.LocalStorage 2.0
import Sailfish.WebView 1.0
import Sailfish.WebEngine 1.0

WebViewPage {

    id: loginDialog

    allowedOrientations: Orientation.All

    property var payload
    property string pubkey
    property string encoded: encodeURIComponent(pubkey)
    property string redirect_uri: "https://forum.sailfishos.org/login"
    property string rand

    property string auth_url: "https://forum.sailfishos.org/user-api-key/new?nonce=12345678&scopes=read,write&client_id=" + rand + "&application_name=SFOS-Forum-Viewer&public_key=" + encoded  //"https://forum.sailfishos.org/user-api-key/new?nonce=" + rand + rand2 + "&scopes=read,write&client_id=" + rand2 + rand + rand + rand2 + "&application_name=SFOS-Forum-Viewer" + rand + "&public_key=" + encoded

    property bool showWebview: true

    function findFirstPage() {
        return pageStack.find(function(page) { return page.hasOwnProperty('plaintext'); });
    }

    function getAuthorizationCode(code) {
        if (code.length > 8) {
            payload = code.substring(6, code.length - 8)
            findFirstPage().dec(payload)
            pageStack.pop()
        }
    }
    SilicaFlickable{
        width: parent.width
            height: parent.height //header.height + resultcode.height
            PageHeader {
                id: header
                title: qsTr("Copy the generated API key here")
        }


            TextField {
                id: resultcode
            anchors.top: header.bottom
                width: parent.width
                placeholderText: qsTr("the code you get after clicking Authorize")
        EnterKey.enabled: text.indexOf('=') > 50
                    EnterKey.onClicked: {

                    findFirstPage().dec(resultcode.text)
            pageStack.pop()
            }
    }


            Rectangle{
                anchors.top: resultcode.bottom
            width: parent.width
            height: parent.height - header.height - resultcode.height
        WebView {
            id: webview
                    anchors.fill: parent


            url: auth_url

            property var alreadyloaded: false

            onLoadingChanged: {
                console.log("onLoadingChanged")
                if (alreadyloaded) {
                    console.log("alreadyloaded")
                    runJavaScript("return document.getElementsByTagName('code')[0].outerHTML;", function(result) {getAuthorizationCode(result);});
                }
                if (loaded){
                    console.log("loaded")
                    alreadyloaded = true
                    WebEngineSettings.setPreference("security.csp.enable",
                                                    false,
                                                    WebEngineSettings.BoolPref)
                }
            }
        }
}
}
}


