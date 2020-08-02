import QtQuick 2.0
import Sailfish.Silica 1.0


Page {
    property string initialSearch
    property int searchid
    property string aTitle
    property string hint: aTitle === "" ? "" : "Searching thread: " + aTitle
    property string searchstring: searchid !== 0 ? "https://forum.sailfishos.org/search.json?context=topic&context_id=" + searchid + "&q=" : "https://forum.sailfishos.org/search.json?q="

    function _reset() {
        list.headerItem.searchField.text = ""
        list.model.clear()

        viewPlaceholder.text = "Type at least 3 letters in the field above"
        viewPlaceholder.hintText = hint

        list.headerItem.searchField.forceActiveFocus()
    }
function getcomments(text){
            var xhr = new XMLHttpRequest;
            xhr.open("GET", searchstring + text);
            xhr.onreadystatechange = function() {
                if (xhr.readyState === XMLHttpRequest.DONE) {
                    var data = JSON.parse(xhr.responseText);
                    list.model.clear();
                 if(data.posts[0] !== undefined){


                for (var i=0;i<data.posts.length;i++) {
                    if(searchid === 0){

                        list.model.append({blurb: data.posts[i]["blurb"], topicid: data.posts[i]["topic_id"], title: data.topics[i]["title"], post_number: data.posts[i]["post_number"], posts_count: data.topics[i]["posts_count"], post_id: data.posts[i]["id"], highest_post_number: data.topics[i]["highest_post_number"]});
                } else {
                        list.model.append({blurb: data.posts[i]["blurb"], topicid: data.posts[i]["topic_id"], title: data.topics[0]["title"], post_number: data.posts[i]["post_number"], posts_count: data.topics[0]["posts_count"], post_id: data.posts[i]["id"], highest_post_number: data.topics[0]["highest_post_number"]});
                    }
                }
                } else {
                            viewPlaceholder.text = "No results"

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
            height:  Theme.paddingLarge + theTitle.contentHeight
        Label {
                id:  theTitle
                text: "<b>" + title + "</b><br></br>" + blurb

                wrapMode: Text.Wrap
                font.pixelSize: Theme.fontSizeSmall
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: Theme.paddingMedium
                    verticalCenter: parent.verticalCenter
                    }
        }
            onClicked: {

                var name = list.model.get(index).name
                if(viewPlaceholder.text !== "No results"){
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

                placeholderText: "Search"

                EnterKey.enabled: text.length > 2
                EnterKey.iconSource: "image://theme/icon-m-enter-accept"
                EnterKey.onClicked: _search(text)

                onTextChanged: if (!text) _reset()
            }
        }



        VerticalScrollDecorator { }

        ViewPlaceholder {
            id: viewPlaceholder
            enabled: text
        }




        BusyIndicator {
            id: busyIndicator
            size: BusyIndicatorSize.Large
            anchors.centerIn: parent
            running: parent.count === 0 && !viewPlaceholder.enabled
        }
    }
}
