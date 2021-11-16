import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.LocalStorage 2.0
import QtWebKit 3.0
import QtWebKit.experimental 1.0


Dialog {id: loginDialog

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
        payload = payload.substring(6, payload.length - 8)
        findFirstPage().dec(payload);
        close()

    }

    SilicaWebView {
        id: webview
        anchors.fill: parent
                smooth: true

        url: auth_url
        experimental.preferences.navigatorQtObjectEnabled: true;
        anchors {
           top: parent.top
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        onLoadingChanged: {

                if (status===WebView.LoadSucceededStatus){
                experimental.evaluateJavaScript("navigator.qt.postMessage(document.getElementsByTagName('code')[0].outerHTML)");

            if (url.toString().indexOf(redirect_uri) == 0) {

                        url= "https://forum.sailfishos.org/auth/oauth2_basic"

            }
                }
        }
            experimental.onMessageReceived: {
                payload = message.data
                    console.log(message.data)
                getAuthorizationCode(payload)

            }
    }
}


