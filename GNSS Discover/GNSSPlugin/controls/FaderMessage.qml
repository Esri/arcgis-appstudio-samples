/* Copyright 2021 Esri
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

import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15

import ArcGIS.AppFramework 1.0

Item {
    id: control

    property alias text: messageText.text
    property alias textColor: messageText.color
    property alias backgroundColor: background.color
    property alias duration: hideAnimator.duration
    property alias glowColor: glow.color
    property alias icon: image.source

    property string fontFamily: Qt.application.font.family
    property real pixelSize: 20 * AppFramework.displayScaleFactor
    property real letterSpacing: 0
    property bool bold: false

    readonly property int kDefaultDuration: 3000
    readonly property color kDefaultTextColor: "white"
    readonly property color kDefaultBackgroundColor: "blue"

    //--------------------------------------------------------------------------

    height: 60 * AppFramework.displayScaleFactor

    anchors {
        left: parent.left
        right: parent.right
        margins: 50 * AppFramework.displayScaleFactor
        verticalCenter: parent.verticalCenter
    }

    opacity: 0
    visible: opacity > 0

    //--------------------------------------------------------------------------

    RectangularGlow {
        id: glow

        anchors.fill: parent

        glowRadius: 10 * AppFramework.displayScaleFactor
        spread: 0.2
        color: "grey"
        cornerRadius: background.radius + glowRadius
    }

    //--------------------------------------------------------------------------

    Rectangle {
        id: background

        anchors {
            fill: parent
        }

        color: kDefaultBackgroundColor
        radius: 10 * AppFramework.displayScaleFactor
    }

    //--------------------------------------------------------------------------

    Rectangle {
        anchors {
            fill: background
            margins: 2 * AppFramework.displayScaleFactor
        }

        color: "transparent"
        radius: background.radius

        border {
            color: messageText.color
            width: 1 * AppFramework.displayScaleFactor
        }
    }

    //--------------------------------------------------------------------------

    RowLayout {
        id: layout

        anchors.centerIn: parent

        width: parent.width * 0.8
        spacing: 10 * AppFramework.displayScaleFactor

        StyledImage {
            id: image

            Layout.preferredWidth: 40 * AppFramework.displayScaleFactor
            Layout.preferredHeight: Layout.preferredWidth

            visible: source > ""
            color: textColor
        }

        AppText {
            id: messageText

            Layout.fillWidth: true

            color: kDefaultTextColor
            horizontalAlignment: Text.AlignHCenter

            fontFamily: control.fontFamily
            pixelSize: control.pixelSize
            letterSpacing: control.letterSpacing
            bold: control.bold
        }
    }

    //--------------------------------------------------------------------------

    OpacityAnimator {
        id: hideAnimator

        easing.type: Easing.InCubic
        target: control
        from: 1
        to: 0
        duration: kDefaultDuration
    }

    //--------------------------------------------------------------------------

    function show(text, icon, textColor, backgroundColor, duration) {
        if (text) {
            messageText.text = text;
        }

        if (icon) {
            image.source = icon;
        } else {
            image.source = "";
        }

        messageText.color = textColor !== undefined ? textColor: kDefaultTextColor;
        background.color = backgroundColor !== undefined ? backgroundColor: kDefaultBackgroundColor;

        hideAnimator.stop();
        hideAnimator.duration = duration !== undefined ? duration : kDefaultDuration;
        opacity = 1;
        hideAnimator.start();
    }

    //--------------------------------------------------------------------------

    function hide(fade) {
        hideAnimator.stop();
        opacity = 0;
    }

    //--------------------------------------------------------------------------
}
