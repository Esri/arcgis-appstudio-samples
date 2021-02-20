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

import QtQuick 2.7
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtGraphicalEffects 1.0

import ArcGIS.AppFramework 1.0

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
    property bool isTablet: AppFramework.systemInformation.family === "tablet"
    property bool isPhone: (AppFramework.systemInformation.family === "phone")

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
        contentItem: Rectangle {
            anchors.top:header.bottom

            CryptographicHash {
                id: hashObj
                algorithm: CryptographicHash.Md4
                onResultChanged: {
                    hashText.text = result.data.toString();
                }
            }

            MessageAuthenticationCode {
                id: macObj
                algorithm: CryptographicHash.Md4
                key: AppFramework.binaryData("key");
                onResultChanged: {
                    macText.text = result.data.toString();
                }
            }

            Rectangle {
                anchors.margins: 5 * scaleFactor
                anchors.fill: parent
                color:"#F5F5F5"

                Rectangle {
                    anchors.margins: 4 * scaleFactor
                    anchors.fill: parent
                    color:"#F5F5F5"

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 0

                        Item {
                            Layout.preferredHeight: parent.height * 1/10
                            Layout.preferredWidth: parent.width

                            RowLayout {
                                anchors.fill: parent
                                spacing: 10 * scaleFactor

                                Controls.CustomizedText {
                                    id: texttohash
                                    Layout.preferredWidth: isTablet ? Math.max(0.15 * parent.width, 10 * scaleFactor) : Math.max(0.25 * parent.width, 10 * scaleFactor)
                                    cusText: qsTr("Text to hash: ")
                                }

                                Item {
                                    Layout.fillWidth: true

                                    TextField {
                                        width: parent.width
                                        anchors.verticalCenter: parent.verticalCenter
                                        placeholderText: qsTr("Enter a text to hash")
                                        Material.accent: "#8f499c"
                                        font.pixelSize: 14 * scaleFactor
                                        clip: true
                                        selectByMouse: true
                                        onTextChanged: {
                                            hashObj.data = text;
                                            macObj.data = text;
                                        }
                                    }
                                }
                            }
                        }

                        Item {
                            Layout.preferredHeight: parent.height * 1/10
                            Layout.preferredWidth: parent.width

                            RowLayout {
                                anchors.fill: parent
                                spacing: 10 * scaleFactor

                                Controls.CustomizedText {
                                    Layout.preferredWidth: isTablet ? Math.max(0.15 * parent.width, 10 * scaleFactor) : Math.max(0.25 * parent.width, 10 * scaleFactor)
                                    cusText: qsTr("Key: ")
                                }

                                Item {
                                    Layout.fillWidth: true

                                    TextField {
                                        width: parent.width
                                        anchors.verticalCenter: parent.verticalCenter
                                        placeholderText: qsTr("Enter key")
                                        Material.accent: "#8f499c"
                                        selectByMouse: true
                                        font.pixelSize: 14 * scaleFactor
                                        onTextChanged: {
                                            //hashObj.data = text;
                                            macObj.key = AppFramework.binaryData(text);
                                        }
                                    }
                                }
                            }
                        }

                        Item {
                            Layout.preferredHeight: parent.height * 1/10
                            Layout.preferredWidth: parent.width

                            RowLayout {
                                anchors.fill: parent
                                spacing: 10 * scaleFactor

                                Controls.CustomizedText {
                                    Layout.preferredWidth: isTablet ? Math.max(0.15 * parent.width, 10 * scaleFactor) : Math.max(0.25 * parent.width, 10 * scaleFactor)
                                    cusText: qsTr("Algorithm")
                                }

                                ComboBox {
                                    id: algorithCombo
                                    Material.accent: "#8f499c"
                                    Layout.fillWidth: true
                                    model: ["MD4", "MD5", "SHA1", "SHA_224", "SHA_256", "SHA_384", "KECCAK_224", "KECCAK_256", "KECCAK_256",
                                        "KECCAK_384", "KECCAK_512", "SHA3_224", "SHA3_256", "SHA3_384", "SHA3_512"]
                                    onCurrentTextChanged: {
                                        var alg = textToEnum(algorithCombo.currentText);
                                        hashObj.algorithm = alg;
                                        macObj.algorithm = alg;
                                    }
                                }
                            }
                        }

                        Item {
                            Layout.preferredHeight: parent.height * 1/10
                            Layout.preferredWidth: parent.width

                            RowLayout {
                                anchors.fill: parent
                                spacing: 10 * scaleFactor

                                Controls.CustomizedText {
                                    Layout.preferredWidth: isTablet ? Math.max(0.15 * parent.width, 10 * scaleFactor) : Math.max(0.25 * parent.width, 10 * scaleFactor)
                                    cusText: qsTr("Hex output")
                                }

                                CheckBox {
                                    id: hexOutputCheckBox
                                    Material.accent: "#8f499c"
                                    width: 20 * scaleFactor
//                                    checked: macObj.hexOutput
                                    onCheckedChanged: {
                                        hashObj.hexOutput = checked;
                                        macObj.hexOutput = checked;
                                    }
                                }

                                Item {
                                    Layout.fillWidth: true
                                }
                            }
                        }

                        Item {
                            Layout.preferredHeight: parent.height * 1/10
                            Layout.preferredWidth: parent.width

                            RowLayout {
                                anchors.fill: parent
                                spacing: 10 * scaleFactor

                                Controls.CustomizedText {
                                    Layout.preferredWidth: isTablet ? Math.max(0.15 * parent.width, 10 * scaleFactor) : Math.max(0.25 * parent.width, 10 * scaleFactor)
                                    cusText: qsTr("Key as bytes")
                                }

                                CheckBox {
                                    id: keyAsBytesCheckBox
                                    Material.accent: "#8f499c"
                                    width: 20 * scaleFactor
//                                    checked: macObj.keyAsBytes
                                    onCheckedChanged: {
                                        macObj.keyAsBytes = checked;
                                    }
                                }

                                Item {
                                    Layout.fillWidth: true
                                }
                            }
                        }

                        Item {
                            Layout.preferredHeight: 5 * scaleFactor
                            Layout.preferredWidth: parent.width
                        }

                        Rectangle {
                            id: divider
                            Layout.preferredHeight: 1 * scaleFactor
                            Layout.preferredWidth: parent.width
                            color: Material.color(Material.Grey)
                        }

                        Item {
                            Layout.preferredHeight: 5 * scaleFactor
                            Layout.preferredWidth: parent.width
                        }

                        Item {
                            Layout.preferredHeight: parent.height * 1/5
                            Layout.preferredWidth: parent.width

                            RowLayout {
                                anchors.fill: parent
                                spacing: 10 * scaleFactor


                                Controls.CustomizedText {
                                    Layout.preferredWidth: isTablet ? Math.max(0.15 * parent.width, 10 * scaleFactor) : Math.max(0.25 * parent.width, 10 * scaleFactor)
                                    cusText: qsTr("Hash: ")
                                }

                                Item {
                                    Layout.fillWidth: true

                                    TextField {
                                        id: hashText
                                        width: parent.width
                                        font.pixelSize: 14 * scaleFactor
                                        anchors.verticalCenter: parent.verticalCenter
                                        Material.accent: "#8f499c"
                                        wrapMode: Text.WrapAnywhere
                                        clip: true
                                    }
                                }
                            }
                        }

                        Item {
                            Layout.preferredHeight: parent.height * 1/5
                            Layout.preferredWidth: parent.width

                            RowLayout {
                                anchors.fill: parent
                                spacing: 10 * scaleFactor


                                Controls.CustomizedText {
                                    Layout.preferredWidth: isTablet ? Math.max(0.15 * parent.width, 10 * scaleFactor) : Math.max(0.25 * parent.width, 10 * scaleFactor)
                                    cusText:  qsTr("Mac: ")
                                }

                                Item {
                                    Layout.fillWidth: true

                                    TextField {
                                        id: macText
                                        width: parent.width
                                        font.pixelSize: 14 * scaleFactor
                                        anchors.verticalCenter: parent.verticalCenter
                                        Material.accent: "#8f499c"
                                        wrapMode: Text.WrapAnywhere
                                        clip: true
                                    }
                                }
                            }
                        }

                        Item {
                            Layout.fillHeight: true
                        }
                    }
                }
            }
        }
    }

    // sample ends here ------------------------------------------------------------------------
    Controls.DescriptionPage{
        id:descPage
        visible: false
    }

    function textToEnum (algText) {
        var result = "" ;

        switch (algText) {
        case "MD4":
            return CryptographicHash.Md4;

        case "MD5":
            return CryptographicHash.Md5;
        case "SHA1":
            return CryptographicHash.Sha1;
        case "SHA_224":
            return CryptographicHash.Sha_224;
        case "SHA_256":
            return CryptographicHash.Sha_256;
        case "SHA_384":
            return CryptographicHash.Sha_384;
        case "KECCAK_224":
            return CryptographicHash.Keccak_224;
        case "KECCAK_256":
            return CryptographicHash.Keccak_256;
        case "KECCAK_384":
            return CryptographicHash.Keccak_384;
        case "KECCAK_512":
            return CryptographicHash.Keccak_512;
        case "SHA3_224":
            return CryptographicHash.Sha3_224;
        case "SHA3_256":
            return CryptographicHash.Sha3_256;
        case "SHA3_384":
            return CryptographicHash.Sha3_384;
        case "SHA3_512":
            return CryptographicHash.Sha3_512;
        }

        return result;
    }

    function testAWS() {

        var myKey   = "AWS4wJalrXUtnFEMI/K7MDENG+bPxRfiCYEXAMPLEKEY";
        var myData = "20120215";
        var region = "us-east-1";
        var service = "iam";

        // PROCESS
        var kDate = macObj.hmacSHA256(myData, AppFramework.binaryData(myKey), false);
        console.log("------------------------------------------------")
        console.log(typeof kDate);
        console.log("kDate: ****** ", kDate.data.toString(), " *****");
        console.log("kDate: ", JSON.stringify(kDate));

        var kRegion = macObj.hmacSHA256(region, kDate);
        console.log("------------------------------------------------")
        console.log(typeof kRegion);
        console.log("kRegion: ****** ", kRegion.data.toString(), " *****");
        console.log("kRegion: ", JSON.stringify(kRegion));

        var kService = macObj.hmacSHA256(service, kRegion);
        console.log("------------------------------------------------")
        console.log(typeof kService);
        console.log("kService: ****** ", kService.data.toString(), " *****");
        console.log("kService: ", JSON.stringify(kService));

        var kSigning = macObj.hmacSHA256("aws4_request", kService);
        console.log("------------------------------------------------")
        console.log(typeof kSigning);
        console.log("kSigning: ****** ", kSigning.data.toString(), " *****");
        console.log("kSigning: ", JSON.stringify(kSigning));

    }
}

