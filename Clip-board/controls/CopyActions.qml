import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2
import QtLocation 5.3
import QtPositioning 5.3
import QtQuick.Controls.Material 2.1

import ArcGIS.AppFramework 1.0

Page {
    id: copyactions

    anchors.fill: parent
    header: ToolBar{
        id:header
        width: parent.width
        height: 50 * scaleFactor
        Material.background: "#8f499c"
        HeaderBar{}
    }
    property url urlValue: "http://webapps-cdn.esri.com/Apps/MegaMenu/img/logo.jpg"
    property color colorValue: "#00b2ff"

    ColumnLayout {
        anchors {
            fill: parent
            margins: 5 * AppFramework.displayScaleFactor
        }
        
        GroupBox {
            Layout.fillWidth: true
            implicitWidth: parent.width


            title: "TextField"
            
            ColumnLayout {
                anchors {
                    left: parent.left
                    right: parent.right
                }

                Rectangle{
                    Layout.fillWidth: true
                    Layout.preferredHeight: 75 * scaleFactor
                    color: "transparent"
                    border.color: "black"
                    border.width: 1 * scaleFactor
                    TextArea {
                        id: textField
                        width: parent.width
                        Material.accent: "#8f499c"
                        padding: 5 * scaleFactor
                        selectByMouse: true
                        wrapMode: TextEdit.WrapAnywhere
                        text: "AppStudio is Awesome"
                    }
                }
                

                Text {
                    Layout.fillWidth: true
                    
                    text: "Clipboard operations"
                }
                
                Flow {
                    Layout.fillWidth: true
                    
                    Button {
                        text: "Copy Text field"
                        
                        onClicked: {
                            AppFramework.clipboard.copy(textField.text);
                        }
                    }
                    
                    
                }
            }
        }

        GroupBox {
            Layout.fillWidth: true
            implicitWidth: parent.width


            title: "Image"

            ColumnLayout {
                anchors {
                    left: parent.left
                    right: parent.right
                }

                Text {
                    Layout.fillWidth: true

                    text: "Url: <b>%1</b>".arg(urlValue)
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                }

                Flow {
                    Layout.fillWidth: true

                    Image {

                        id: image
                        source: urlValue
                        height: 50 * AppFramework.displayScaleFactor
                        fillMode: Image.PreserveAspectFit

                        MouseArea {
                            anchors.fill: parent

                            onClicked: {
                                fileDialog.open();
                            }
                        }
                    }


                }

                Text {
                    Layout.fillWidth: true

                    text: "Clipboard operations"
                }

                Flow {
                    Layout.fillWidth: true

                Button {
                    text: "Copy Image"

                    onClicked: {
                        AppFramework.clipboard.copy(image);
                    }
                }




                }
            }
        }

        GroupBox {
            Layout.fillWidth: true
            implicitWidth: parent.width


            title: "Color"

            ColumnLayout {
                anchors {
                    left: parent.left
                    right: parent.right
                }

                Flow {
                    Layout.fillWidth: true

                    Rectangle {

                        width: 100
                        height: 50
                        color: colorValue
                        border {
                            color: "grey"
                            width: 1
                        }



                        MouseArea {
                            anchors.fill: parent

                            onClicked: {
                                colorDialog.open();
                            }
                        }
                    }

                    Rectangle {
                        id: pastedColor
                        width: 100
                        height: 50
                        border {
                            color: "grey"
                            width: 1
                        }


                        MouseArea {
                            anchors.fill: parent

                            onClicked: {
                                colorDialog.open();
                            }
                        }
                    }


                }
                Text {
                    Layout.fillWidth: true

                    text: "Clipboard operations"
                }
                Flow{
                    Layout.fillWidth: true
                    Button {
                        text: "Copy color %1".arg(colorValue)

                        onClicked: {
                            AppFramework.clipboard.color = colorValue;
                            pastedColor.color = colorValue;
                        }
                    }
                    /*
                    Button {
                        text: "Paste %1".arg(AppFramework.clipboard.color)

                        onClicked: {
                            colorValue = AppFramework.clipboard.color;
                        }
                    }
                    */
                }


            }
        }

   /*
        GroupBox {
            Layout.fillWidth: true
            Layout.fillHeight: true

            implicitWidth: parent.width

            title: "Other Clipboard operations"

            ColumnLayout {
                anchors {
                    left: parent.left
                    right: parent.right
                }

                Flow {
                    id: buttons

                    Layout.fillWidth: true

                    Button {
                        text: "Clear"

                        onClicked: {
                            AppFramework.clipboard.clear();
                        }
                    }

                    Button {
                        text: "Copy null"

                        onClicked: {
                            AppFramework.clipboard.copy(null);
                        }
                    }

                    Button {
                        text: "Copy undefined"

                        onClicked: {
                            AppFramework.clipboard.copy(undefined);
                        }
                    }

                    Button {
                        text: "Copy app window"

                        onClicked: {
                            AppFramework.grabWindowToClipboard();
                        }
                    }

                    Button {
                        text: "Copy number"

                        onClicked: {
                            AppFramework.clipboard.copy(123.456);
                        }
                    }

                    Button {
                        text: "Copy date"

                        onClicked: {
                            AppFramework.clipboard.copy(new Date());
                        }
                    }

                    Button {
                        text: "Copy boolean"

                        onClicked: {
                            AppFramework.clipboard.copy(true);
                        }
                    }

                    Button {
                        text: "Copy JavaScript object"

                        onClicked: {
                            var object = {
                                "stringProperty": "stringValue",
                                "boolProperty": true,
                                "numberValue": 123.456,
                                "dateValue": new Date(),
                                "arrayValue": ["A", "B", "C", 1, 2, 3],
                                "objectValue": {
                                    "stringProperty": "stringValue",
                                    "boolPropert2y": false,
                                    "numberValue": 654.321
                                }
                            };

                            AppFramework.clipboard.copy(object);
                        }
                    }

                    Button {
                        text: "Copy buttons"

                        onClicked: {
                            AppFramework.clipboard.copy(buttons);
                        }
                    }
                }
            }
        }
   */
    }

    ColorDialog {
        id: colorDialog

        color: colorValue
        title: "Choose color"

        onAccepted: {
            colorValue = currentColor;
        }
    }

    FileDialog {
        id: fileDialog

        title: "Select an image"
        selectExisting: true
        selectMultiple: false
        folder: shortcuts.pictures
        nameFilters: [ "Image files (*.jpg *.png)", "All files (*)" ]

        onAccepted: {
            urlValue = fileUrl;
        }
    }
}
