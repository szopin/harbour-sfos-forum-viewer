import QtQuick 2.2
import Sailfish.Silica 1.0

Page { id: pollpage

    allowedOrientations: Orientation.All
    /*
        Polls of type number and multiple have "min"/"max",
        Polls of type number have "step"
        Polls of type regular have not
      {
        "name": "poll",
        "type": "multiple",
        "status": "open",
        "results": "always",
        "min": 1, "max": 18,
        "options": [
          { "id": "d3090135d6e4050a686dac81a8e56140", "html": "Vote Option Text", "votes": 0 },
          ...
          ],
        "voters": 2,
        "chart_type": "bar",
        "title": null
       }
     */
    property var polldata // input
    property var submitted_votes // input: array of ids corrsponding to poll.options
    property string postid // input, needed to post votes
    property string key // input, needed to post votes

    property bool votemode: (polldata.status == "open") && canVote
    property bool canSubmit: { var k = Object.keys(voteTracker); return (k.length > 0) }
    property bool canVote: submitted_votes.length == 0 && key != -1
    property var voteTracker: ({})

    // guard against unwieldy polls. randomly selected amount.
    readonly property int maxopts: 128
    /* Lookup table.
     * Set a property to true if we can handle the type here.
     */
    readonly property var pollType: {
        "regular":     { "supported": true,  "typeDisplayName": qsTr("Single Answer Poll") },
        "multiple":    { "supported": true,  "typeDisplayName": qsTr("Multiple Answer Poll") },
        "number":      { "supported": false, "typeDisplayName": qsTr("Rating Poll") },
        "unsupported": { "supported": false, "typeDisplayName": qsTr("Unsupported Poll") },
    }
    property ListModel pollmodel: ListModel{}

    function findFirstPage() {
        return pageStack.find(function(page) { return page.hasOwnProperty('loadmore'); });
    }

    Component.onCompleted: {
        if ( polldata.options.length > maxopts ) {
            placeholder.text = qsTr("This poll has more than %1 options, this is not supported." ).arg(maxopts)
            placeholder.hintText = qsTr("Please go back and open the poll in a browser window." )
            placeholder.enabled = true
            return
        }
        if (!pollType[polldata.type].supported) {
            placeholder.text = qsTr("This type of poll is not yet supported: %1").arg(pollType[polldata.type].typeDisplayName)
            placeholder.hintText = qsTr("Please go back and open the poll in a browser window." )
            placeholder.enabled = true
            return
        }
        // else
        populate()
    }

    function populate() {
        pollmodel.clear()
        polldata.options.forEach(function(o) { pollmodel.append(o) })
        submitted_votes.forEach(function(o) { voteTracker[o] = true })
    }

    // just so we can show something from outside the view
    property alias placeholder: view.placeholder

    SilicaListView { id: view
        anchors.fill: parent
        spacing: Theme.paddingMedium

        property Item  placeholder: viewplaceholder

        header: PageHeader { title: "%1: %2".arg(pollType[polldata.type].supported ? pollType[polldata.type].typeDisplayName : pollType["unsupported"].typeDisplayName).arg(polldata.title ? polldata.title : "")
                description: qsTr("Voters: %1 Status: %2").arg(polldata.voters).arg(canVote ? polldata.status : key != -1 ? qsTr("submitted") : qsTr("not logged in"))
        }
        model: pollmodel
        delegate: Column {
            width: ListView.view.width - Theme.horizontalPageMargin
            anchors.horizontalCenter: parent.horizontalCenter
            states: [
                State { name: "vote"; when: votemode && canVote
                    PropertyChanges { target: pollSwitch; visible: true }
                    PropertyChanges { target: bars; visible: false }
                },
                State { name: "voted"; when: votemode && !canVote
                    PropertyChanges { target: pollSwitch; visible: true }
                    PropertyChanges { target: bars; visible: false }
                },
                State { name: "view"; when: !votemode
                    PropertyChanges { target: pollSwitch; visible: false }
                    PropertyChanges { target: bars; visible: true }
                }
            ]
            /* TODO: for type == "number"  */
            /*
             Slider { id: pollSlider
                minimumValue: polldata.min ? polldata.min : 0
                maximumValue: polldata.max
                stepSize: polldata.step
             }
            */
            TextSwitch { id: pollSwitch
                width: parent.width
                opacity: visible ? 1.0 : 0
                Behavior on opacity { NumberAnimation { } }
                text: html // FIXME: if this actually contains HTML it may look bad
                description: canVote ? "" : qsTr("Votes: %1").arg(votes)
                checked: voteTracker[model.id] == true
                highlighted: down && canVote
                automaticCheck: false
                onClicked: {
                    // TODO: if poll type is multiple, we must respect:
                    //   -  the max value, maximum allowed votes
                    //   -  the min value, minimum allowed votes
                    if (!canVote) return
                    if (polldata.type === "multiple") { // record this click
                        var va = voteTracker
                        va[model.id] = !checked
                        voteTracker = new Object(va)
                    } else if (polldata.type === "regular") { // reset uservotes to contain just this
                        var va = {}
                        va[model.id] = !checked
                        voteTracker = new Object(va)
                    } else { // not supported
                        console.warn("click in unsupported poll mode")
                    }
                }
            }
            Row { id: viewText
                visible: bars.visible
                width: parent.width - Theme.horizontalPageMargin
                anchors.horizontalCenter: parent.horizontalCenter
                opacity: visible ? 1.0 : 0
                Behavior on opacity { NumberAnimation { } }
                Label { id: pollText
                    width: parent.width - pollNum.width
                    text: html
                    textFormat: Text.StyledText
                    wrapMode: Text.Wrap
                }
                Label { id: pollNum
                    text: votes //+ " (" + (votes / polldata.voters * 100).toFixed(1) + "%)"
                    color: Theme.secondaryColor
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
            // TODO: chart type *could* be "pie chart"
            //ProgressCircle { }
            ProgressBar { id: bars
                width: parent.width - Theme.horizontalPageMargin
                anchors.horizontalCenter: parent.horizontalCenter
                leftMargin: 0
                rightMargin: 0
                visible: bars.visible
                // that truncates, not good for long text.
                //label: html
                // large and ugly when used below a text label:
                // valueText: votes
                minimumValue: !!polldata.min ? polldata.min - 1 : 0
                maximumValue: polldata.voters
                value: votes
            }
        }
        VerticalScrollDecorator {}
        ViewPlaceholder { id: viewplaceholder }
        PullDownMenu{
            MenuItem { id: resetMenu
                visible: canVote
                enabled: canSubmit
                text: qsTr("Reset")
                onClicked: { voteTracker = new Object({}); populate() }
            }
            MenuItem { id: submitMenu
                visible: canVote
                enabled: canSubmit
                text: qsTr("Submit")
                onClicked: {
                    // make an array of ids out of the object with "id" as property name
                    var votes = Object.keys(voteTracker).map(function(id) { return id })
                    submitPoll(key, postid, polldata.name, votes)
                }
            }
            MenuItem { id: switchMenu
                text: votemode ? qsTr("View Results") : canVote ? qsTr("Vote") : qsTr("View Votes")
                onClicked: votemode = !votemode
            }
        }
    }
    /* docs seem to be missing this API.
     * according to
     * https://github.com/discourse/discourse_api/blob/main/lib/discourse_api/api/polls.rb
     * we need
     *    PUT to /polls/vote/
     *    payload: post_id, poll_name, options
     *    where poll_name is fixed "poll"
     *    and options is an array of option ids
    */
    function submitPoll(apikey, pid, name, options) {
        var xhr = new XMLHttpRequest;
        const json = { "post_id": pid, "poll_name": name, "options": options }
        //console.log(JSON.stringify(json));
        xhr.open("PUT", "https://forum.sailfishos.org/polls/vote/");
        xhr.setRequestHeader("User-Api-Key", apikey);
        xhr.setRequestHeader("Content-Type", 'application/json');
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE){
                if(xhr.statusText !== "OK"){
                    pageStack.completeAnimation();
                    pageStack.push("Error.qml", {errortext: xhr.responseText});
                } else {
                    console.log(xhr.responseText);
                    findFirstPage().refresh();
                    pageStack.pop()
                }
            }
        }
        xhr.send(JSON.stringify(json));
    }
}
