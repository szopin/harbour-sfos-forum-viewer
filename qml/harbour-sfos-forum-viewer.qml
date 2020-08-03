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
    property string tid
    property int pageno: 0
    property string viewmode : "latest"
    property string textname
    property string pagetitle:  textname == "" ? "SFOS Forum - " + viewmode : "SFOS Forum - " + textname
    property string combined: tid == "" ? source + viewmode + ".json?page=" + pageno : source + "c/" + tid + ".json?page=" + pageno

    function fetchLatestPosts() {
        application.latest.clear()
        fetching = true
        var xhr = new XMLHttpRequest;
        xhr.open("GET", combined);
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                var data = JSON.parse(xhr.responseText);

                if (viewmode === "latest" && tid === ""){

                for (var i=0;i<data.topic_list.topics.length;i++) {
                    if ("bumped" in data.topic_list.topics[i] && data.topic_list.topics[i]["bumped"] === true){
                        if (i <= 4) {
                            application.latest.append({title: data.topic_list.topics[i]["title"]})
                        }
                    }
                }

            } else {
                    for (var j=0;j<data.topic_list.topics.length;j++) {
                        if (j < 4) {
                            application.latest.append({title: data.topic_list.topics[j]["title"]})
                        }
                    }

            }
                var more = 'more_topics_url';
                if (data.topic_list[more]){
                    pageno++;
                } else {
                    pageno = 0;
                }
            }

            fetching = false
        }
        xhr.send();
    }
}
