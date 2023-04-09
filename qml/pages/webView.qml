import QtQuick 2.2
import Sailfish.Silica 1.0
import Sailfish.WebView 1.0
import Sailfish.WebEngine 1.0

 WebViewPage {
    property string pageurl
    allowedOrientations: Orientation.All
     WebView {
         id: webView

         anchors {
             top: parent.top
             left: parent.left
             right: parent.right
             bottom: parent.bottom
         }
         url: pageurl
     }

 }

