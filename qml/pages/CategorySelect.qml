import QtQuick 2.2
import Sailfish.Silica 1.0

Page {
   id: categorySelectPage
       allowedOrientations: Orientation.All


   SilicaListView {
       id:list
       ViewPlaceholder {
           id: vplaceholder
           enabled: model.count == 0
           text: "Loading..."

       }

      header: PageHeader {
               title: "Categories"
               }
       anchors.top: header.bottom
       width: parent.width
       height: parent.height

       VerticalScrollDecorator {}
       model: ListModel { id: model}

       Component.onCompleted: {
           var xhr = new XMLHttpRequest;
           xhr.open("GET", "https://forum.sailfishos.org/categories.json");
           xhr.onreadystatechange = function() {
               if (xhr.readyState === XMLHttpRequest.DONE) {
                   var data = JSON.parse(xhr.responseText);
                   model.clear();

                   for (var i=0;i<data.category_list.categories.length;i++) {

                         model.append({textname: data.category_list.categories[i]["name"], topic: data.category_list.categories[i]["id"]});

                   }
               }
           }
           xhr.send();
       }


         delegate: BackgroundItem {
           width: parent.width
           height: Theme.paddingLarge + theTitle.contentHeight

           Label {
               id:  theTitle
               text: textname
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
               pageStack.replaceAbove(null, "FirstPage.qml", {"tid": topic, "textname": textname});
           }
           }
       }
  }

