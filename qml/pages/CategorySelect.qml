import QtQuick 2.2
import Sailfish.Silica 1.0

Page {
    id: categorySelectPage
    allowedOrientations: Orientation.All

    function findFirstPage() {
        return pageStack.find(function(page) { return (page._depth === 0); });
    }

   SilicaListView {
       id:list
       ViewPlaceholder {
           id: vplaceholder
           enabled: catmodel.count == 0
           text: "Loading..."

       }

       header: Column {
           width: list.width; height: childrenRect.height
           spacing: 0

           PageHeader {
               id: pageHeader
               title: qsTr("Categories")
           }

           Item { width: parent.width; height: Theme.paddingSmall }
       }

       footer: Item { width: parent.width; height: Theme.horizontalPageMargin }

       anchors.top: header.bottom
       width: parent.width
       height: parent.height

       VerticalScrollDecorator {}
       model: ListModel { id: catmodel}

       Component.onCompleted: {
           var xhr = new XMLHttpRequest;
           xhr.open("GET", "https://forum.sailfishos.org/categories.json");
           xhr.onreadystatechange = function() {
               if (xhr.readyState === XMLHttpRequest.DONE) {
                   var data = JSON.parse(xhr.responseText);
                   catmodel.clear();

                   for (var i=0;i<data.category_list.categories.length;i++) {

                         catmodel.append({textname: data.category_list.categories[i]["name"], topic: data.category_list.categories[i]["id"]});

                   }
               }
           }
           xhr.send();
       }

       delegate: BackgroundItem {
           width: parent.width
           height: Theme.itemSizeSmall
           onClicked: {
               findFirstPage().showCategory(topic, textname);
               pageStack.navigateBack();
           }

           Label {
               id: theTitle
               text: textname
               wrapMode: Text.Wrap
               anchors {
                   left: parent.left; leftMargin: Theme.horizontalPageMargin
                   right: parent.right; rightMargin: Theme.horizontalPageMargin
                   verticalCenter: parent.verticalCenter
               }
           }
       }
   }
}
