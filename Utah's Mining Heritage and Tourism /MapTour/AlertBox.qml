/* Copyright 2015 Esri
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

import QtQuick 2.2
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1

//import ArcGIS.AppFramework 1.0
//import ArcGIS.AppFramework.Controls 1.0
//import ArcGIS.AppFramework.Runtime 1.0

Item {

    id: alertBox
    visible: false
    property string text : "Alert!"
    width: parent.width
    height: parent.height
    property color backgroundColor: app.headerBackgroundColor
    property color textColor : app.textColor

    Rectangle {
        anchors.centerIn: parent;
        z:11
        height: (alertBoxText.contentHeight + 20) * app.scaleFactor
        color: backgroundColor
        radius: 5*app.scaleFactor
        width: Math.min(parent.width, 400*app.scaleFactor)
        anchors.margins: 10*app.scaleFactor

        MouseArea {
            anchors.fill: parent
            onClicked: {
                alertBox.visible = false
            }
        }

        Text {
            id: alertBoxText
            color: textColor
            //fontSizeMode: Text.Fit
            anchors.fill: parent
            anchors.margins: 10*app.scaleFactor
            maximumLineCount: 4
            textFormat: Text.StyledText

            anchors.leftMargin: 5*app.scaleFactor
            anchors.rightMargin: 5*app.scaleFactor

            wrapMode: Text.Wrap

            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            horizontalAlignment: Text.AlignHCenter


            font {
                pointSize: app.baseFontSize * 0.8
            }

            text: alertBox.text
        }
    }

}
