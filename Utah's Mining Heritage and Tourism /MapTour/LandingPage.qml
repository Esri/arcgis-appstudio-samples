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

import ArcGIS.AppFramework.Controls 1.0

Image {
    signal signInClicked()

    source: app.landingpageBackground
    fillMode: Image.PreserveAspectCrop

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#55000000";}
            GradientStop { position: 1.0; color: "#00000000";}
        }
    }

    Text {
        id: titleText

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            topMargin: app.height/10
        }

        font.family: app.customTitleFont.name

        text: app.info.title
        font {
            //pointSize: 60
            pointSize: app.baseFontSize * 1.9
        }
        color: app.titleColor
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.Wrap
    }

    Text {
        id: subtitleText
        anchors {
            left: parent.left
            right: parent.right
            top: titleText.bottom
            margins: 5*app.scaleFactor
            topMargin: 30*app.scaleFactor
        }

        font.family: app.customTextFont.name

        text: app.info.snippet
        font {
            pointSize: app.baseFontSize
        }
        color: app.subtitleColor
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.Wrap
    }

    Image {
        id: testimage
        source: app.loginImage
        visible: false
    }

    ImageButton {
        id: signInButton

        anchors {
            horizontalCenter: parent.horizontalCenter
            top: subtitleText.bottom
            topMargin: 40 * app.scaleFactor
        }

        checkedColor : "transparent"
        pressedColor : "transparent"
        hoverColor : "transparent"
        glowColor : "transparent"


        width: Math.min(testimage.sourceSize.width, 250) * app.scaleFactor
        height: Math.min(testimage.sourceSize.height, 125) * app.scaleFactor
        source: app.loginImage

        onClicked: {
            signInClicked();
        }
    }

    Image {
        id: logoButton

        anchors {
            left: parent.left
            bottom: parent.bottom
            margins: 5 * app.scaleFactor
        }

        fillMode: Image.PreserveAspectFit

        width: Math.min(sourceSize.width, 80) * app.scaleFactor
        height: Math.min(sourceSize.height, 80*sourceSize.height/sourceSize.width) * app.scaleFactor

        Component.onCompleted: {
            console.log("Logo image original size: ", sourceSize.width, sourceSize.height);
            console.log("Display size: ", width, height)
        }

        source: app.logoImage

        MouseArea {
            anchors.fill: parent
            onClicked: {
                if(app.logoUrl && app.logoUrl.length > 1)
                    Qt.openUrlExternally(unescape(app.logoUrl));
            }
        }
    }

    ImageButton {

        anchors {
            right: parent.right
            bottom: parent.bottom
            margins: 5 * app.scaleFactor
        }

        checkedColor : "transparent"
        pressedColor : "transparent"
        hoverColor : "transparent"
        glowColor : "transparent"

        height: 30 * app.scaleFactor
        width: 30 * app.scaleFactor

        source: "images/info.png"

        visible: app.showDescriptionOnStartup

        onClicked: {
            aboutPage.visible = true;
        }

    }

    AboutPage {
        id: aboutPage
    }

}
