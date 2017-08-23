import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import QtLocation 5.3
import QtPositioning 5.3
import QtQuick.Controls.Material 2.1

import ArcGIS.AppFramework 1.0

Page {
    id: mapactions

    anchors.fill: parent
    header: ToolBar{
        id:header
        width: parent.width
        height: 50 * scaleFactor
        Material.background: "#8f499c"
        HeaderBar{}
    }
    ImageObject {
        id: imageObject
    }

    ColumnLayout {
        anchors {
            fill: parent
            margins: 5 * AppFramework.displayScaleFactor
        }
        
        Image {
            Layout.fillWidth: true
            Layout.fillHeight: true
            
            fillMode: Image.PreserveAspectFit
            source: imageObject.url
            horizontalAlignment: Image.AlignHCenter
            verticalAlignment: Image.AlignVCenter
            cache: false
            
            Rectangle {
                anchors {
                    fill: parent
                    margins: -1
                }
                
                color: "transparent"
                border {
                    width: 1
                    color: "black"
                }
            }
        }
        
        Text {
            Layout.fillWidth: true
            
            visible: !imageObject.empty
            text: "%1 x %2".arg(imageObject.width).arg(imageObject.height)
        }
        
        Flow {
            Layout.fillWidth: true
            
            Button {
                text: "Clear Image"
                enabled: !imageObject.empty
                
                onClicked: {
                    imageObject.clear();
                }
            }
            
            Button {
                text: "Copy"
                enabled: !imageObject.empty
                
                onClicked: {
                    imageObject.copyToClipboard();
                }
            }
            
            Button {
                text: "Paste"
                enabled: imageObject.canPasteFromClipboard
                
                onClicked: {
                    imageObject.pasteFromClipboard();
                }
            }
        }
    }
}
