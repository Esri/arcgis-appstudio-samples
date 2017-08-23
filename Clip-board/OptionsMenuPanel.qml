import QtQuick 2.7
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1

import ArcGIS.AppFramework 1.0

Popup{
    id:pane

    width: 150*app.scaleFactor
    height: implicitHeight
    visible: false
    padding: 0

    Material.elevation: 2
    Material.background: app.appDialogColor

    closePolicy: Popup.CloseOnPressOutside

    ColumnLayout{
        width:parent.width
        spacing: 0 * app.scaleFactor

        Item{
            Layout.fillWidth: true
            Layout.preferredHeight: 4*app.scaleFactor
        }

        Repeater{
            id:repeater
            model: 3
            delegate: Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 48* app.scaleFactor

                Label{
                    anchors.fill: parent                    
                    font.pixelSize: app.captionFontSize
                    text: qsTr("Option ") + (index + 1)
                    leftPadding: 16*app.scaleFactor
                    verticalAlignment: Label.AlignVCenter
                    color: app.appPrimaryTextColor
                    opacity: 0.87

                    Material.theme: app.lightTheme ? Material.Light : Material.Dark
                }

                Ink {
                    propagateComposedEvents: false
                    preventStealing: false
                    anchors.centerIn: parent
                    enabled: true
                    centered: true
                    circular: true
                    hoverEnabled: true
                    color: app.listViewDividerColor
                    anchors.fill: parent
                    onClicked: {
                        console.log("Item clicked");
                        pane.close();
                    }
                }
            }
        }

        Item{
            Layout.fillWidth: true
            Layout.preferredHeight: 4*app.scaleFactor
        }
    }

    function toggle(){
        pane.open();
    }
}


