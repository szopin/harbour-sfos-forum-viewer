import QtQuick 2.0
import Sailfish.Silica 1.0

// Discourse "device authorization" login: the forum hands out a short user
// code, the user approves it in a regular browser, and the app polls for the
// encrypted User API key. This avoids driving the forum login inside an
// embedded web view.
Page {
    id: page

    allowedOrientations: Orientation.All

    property string pubkey
    property string rand

    readonly property string applicationName: "SFOS-Forum-Viewer"
    readonly property string scopes: "read,write"

    property string deviceCode
    property string userCode
    property string verificationUri
    property string verificationUriWithRequest
    property int pollInterval: 5

    // requesting | waiting | done | error
    property string loginState: "requesting"
    property string errorText
    property bool pollInFlight: false

    function findLoginPage() {
        return pageStack.find(function(p) { return p.hasOwnProperty('plaintext'); });
    }

    function fail(text) {
        pollTimer.stop();
        errorText = text;
        loginState = "error";
    }

    function describeHttpError(xhr) {
        var text = xhr.status + " " + xhr.statusText;
        try {
            var data = JSON.parse(xhr.responseText);
            if (data.errors && data.errors.length) text += "\n" + data.errors.join("\n");
        } catch (e) {
        }
        return text;
    }

    function requestCode() {
        pollTimer.stop();
        deviceCode = "";
        userCode = "";
        errorText = "";
        loginState = "requesting";

        var xhr = new XMLHttpRequest;
        xhr.open("POST", application.source + "user-api-key/device.json");
        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.setRequestHeader("Accept", "application/json");
        xhr.onreadystatechange = function() {
            if (xhr.readyState !== XMLHttpRequest.DONE) return;
            if (xhr.status === 404) {
                fail(qsTr("The forum does not support device login."));
                return;
            }
            if (xhr.status !== 200) {
                fail(describeHttpError(xhr));
                return;
            }
            var data = JSON.parse(xhr.responseText);
            deviceCode = data.device_code;
            userCode = data.user_code;
            verificationUri = data.verification_uri;
            verificationUriWithRequest = data.verification_uri_with_request || data.verification_uri;
            if (data.interval) pollInterval = data.interval;
            loginState = "waiting";
            pollTimer.restart();
        }
        xhr.send(JSON.stringify({
            "nonce": "12345678",
            "scopes": scopes,
            "client_id": rand,
            "application_name": applicationName,
            "public_key": pubkey
        }));
    }

    function poll() {
        if (loginState !== "waiting" || pollInFlight || deviceCode === "") return;
        pollInFlight = true;
        var code = deviceCode;

        var xhr = new XMLHttpRequest;
        xhr.open("POST", application.source + "user-api-key/device/poll.json");
        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.setRequestHeader("Accept", "application/json");
        xhr.onreadystatechange = function() {
            if (xhr.readyState !== XMLHttpRequest.DONE) return;
            pollInFlight = false;
            if (loginState !== "waiting" || code !== deviceCode) return;

            // Transient failures (rate limiting, flaky network): try again on the next tick.
            if (xhr.status === 0 || xhr.status === 429 || xhr.status >= 500) return;
            if (xhr.status !== 200) {
                fail(describeHttpError(xhr));
                return;
            }

            var data = JSON.parse(xhr.responseText);
            if (data.status === "authorized" && data.payload) {
                pollTimer.stop();
                loginState = "done";
                findLoginPage().dec(data.payload);
                pageStack.pop();
            } else if (data.status === "access_denied") {
                fail(qsTr("The login request was denied."));
            } else if (data.status === "expired_token") {
                fail(qsTr("The code has expired."));
            }
            // "authorization_pending": keep polling
        }
        xhr.send(JSON.stringify({ "device_code": code }));
    }

    function openBrowser() {
        Clipboard.text = userCode;
        Qt.openUrlExternally(verificationUriWithRequest);
    }

    Component.onCompleted: requestCode()

    Timer {
        id: pollTimer
        interval: pollInterval * 1000
        repeat: true
        onTriggered: poll()
    }

    // Check right away when the user switches back from the browser.
    Connections {
        target: Qt.application
        onStateChanged: if (Qt.application.state === Qt.ApplicationActive) poll()
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height + Theme.paddingLarge

        PullDownMenu {
            visible: loginState === "waiting"
            MenuItem {
                text: qsTr("Copy link")
                onClicked: Clipboard.text = verificationUriWithRequest
            }
            MenuItem {
                text: qsTr("Request a new code")
                onClicked: requestCode()
            }
        }

        Column {
            id: column
            width: parent.width
            spacing: Theme.paddingLarge

            PageHeader {
                title: qsTr("Login")
            }

            BusyIndicator {
                anchors.horizontalCenter: parent.horizontalCenter
                size: BusySize.Large
                running: loginState === "requesting" || loginState === "done"
                visible: running
            }

            Label {
                visible: loginState === "waiting"
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * Theme.horizontalPageMargin
                wrapMode: Text.Wrap
                color: Theme.highlightColor
                text: qsTr("Open the forum in a browser, log in and enter this code to authorize the app:")
            }

            Label {
                visible: loginState === "waiting"
                anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: Theme.fontSizeHuge
                font.family: "monospace"
                font.bold: true
                color: Theme.highlightColor
                text: userCode
            }

            Button {
                visible: loginState === "waiting"
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Copy code and open browser")
                onClicked: openBrowser()
            }

            Label {
                visible: loginState === "waiting"
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * Theme.horizontalPageMargin
                wrapMode: Text.Wrap
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.secondaryColor
                text: qsTr("You can also approve the login on another device at %1").arg(verificationUri)
            }

            Row {
                visible: loginState === "waiting"
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: Theme.paddingMedium

                BusyIndicator {
                    size: BusySize.ExtraSmall
                    running: loginState === "waiting"
                    anchors.verticalCenter: parent.verticalCenter
                }
                Label {
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.secondaryHighlightColor
                    text: qsTr("Waiting for authorization…")
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Label {
                visible: loginState === "error"
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * Theme.horizontalPageMargin
                wrapMode: Text.Wrap
                color: Theme.highlightColor
                text: errorText
            }

            Button {
                visible: loginState === "error"
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Try again")
                onClicked: requestCode()
            }
        }
    }
}
