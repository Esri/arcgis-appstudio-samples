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

import QtQuick 2.6
import QtQuick.Layouts 1.1
import ArcGIS.AppFramework 1.0

Rectangle {
    id: statusIndicator

    // PROPERTIES //////////////////////////////////////////////////////////////

    property bool hideAutomatically: false
    property bool animateHide: false
    property int hideAfter: 30000
    property int containerHeight: 50
    property int statusTextFontSize: 14
    property int indicatorBorderWidth: 1
    property string statusTextFontColor: "#111"
    property alias message: statusText.text
    property alias statusTextObject: statusText

    readonly property var success: {
        "backgroundColor": "#DDEEDB",
        "borderColor": "#9BC19C"
    }

    readonly property var info: {
        "backgroundColor": "#D2E9F9",
        "borderColor": "#3B8FC4"
    }

    readonly property var warning: {
        "backgroundColor": "#F3EDC7",
        "borderColor": "#D9BF2B"
    }

    readonly property var error: {
        "backgroundColor": "#F3DED7",
        "borderColor": "#E4A793"
    }

    property var messageType: success

    signal show()
    signal hide()

    color: messageType.backgroundColor
    height: containerHeight
    Layout.preferredHeight: containerHeight
    border.width: indicatorBorderWidth
    border.color: messageType.borderColor
    visible: false
    radius: 6 * AppFramework.displayScaleFactor

    // UI //////////////////////////////////////////////////////////////////////

    Text{
        id: statusText
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        color: statusTextFontColor
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        textFormat: Text.RichText
        text: ""
        font.pointSize: statusTextFontSize
        wrapMode: Text.WordWrap
        onLinkActivated: {
            Qt.openUrlExternally(link);
        }
    }

    // SIGNALS /////////////////////////////////////////////////////////////////

    onShow: {
       statusIndicator.opacity = 1;
       statusIndicator.visible = true;
        if(hideAutomatically===true){
            hideStatusMessage.start();
        }
    }

    //--------------------------------------------------------------------------

    onHide: {
        if(animateHide===true){
            fader.start()
        }
        else{
            statusIndicator.visible = false;
            if(hideStatusMessage.running===true){
                hideStatusMessage.stop();
            }
        }
    }

    // COMPONENTS //////////////////////////////////////////////////////////////

    Timer {
        id: hideStatusMessage
        interval: hideAfter
        running: false
        repeat: false
        onTriggered: hide()
    }

    //--------------------------------------------------------------------------

    PropertyAnimation{
        id:fader
        from: 1
        to: 0
        duration: 1000
        property: "opacity"
        running: false
        easing.type: Easing.Linear
        target: statusIndicator

        onStopped: {
            statusIndicator.visible = false;
            if(hideStatusMessage.running===true){
                hideStatusMessage.stop();
            }
        }
    }


}
