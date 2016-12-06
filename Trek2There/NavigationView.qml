/* Copyright 2016 Esri
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

import QtQuick 2.5
import QtQml 2.2
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0
import QtPositioning 5.4
import QtQuick.Dialogs 1.2
import QtQuick.Window 2.2

import ArcGIS.AppFramework 1.0

//------------------------------------------------------------------------------

Item {

    id: navigationView

    // PROPERTIES //////////////////////////////////////////////////////////////

    property bool navigating: false
    property bool arrivedAtDestination: false
    property bool autohideToolbar: true
    property double currentDistance: 0.0
    property double currentDegreesOffCourse: 0
    property int sideMargin: 14 * AppFramework.displayScaleFactor

    signal arrived()
    signal reset()
    signal startNavigation()
    signal pauseNavigation()
    signal endNavigation()

    //--------------------------------------------------------------------------

    Component.onCompleted: {
        if(requestedDestination !== null){
            startNavigation();
        }
    }

    // UI //////////////////////////////////////////////////////////////////////

    Rectangle {
        id: appFrame
        anchors.fill: parent
        color: !nightMode ? dayModeSettings.background : nightModeSettings.background

        MouseArea{
            id: viewTouchArea
            anchors.fill: parent
            enabled: autohideToolbar ? true : false

            onClicked: {
                if(toolbar.opacity === 0){
                    toolbar.opacity = 1;
                    toolbar.enabled = true;
                    hideToolbar.start();
                }
            }
        }

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "transparent"

                ColumnLayout{
                    anchors.fill: parent
                    spacing: 0

                    //----------------------------------------------------------

                    Rectangle{
                        id:statusMessageContianer
                        Layout.fillWidth: true
                        Layout.preferredHeight: 40 * AppFramework.displayScaleFactor
                        Layout.rightMargin: 10 * AppFramework.displayScaleFactor
                        Layout.leftMargin: 10 * AppFramework.displayScaleFactor
                        Layout.topMargin: 10 * AppFramework.displayScaleFactor
                        visible: true
                        color:"transparent"

                        StatusIndicator{
                            id: statusMessage
                            visible: false
                            anchors.fill: parent
                            containerHeight: parent.height
                            hideAutomatically: false
                            animateHide: false
                            messageType: statusMessage.warning
                            message: qsTr("Start moving to determine direction.")
                        }
                    }

                   // DIRECTION ARROW //////////////////////////////////////////

                    Rectangle {
                        id: directionUI
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        color: !nightMode ? dayModeSettings.background : nightModeSettings.background
                        property int imageScaleFactor: 40 * AppFramework.displayScaleFactor

                        Rectangle{
                            id: noDestinationSet
                            anchors.fill: parent
                            anchors.leftMargin: sideMargin
                            anchors.rightMargin: sideMargin
                            z:100
                            visible: (requestedDestination === null) ? true : false
                            color: !nightMode ? dayModeSettings.background : nightModeSettings.background

                            Rectangle{
                                anchors.centerIn: parent
                                height: 80 * AppFramework.displayScaleFactor
                                width: parent.width
                                color:!nightMode ? dayModeSettings.background : nightModeSettings.background

                                ColumnLayout{
                                    anchors.fill: parent
                                    spacing: 0

                                    Text{
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        color: !nightMode ? dayModeSettings.foreground : nightModeSettings.foreground
                                        fontSizeMode: Text.Fit
                                        wrapMode: Text.Wrap
                                        font.pointSize: largeFontSize
                                        minimumPointSize: 9
                                        font.weight: Font.Black
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                        text: qsTr("No destination set!")
                                    }
                                    Text{
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        color: !nightMode ? dayModeSettings.foreground : nightModeSettings.foreground
                                        fontSizeMode: Text.Fit
                                        wrapMode: Text.Wrap
                                        font.pointSize: baseFontSize
                                        minimumPointSize: 9
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                        text: qsTr("Go to <img src=\"images/settings.png\" width='%1' height='%2'>&nbsp; to set your destination.".arg(30 * AppFramework.displayScaleFactor).arg(30 * AppFramework.displayScaleFactor))
                                    }
                                }

                            }


                        }

                        //------------------------------------------------------

                        Rectangle{
                            anchors.fill: parent
                            color: !nightMode ? dayModeSettings.background : nightModeSettings.background
                            z:99

                            Image{
                                id: directionOfTravel
                                anchors.centerIn: parent
                                height: isLandscape ? parent.height : parent.height - directionUI.imageScaleFactor
                                width: isLandscape ? parent.width : parent.width - directionUI.imageScaleFactor
                                source: "images/direction_of_travel_circle.png"
                                fillMode: Image.PreserveAspectFit
                                visible: useDirectionOfTravelCircle
                            }

                            Image{
                                id: directionArrow
                                anchors.centerIn: parent
                                source: !nightMode ? "images/arrow_day.png" : "images/arrow_night.png"
                                width: isLandscape ? parent.width - directionUI.imageScaleFactor : parent.width - (useDirectionOfTravelCircle === false ? directionUI.imageScaleFactor * 2.5 : directionUI.imageScaleFactor * 3)
                                height: isLandscape ? parent.height - directionUI.imageScaleFactor : parent.height - (useDirectionOfTravelCircle === false ? directionUI.imageScaleFactor * 2.5 : directionUI.imageScaleFactor * 3)
                                fillMode: Image.PreserveAspectFit
                                rotation: currentDegreesOffCourse
                                opacity: 1
                                visible: true
                            }

                            Image{
                                id: arrivedIcon
                                anchors.centerIn: parent
                                source: !nightMode ? "images/map_pin_day.png" : "images/map_pin_night.png"
                                width: isLandscape ? parent.width - directionUI.imageScaleFactor : parent.width - (useDirectionOfTravelCircle === false ? directionUI.imageScaleFactor * 2.5 : directionUI.imageScaleFactor * 3)
                                height: isLandscape ? parent.height - directionUI.imageScaleFactor : parent.height - (useDirectionOfTravelCircle === false ? directionUI.imageScaleFactor * 2.5 : directionUI.imageScaleFactor * 3)
                                fillMode: Image.PreserveAspectFit
                                rotation: 0
                                visible: false
                            }
                        }
                        //------------------------------------------------------
                    }
                }
            }

            // DISTANCE READOUT ////////////////////////////////////////////////

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 100 * AppFramework.displayScaleFactor
                color: !nightMode ? dayModeSettings.background : nightModeSettings.background

                Text {
                    id: distanceReadout
                    anchors.fill: parent
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    text: displayDistance(currentDistance.toString())
                    font.pointSize: extraLargeFontSize
                    font.weight: Font.Light
                    fontSizeMode: Text.Fit
                    minimumPointSize: largeFontSize
                    color: !nightMode ? dayModeSettings.foreground : nightModeSettings.foreground
                    visible: requestedDestination !== null
                }
            }

            // UTILITY | SETTINGS //////////////////////////////////////////////

            Rectangle {
                id: toolbar
                Layout.fillWidth: true
                Layout.preferredHeight: 50 * AppFramework.displayScaleFactor
                color: "transparent"
                opacity: 1

                RowLayout {
                    anchors.fill: parent
                    spacing: 0

                    //----------------------------------------------------------

                    Rectangle {
                        Layout.fillHeight: true
                        Layout.preferredWidth: 50 * AppFramework.displayScaleFactor
                        color: "transparent"

                        Button{
                            id: settingsButton
                            anchors.fill: parent
                            tooltip: qsTr("Settings")

                            style: ButtonStyle{
                                background: Rectangle{
                                    color: "transparent"
                                    anchors.fill: parent
                                }
                            }

                            Image{
                                id: settingsButtonIcon
                                anchors.centerIn: parent
                                height: parent.height - (24 * AppFramework.displayScaleFactor)
                                fillMode: Image.PreserveAspectFit
                                source: "images/settings.png"
                            }

                            onClicked:{
                                if(navigating === false){
                                    reset();
                                }
                                mainStackView.push({ item: settingsView });
                            }
                        }
                    }

                    //----------------------------------------------------------

                    Rectangle{
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        color: "transparent"
                        Button{
                            id: endNavigationButton
                            anchors.fill: parent
                            visible: false
                            enabled: false

                            style: ButtonStyle{
                                background: Rectangle{
                                    anchors.fill: parent
                                    anchors.bottomMargin: 5 * AppFramework.displayScaleFactor
                                    color: !nightMode ? dayModeSettings.background : nightModeSettings.background
                                    border.width: 1 * AppFramework.displayScaleFactor
                                    border.color: !nightMode ? dayModeSettings.buttonBorder : nightModeSettings.buttonBorder
                                    radius: 5 * AppFramework.displayScaleFactor
                                    Text{
                                        anchors.fill: parent
                                        verticalAlignment: Text.AlignVCenter
                                        horizontalAlignment: Text.AlignHCenter
                                        anchors.rightMargin: 15 * AppFramework.displayScaleFactor
                                        text: qsTr("End")
                                        color: buttonTextColor
                                    }
                                }
                            }

                            onClicked: {
                                endNavigation();
                                if(applicationCallback !== ""){
                                    callingApplication = "";
                                    Qt.openUrlExternally(applicationCallback);
                                    applicationCallback = "";
                                }
                            }
                        }
                    }

                    //----------------------------------------------------------

                    Rectangle {
                        Layout.fillHeight: true
                        Layout.preferredWidth: 50 * AppFramework.displayScaleFactor
                        color: "transparent"

                        Button{
                            id: viewModeButton
                            anchors.fill: parent
                            tooltip: qsTr("View Mode")

                            style: ButtonStyle{
                                background: Rectangle{
                                    color: "transparent"
                                    anchors.fill: parent
                                }
                            }

                            Image{
                                id: viewModeButtonIcon
                                anchors.centerIn: parent
                                height: parent.height - (24 * AppFramework.displayScaleFactor)
                                fillMode: Image.PreserveAspectFit
                                source: !nightMode ? "images/night_mode_blue.png" : "images/day_mode_blue.png"
                            }

                            onClicked:{
                                nightMode = !nightMode ? true : false;
                            }
                        }
                    }
                }
            }
            //------------------------------------------------------------------
        }
    }

    // SIGNALS /////////////////////////////////////////////////////////////////

    onArrived: {
        arrivedAtDestination = true;
        navigating = false;
        positionSource.stop();
        directionArrow.visible = false
        arrivedIcon.visible = true
        distanceReadout.text = qsTr("Arrived");
        try{
            appMetrics.trackEvent("Arrived at destination.");
        }
        catch(e){
            appMetrics.reportError(e, "onArrived");
        }
    }

    //--------------------------------------------------------------------------

    onReset: {
        console.log('reseting navigation')

        navigating = false;
        positionSource.active = false;
        positionSource.stop();

        statusMessage.hide();

        arrivedAtDestination = false;
        arrivedIcon.visible = false

        directionArrow.visible = true;
        directionArrow.rotation = 0;
        directionArrow.opacity = 1;

        currentDistance = 0.0;
        distanceReadout.text = displayDistance(currentDistance.toString());

        if(autohideToolbar === true){
            if(hideToolbar.running){
                hideToolbar.stop();
            }
            if(fadeToolbar.running){
                fadeToolbar.stop();
            }
            toolbar.opacity = 1;
            toolbar.enabled = true;
        }

    }

    //--------------------------------------------------------------------------

    onStartNavigation:{
        console.log('starting navigation')
        reset(); // TODO: This may cause some hiccups as positoin source is stopped and started. even though update is called, not sure all devices allow the update immedieately.
        navigating = true;
        positionSource.active = true;
        positionSource.update();
        currentPosition.destinationCoordinate = requestedDestination;
        positionSource.update();
        endNavigationButton.visible = true;
        endNavigationButton.enabled = true;

        if(autohideToolbar === true){
            hideToolbar.start();
        }

        try{
            appMetrics.startSession();
            if(callingApplication !== null && callingApplication !== ""){
                appMetrics.trackEvent("App called from: " + callingApplication);
            }
        }
        catch(e){
            appMetrics.reportError(e, "onStartNavigation");
        }

        if(logTreks){
            trekLogger.startRecordingTrek();
        }
    }

    //--------------------------------------------------------------------------

    onPauseNavigation:{
    }

    //--------------------------------------------------------------------------

    onEndNavigation:{
        console.log('ending navigation')
        reset();
        navigating = false;
        endNavigationButton.visible = false;
        endNavigationButton.enabled = false;
        requestedDestination = null;

        if(logTreks){
            trekLogger.stopRecordingTrek();
        }

        try{
            if(arrivedAtDestination === false){
                appMetrics.trackEvent("Ended navigation without arrival.");
            }
        }
        catch(e){
            appMetrics.reportError(e, "onEndNavigation");
        }

    }

    // COMPONENTS //////////////////////////////////////////////////////////////

    PositionSource {
        id: positionSource

        onPositionChanged: {
            if (position.coordinate.isValid === true) {
                console.log("lat: %1, long:%2".arg(position.coordinate.latitude).arg(position.coordinate.longitude));
                currentPosition.position = position;
            }

           if(requestedDestination !== null){
                /*
                    TODO: On some Android devices position.directionValid must return
                    true so the statusMessage isn't shown when navigation first starts
                    in order to inform the user to move. This isn't an issue on iOS.
                    May need to evaluate reset() method that hides the status
                    message as well as the startNavigation method as well to fix this.
                */
                if (position.directionValid){
                    statusMessage.hide();
                }
                else{
                    directionArrow.opacity = 0.2;
                    statusMessage.show();
                }
           }
        }

        onSourceErrorChanged: {
        }
    }

    //--------------------------------------------------------------------------

    CurrentPosition {
        id: currentPosition

        onDistanceToDestinationChanged: {
            if(navigating === true){
                distanceReadout.text = displayDistance(distanceToDestination);
            }
        }

        onDegreesOffCourseChanged: {
            if(degreesOffCourse === NaN || degreesOffCourse === 0){
                directionArrow.opacity = 0.2;
            }else{
                directionArrow.opacity = 1;
                directionArrow.rotation = degreesOffCourse;
            }
        }

        onAtDestination: {
            if(navigating===true){
                arrived();
            }
        }
    }

    //--------------------------------------------------------------------------

    Connections{
        target: app
        onRequestedDestinationChanged: {
            console.log(requestedDestination);
            if(requestedDestination !== null){
                startNavigation();
            }
        }
    }

    //--------------------------------------------------------------------------

    Timer {
        id: hideToolbar
        interval: 10000
        running: false
        repeat: false
        onTriggered: {
            fadeToolbar.start()
        }
    }

    //--------------------------------------------------------------------------

    PropertyAnimation{
        id:fadeToolbar
        from: 1
        to: 0
        duration: 1000
        property: "opacity"
        running: false
        easing.type: Easing.Linear
        target: toolbar

        onStopped: {
            toolbar.enabled = false;
            if(hideToolbar.running===true){
                hideToolbar.stop();
            }
        }
    }

    // METHODS /////////////////////////////////////////////////////////////////

    function displayDistance(distance) {

        if(usesMetric === false){
            var distanceFt = distance * 3.28084;
            if (distanceFt < 1000) {
                return "%1 ft".arg(Math.round(distanceFt).toLocaleString(locale, "f", 0))
            } else {
                var distanceMiles = distance * 0.000621371;
                return "%1 mi".arg((Math.round(distanceMiles * 10) / 10).toLocaleString(locale, "f", distanceMiles < 10 ? 1 : 0))
            }
        }
        else{
            if (distance < 1000) {
                return "%1 m".arg(Math.round(distance).toLocaleString(locale, "f", 0))
            } else {
                var distanceKm = distance / 1000;
                return "%1 km".arg((Math.round(distanceKm * 10) / 10).toLocaleString(locale, "f", distanceKm < 10 ? 1 : 0))
            }
        }
    }
}
