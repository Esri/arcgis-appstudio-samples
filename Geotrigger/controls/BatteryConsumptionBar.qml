import QtQuick 2.0
import QtQuick.Layouts 1.3

import ArcGIS.AppFramework.Platform 1.0

Item {
    id: batteryConsumptionBar
    height: batteryBarHeight
    anchors.fill: parent

    //Functions and properties for getting device battery info

    function getBatteryState(){
        var batteryState = Battery.state
        switch(batteryState) {
        case 0:
            return "Unknown"
        case 1:
            return "Not charging"
        case 2:
            return "Discharging"
        case 3:
            return "Charging"
        case 4:
            return "Full Charge"
        default:
            return "Error"
        }
    }

    function getBatteryPowerMode(){
        var batteryMode = Battery.mode
        switch(batteryMode) {
        case 0:
            return "Unknown"
        case 1:
            return "Balanced"
        case 2:
            return "Saver"
        default:
            return "Error"
        }
    }

    function getBatteryPowerSource() {
        var batterySource = Battery.source
        switch(batterySource) {
        case 0:
            return "Unknown"
        case 1:
            return "AC"
        case 2:
            return "USB"
        case 3:
            return "Wireless"
        case 4:
            return "Battery"
        default:
            return "Error"
        }
    }

    property bool timerRunning: true

    property int batteryBarHeight: 30 * scaleFactor
    property double startTime: new Date().getTime()

    property bool initBattery: false
    property int startingBatteryLevel: 100
    property int currentBatteryLevel: Battery.level
    property string currentBatteryState: getBatteryState()
    property string currentBatteryPowerMode: getBatteryPowerMode()
    property string currentBatteryPowerSource: getBatteryPowerSource()

    //Checks battery state changes, if discharing, set initial battery level and time
    Connections {
        target: Battery
        function onStateChanged(){
            if(currentBatteryState === "Discharging"){
                startTime = new Date().getTime()
                startingBatteryLevel = Battery.level;
            } else {
                startingBatteryLevel = 100;
            }
        }
    }

    Component.onCompleted: {
        startTime: new Date().getTime()
        startingBatteryLevel = Battery.level;
    }

    Rectangle {
        id: statusBar
        visible: currentBatteryState === "Discharging"
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        height: batteryBarHeight
        color: "lightgrey"
        border {
            width: 0.5 * scaleFactor
            color: "black"
        }

        RowLayout {
            anchors{
                fill: parent
                leftMargin: 10 * scaleFactor
                rightMargin: 10 * scaleFactor
            }
            Text {
                id:batteryText
                Layout.alignment: Qt.AlignLeft
                width: 150 * scaleFactor
                text: currentBatteryState !== "Discharging" ? "Battery Charging" : "Battery: " + Math.max((startingBatteryLevel - currentBatteryLevel),0) + "% consumed"
                font.pixelSize: 14 * scaleFactor
            }
            //Filler
            Item {
                Layout.fillWidth: true
                height: parent.height
            }
            Text {
                property int time: 0
                id:timerText
                Layout.alignment: Qt.AlignRight
                width: 150 * scaleFactor
                font.pixelSize: 14 * scaleFactor
            }

        }
    }

    //Used for Displaying time running while discharging
    Timer {
        id: timer
        interval: 1000
        running: timerRunning
        repeat: true
        onTriggered: {
            getTimeMinSec()
        }
    }

    //Returns string of time running in hours:minutes:seconds
    function getTimeMinSec(){

        var time = (new Date().getTime() - startTime) / 1000;
        var hours = 0;
        var minutes = 0;
        var seconds = 0;

        hours = Math.floor((time / 3600).toFixed(2));
        time = time - (hours * 3600);
        minutes = Math.floor((time / 60).toFixed(2));
        seconds = Math.floor((time % 60).toFixed(2));

        timerText.text = "Time lapse: " + (hours < 10 ? "0" + hours : hours) + ":" + (minutes < 10 ? "0" + minutes : minutes) + ":" + (seconds < 10 ? "0" + seconds : seconds)
    }
}
