import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0

import "../Widgets"

ToolBar {
    id: navigatorFooter

    signal back()
    signal next()
    
    height: 56 * scaleFactor
    Material.primary: colors.primary_color
    Material.elevation: 4
    
    property bool isBackEnabled: true
    property bool isNextEnabled: false

    property alias text1: label1.text
    property alias text2: label2.text
    property alias icon1: icon1
    property alias icon2: icon2
    
    RowLayout {
        anchors.fill: parent
        spacing: 0
        
        Item {
            Layout.fillHeight: true
            Layout.preferredWidth: parent.width*0.4
            
            RowLayout {
                anchors.fill: parent
                spacing: 0
                
                Item {
                    Layout.fillHeight: true
                    Layout.preferredWidth: icon1.visible ? 16 * scaleFactor : 24 * scaleFactor
                }
                
                IconImage {
                    id: icon1
                    Layout.preferredWidth: 36 * scaleFactor
                    Layout.preferredHeight: 36 * scaleFactor
                    source: sources.arrow_left
                    color: navigatorFooter.isBackEnabled ? colors.white_100 : colors.white_54
                }
                
                Item {
                    Layout.fillHeight: true
                    Layout.preferredWidth: 8 * scaleFactor
                    visible: icon1.visible
                }
                
                Label {
                    id: label1
                    text: strings.back
                    font {
                        weight: Font.Medium
                        pixelSize: 14 * scaleFactor
                    }
                    color: navigatorFooter.isBackEnabled ? colors.white_100 : colors.white_54
                }
                
                Item {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                }
            }
            
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    back();
                }
            }
        }
        
        Item {
            Layout.fillHeight: true
            Layout.fillWidth: true
        }
        
        Item {
            Layout.fillHeight: true
            Layout.preferredWidth: parent.width*0.4
            
            RowLayout {
                anchors.fill: parent
                spacing: 0
                
                Item {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                }
                
                Label {
                    id: label2
                    text: strings.next
                    font {
                        weight: Font.Medium
                        pixelSize: 14 * scaleFactor
                    }
                    color: navigatorFooter.isNextEnabled ? colors.white_100 : colors.white_54
                }
                
                Item {
                    Layout.fillHeight: true
                    Layout.preferredWidth: 8 * scaleFactor
                    visible: icon2.visible
                }
                
                IconImage {
                    id: icon2
                    Layout.preferredWidth: 36 * scaleFactor
                    Layout.preferredHeight: 36 * scaleFactor
                    source: sources.arrow_right
                    color: colors.white_100
                    opacity: navigatorFooter.isNextEnabled ? 1 : 0.48
                }
                
                Item {
                    Layout.fillHeight: true
                    Layout.preferredWidth: icon2.visible ? 16 * scaleFactor : 24 * scaleFactor
                }
            }

            MouseArea{
                anchors.fill: parent
                enabled: isNextEnabled
                onClicked: {
                    next();
                }
            }
            
        }
    }
}
