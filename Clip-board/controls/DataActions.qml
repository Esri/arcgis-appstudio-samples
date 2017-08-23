import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import QtLocation 5.3
import QtPositioning 5.3
import QtQuick.Controls.Material 2.1
import QtQuick.Dialogs 1.2

import ArcGIS.AppFramework 1.0

Page {
    id: dataactions

    anchors.fill: parent
    header: ToolBar{
        id:header
        width: parent.width
        height: 50 * scaleFactor
        Material.background: "#8f499c"
        HeaderBar{}
    }
    property BinaryData binaryData: dataTypeComboBox.currentIndex >= 0 ? AppFramework.clipboard.data(dataTypeComboBox.currentText) : null
    property var dataSize: binaryData ? binaryData.size : "N/A"

    onBinaryDataChanged: {
        dataText.text = "";
    }

    ColumnLayout {
        
        visible: AppFramework.clipboard.dataAvailable
        
        anchors {
            fill: parent
            margins: 5 * AppFramework.displayScaleFactor
        }
 /*
        GroupBox {
            Layout.fillWidth: true
            Layout.fillHeight: true
            implicitWidth: parent.width

            title: "Binary Data"

            ColumnLayout {
                anchors.fill: parent

                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: "Data types"
                    }

                    ComboBox {
                        id: dataTypeComboBox

                        Layout.fillWidth: true

                        model: AppFramework.clipboard.dataTypes
                    }
                }

                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        Layout.fillWidth: true

                        text: "size: %1 bytes".arg(dataSize)
                    }

                    Button {
                        text: "Show data as string"
                        enabled: binaryData != null

                        onClicked: {
                            dataText.text = binaryData.stringData();
                        }
                    }
                }



                TextArea {
                    id: dataText

                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    visible: text > ""
                }
            }
        }
*/
        GroupBox {
            Layout.fillWidth: true
            Layout.fillHeight: true
            implicitWidth: parent.width

            title: "text/plain %1".arg(AppFramework.clipboard.dataTypes.indexOf("text/plain") >= 0 ? "✅" : "")
            
            ColumnLayout {
                anchors.fill: parent
                Rectangle{
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.preferredHeight: 75 * scaleFactor
                    color: "transparent"
                    border.color: "black"
                    border.width: 1 * scaleFactor
                    TextArea {
                        id: textArea
                        Material.accent: "#8f499c"
                        padding: 5 * scaleFactor
                        wrapMode: Text.WrapAnywhere

                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        text: AppFramework.clipboard.text
                        readOnly: true


                    }
                }
            }
        }
        /*
        GroupBox {
            Layout.fillWidth: true
            Layout.fillHeight: true
            implicitWidth: parent.width
            
            title: "text/html %1".arg(AppFramework.clipboard.dataTypes.indexOf("text/html") >= 0 ? "✅" : "")
            
            ColumnLayout {
                anchors.fill: parent
                
                TextArea {
                    id: htmlTextArea
                    
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    wrapMode: Text.WrapAnywhere
                    text: AppFramework.clipboard.html
                    textFormat: Text.RichText
                    readOnly: true
                }
            }
        }
    */
    }
}
