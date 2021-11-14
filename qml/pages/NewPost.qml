import QtQuick 2.0
import Sailfish.Silica 1.0


Dialog {
    id: dialog
    property string topicid

    function findFirstPage() {
        return pageStack.find(function(page) { return page.hasOwnProperty('loadmore'); });
    }
    canAccept: postbody.text.length >19

        onAccepted: {
              findFirstPage().reply(postbody.text, topicid);
    }


                PageHeader {
                    id: pageHeader
                    title: qsTr("Enter post");
                }
                TextArea {
                    id: postbody
                    anchors.fill: parent// { left: parent.left; right: parent.right }

                    }



    }
