import QtQuick 2.2
import Sailfish.Silica 1.0


 Page {
    id: firstPage
        allowedOrientations: Orientation.All
        property string source: "https://forum.sailfishos.org/"
        property string tid
        property int pageno: 0
        property string viewmode : "latest"
        property string textname
        property string pagetitle:  textname == "" ? "SFOS Forum - " + viewmode : "SFOS Forum - " + textname
        property string combined: tid == "" ? source + viewmode + ".json?page=" + pageno : source + "c/" + tid + ".json?page=" + pageno


        function updateview(){
            var xhr = new XMLHttpRequest;
            xhr.open("GET", combined);
            xhr.onreadystatechange = function() {
                if (xhr.readyState === XMLHttpRequest.DONE) {
                    var data = JSON.parse(xhr.responseText);
                    //list.model.clear();


                    if (viewmode === "latest" && tid === ""){

                    for (var i=0;i<data.topic_list.topics.length;i++) {
                        if ("bumped" in data.topic_list.topics[i] && data.topic_list.topics[i]["bumped"] === true){
                        list.model.append({title: data.topic_list.topics[i]["title"], topicid: data.topic_list.topics[i]["id"], posts_count: data.topic_list.topics[i]["posts_count"]});
                    }
                    }

                } else {
                        for (var j=0;j<data.topic_list.topics.length;j++) {

                            list.model.append({title: data.topic_list.topics[j]["title"], topicid: data.topic_list.topics[j]["id"], posts_count: data.topic_list.topics[j]["posts_count"]});
                        }

                        }
                    var more = 'more_topics_url';
                    if (data.topic_list[more]){
                        pageno++;

                    } else {
                        pageno = 0;

                        }


                }
            }

            xhr.send();

        }

    SilicaListView {
        id:list
        anchors.fill: parent

        header: PageHeader {
            id: header
            title: pagetitle
        }

        PullDownMenu {
            MenuItem {
                text: "About"
                onClicked: pageStack.push("About.qml");
            }
            MenuItem {
                text: "Reload"
                onClicked: {
                    pageno = 0;
                    list.model.clear()
                    firstPage.updateview()
                }
            }
            MenuItem {
                text: "Latest"
                visible: viewmode == "top" || tid !== ""
                onClicked: {
                    list.model.clear()
                    pageno = 0;
                    tid =""
                    textname = ""
                    viewmode = "latest"
                    firstPage.updateview()
                }
            }
            MenuItem {
                text: "Top"
                visible: viewmode == "latest" || tid !== ""
                onClicked: {
                    viewmode = "top"
                    pageno = 0;
                    tid =""
                    textname = ""
                    list.model.clear()
                    firstPage.updateview()
                }
            }

            MenuItem {
                text: "Browse by category"
                onClicked: pageStack.push("CategorySelect.qml");

            }
        }

        ViewPlaceholder {
            id: vplaceholder
            enabled: model.count == 0
            text: "Loading..."

        }

        model: ListModel { id: model}
        VerticalScrollDecorator {}
        Component.onCompleted: firstPage.updateview();


          delegate: BackgroundItem {

            width: parent.width

            height:  Theme.paddingLarge + theTitle.contentHeight

            Label {
                id:  theTitle
                text: title + " (posts: " + posts_count + ")"

                wrapMode: Text.Wrap
                font.pixelSize: Theme.fontSizeSmall
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: Theme.paddingSmall
                    verticalCenter: parent.verticalCenter
                    }
                }

            onClicked: {
                var name = list.model.get(index).name
                pageStack.push("ThreadView.qml", {"aTitle": title, "topicid": topicid, "posts_count": posts_count});
            }
        }
          PushUpMenu{
              visible: pageno != 0;
              MenuItem {

                  text: "Load more"
                  onClicked: {

                      firstPage.updateview();
                  }
              }

          }
    }
}
