import QtQuick 2.0
import Sailfish.Silica 1.0
import Nemo.Configuration 1.0

Dialog{
    id: settings

    allowedOrientations: Orientation.All

    property bool checkemb: checkem.value

    ConfigurationGroup {
        id: mainConfig
        path: "/apps/harbour-sfos-forum-viewer"

    }
    ConfigurationValue {
        id: checkem
        key: "/apps/harbour-sfos-forum-viewer/checkem"
    }
    ConfigurationValue {
        id: ctimer
        key: "/apps/harbour-sfos-forum-viewer/timer"
    }
    onAccepted: {
        console.log(checkemb, slider.value, checkem.value)
        mainConfig.setValue("checkem", checkemb);
        mainConfig.setValue("timer", slider.value);


    }
    SilicaFlickable{
        id: flick
        anchors.fill: parent
        PageHeader {
            id: pageHeader
            title: qsTr("Accept");
        }

        TextSwitch {
            id: switcha
            anchors.top: pageHeader.bottom
            text: qsTr("Check automatically")
            checked: checkemb
            onCheckedChanged: {
                checkemb = checked
            }
        }

        Slider {
            id: slider
            anchors.top: switcha.bottom
            width: parent.width
            enabled: checkemb
            highlighted: checkemb
            minimumValue: 1
            maximumValue: 60
            value: ctimer.value
            stepSize: 1
            valueText: qsTr("Minutes: ") + value
        }
    }
}
