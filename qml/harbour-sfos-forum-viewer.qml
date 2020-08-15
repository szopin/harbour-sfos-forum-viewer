import QtQuick 2.0
import Sailfish.Silica 1.0
import "pages"

ApplicationWindow
{
    id: application
    initialPage: Component { FirstPage { } }
    cover: Qt.resolvedUrl("cover/CoverPage.qml")
    property bool fetching: false
    property var latest: ListModel{id: latest}
    property string source: "https://forum.sailfishos.org/"
    readonly property string dateTimeFormat: qsTr("d/M/yyyy '('hh':'mm')'", "date format including date and time but no weekday")

    function formatJsonDate(date) {
        return new Date(date).toLocaleString(Qt.locale(), dateTimeFormat);
    }

    function fetchLatestPosts() {
        application.latest.clear()
        fetching = true
        var xhr = new XMLHttpRequest;
        xhr.open("GET", source + "latest.json");
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                var data = JSON.parse(xhr.responseText);


                for (var i=0;i<data.topic_list.topics.length;i++) {
                    if ("bumped" in data.topic_list.topics[i] && data.topic_list.topics[i]["bumped"] === true){
                        if (i <= 10) {
                            application.latest.append({title: data.topic_list.topics[i]["title"], posts_count: data.topic_list.topics[i]["posts_count"]})
                        }
                    }
                }

            }

            fetching = false
        }
        xhr.send();
    }
}
