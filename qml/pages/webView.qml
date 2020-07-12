import QtQuick 2.2
import Sailfish.Silica 1.0

 Page {
    property string pageurl
    allowedOrientations: Orientation.All
     SilicaWebView {
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

