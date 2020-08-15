import QtQuick 2.0
import Sailfish.Silica 1.0


Page {
    property string initialSearch
    property int searchid
    property string aTitle
    property string searchstring: searchid !== 0 ? "https://forum.sailfishos.org/search.json?context=topic&context_id=" + searchid + "&q=" : "https://forum.sailfishos.org/search.json?q="
    property bool haveResults: false

    function _reset() {
        list.headerItem.searchField.text = ""
        list.model.clear()

        viewPlaceholder.text = ""
        viewPlaceholder.hintText = (aTitle !== "" ? qsTr("Searching in “%1”").arg(aTitle) : "")
        list.headerItem.searchField.forceActiveFocus()
    }
function getcomments(text){
    busyIndicator.running = true;
            var xhr = new XMLHttpRequest;
            xhr.open("GET", searchstring + text);
            xhr.onreadystatechange = function() {
                if (xhr.readyState === XMLHttpRequest.DONE) {
                    busyIndicator.running = false;
                    var data = JSON.parse(xhr.responseText);
                    list.model.clear();
                 if(data.posts[0] !== undefined){


                     haveResults = true;

                for (var i=0;i<data.posts.length;i++) {
                    if(searchid === 0){

                        list.model.append({blurb: data.posts[i]["blurb"], topicid: data.posts[i]["topic_id"], title: data.topics[i]["title"], post_number: data.posts[i]["post_number"], posts_count: data.topics[i]["posts_count"], post_id: data.posts[i]["id"], highest_post_number: data.topics[i]["highest_post_number"]});
                } else {
                        list.model.append({blurb: data.posts[i]["blurb"], topicid: data.posts[i]["topic_id"], title: data.topics[0]["title"], post_number: data.posts[i]["post_number"], posts_count: data.topics[0]["posts_count"], post_id: data.posts[i]["id"], highest_post_number: data.topics[0]["highest_post_number"]});
                    }
                }
                } else {
                     viewPlaceholder.text = qsTr("No results");
                     viewPlaceholder.hintText = (aTitle !== "" ? qsTr("in “%1”").arg(aTitle) : "")
                     haveResults = false;
                 }
            }
            }
            xhr.send();
    }

    function _search(text) {
        list.headerItem.searchField.text  = text
        viewPlaceholder.text = ""
        getcomments(text);
        forceActiveFocus()
    }

    id: page
    allowedOrientations: defaultAllowedOrientations

    onStatusChanged: {
        if (status === PageStatus.Active) {
            if (initialSearch) {
                list.headerItem.searchField.text = initialSearch
                _search(initialSearch)
            } else if (!list.headerItem.searchField.text) {
                _reset()
            }
        }
    }

    SilicaListView
    {
        id: list
        anchors.fill: parent
        model: ListModel { id: model}

        delegate: BackgroundItem {
            width: parent.width
            height: delegateCol.height + Theme.paddingLarge

            Column {
                id: delegateCol
                height: childrenRect.height
                width: parent.width - 2*Theme.horizontalPageMargin
                spacing: Theme.paddingSmall
                anchors {
                    verticalCenter: parent.verticalCenter
                    horizontalCenter: parent.horizontalCenter
                }

                Label {
                    text: title
                    wrapMode: Text.Wrap
                    maximumLineCount: 2
                    elide: Text.ElideRight
                    width: parent.width
                    font.pixelSize: Theme.fontSizeSmall
                }

                Label {
                    text: blurb
                    wrapMode: Text.Wrap
                    elide: Text.ElideRight
                    width: parent.width
                    color: highlighted ? Theme.secondaryHighlightColor
                                       : Theme.secondaryColor
                    font.pixelSize: Theme.fontSizeSmall
                }
            }

            onClicked: {
                var name = list.model.get(index).name
                if(haveResults) {
                    pageStack.push("ThreadView.qml", {"aTitle": title, "topicid": topicid, "post_number": post_number, "posts_count": posts_count, "post_id": post_id, "highest_post_number": highest_post_number});
                }
            }
        }

        header: Column {
            property alias searchField: searchField

            width: parent.width

            PageHeader {

                title: "Search"
            }

            SearchField {
                id: searchField
                width: parent.width

                placeholderText: aTitle === "" ? qsTr("Search in all threads")
                                               : qsTr("Search in the current thread")

                EnterKey.enabled: text.length > 2
                EnterKey.iconSource: "image://theme/icon-m-enter-accept"
                EnterKey.onClicked: _search(text)

                onTextChanged: if (!text) _reset()
            }
        }



        VerticalScrollDecorator { }

        ViewPlaceholder {
            id: viewPlaceholder
            enabled: list.count === 0 && !busyIndicator.running
        }

        BusyIndicator {
            id: busyIndicator
            size: BusyIndicatorSize.Large
            anchors.centerIn: parent
            running: false
        }
    }
}
