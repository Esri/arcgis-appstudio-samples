/* Copyright 2019 Esri
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

import QtQuick 2.7
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Dialogs 1.2

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Speech 1.0
import ArcGIS.AppFramework.Controls 1.0


import "controls" as Controls



App {
    id: app
    width: 414
    height: 736
    function units(value) {
        return AppFramework.displayScaleFactor * value
    }
    property real scaleFactor: AppFramework.displayScaleFactor
    property int baseFontSize : app.info.propertyValue("baseFontSize", 15 * scaleFactor) + (isSmallScreen ? 0 : 3)
    property bool isSmallScreen: (width || height) < units(400)

    Component.onCompleted: {
        volumeSlider.value = 50;
    }

    Page{
        anchors.fill: parent
        header: ToolBar{
            id:header
            width: parent.width
            height: 50 * scaleFactor
            Material.background: "#8f499c"
            Controls.HeaderBar{}
        }

        // sample starts here ------------------------------------------------------------------
        contentItem: Rectangle{


            ColumnLayout{
                anchors {
                    fill: parent
                    margins: 4 * AppFramework.displayScaleFactor
                }

                Text {
                    Layout.fillWidth: true
                    font.pixelSize: 40
                    text: "Enter text below..."
                }

                Rectangle{
                    Layout.fillWidth: true
                    Layout.preferredHeight: 200 * scaleFactor
                    color: transparent
                    border.color: black
                    border.width: 1 * scaleFactor
                    TextArea {
                        id: sayText
                        width: parent.width
                        Material.accent: "#8f499c"
                        padding: 5 * scaleFactor
                        selectByMouse: true
                        wrapMode: TextEdit.WrapAnywhere
                        text: "AppStudio is awesome"
                    }
                }

                Button {
                    Layout.fillWidth: true
                    text: "Say it"
                    onClicked: {
                        textToSpeech.say(sayText.text);
                    }
                }

                PropertySlider {
                    id: volumeSlider
                    Layout.fillWidth: true
                    name: "Volume"
                    onValueChanged: {
                        textToSpeech.volume = value/100;
                    }
                }

                AnimatedImage {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    source: "assets/speaker.gif"
                    playing: textToSpeech.state === TextToSpeech.Speaking
                    fillMode: Image.PreserveAspectFit
                }

            }

        }

    }

    TextToSpeech {
        id: textToSpeech

        property var locales

        Component.onCompleted: {
            var locales = []
            for (var i = 0; i < availableLocales.length; i++) {
                var name = availableLocales[i];
                var localeInfo = AppFramework.localeInfo(name);
                locales.push({
                      name: name,
                      label: "%1 (%2)".arg(localeInfo.countryName).arg(localeInfo.languageName)
                });
            }

            textToSpeech.locales = locales;
        }
    }

    // sample ends here ------------------------------------------------------------------------
    Controls.DescriptionPage{
        id:descPage
        visible: false
    }
}

