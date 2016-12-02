import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.1

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import ArcGIS.AppFramework.Runtime 1.0

ContentBlock {
    property real displayScaleFactor : AppFramework.displayScaleFactor

    property real panelInitialDimension: 15 * displayScaleFactor
    property real panelMaxDimension: (app.width * 0.7) * displayScaleFactor
    property bool isPanelMinimised: true

    property real itemRotation : app.isLandscape ? LayoutMirroring.enabled ? 180 : 0 :  90

    Layout.fillHeight: app.isLandscape
    Layout.fillWidth: !app.isLandscape
    Layout.preferredWidth: isPanelMinimised ? panelInitialDimension : panelMaxDimension
    Layout.preferredHeight: isPanelMinimised ? panelInitialDimension : panelMaxDimension

    GridLayout {
        anchors.fill: parent
        columns: app.isLandscape ? 2 : 1
        rows: app.isLandscape ? 1 : 2

        Image {
            source: "../arrow.png"
            fillMode: Image.PreserveAspectFit
            Layout.preferredWidth: panelInitialDimension
            Layout.preferredHeight: panelInitialDimension
            Layout.fillHeight: app.isLandscape
            Layout.fillWidth: !app.isLandscape
            Layout.alignment: Qt.AlignCenter

            rotation: itemRotation
            mirror: !isPanelMinimised

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    console.log("pressed");
                    isPanelMinimised = !isPanelMinimised;
                }
            }
        }

        ContentBlock {
        }
    }

    Component.onCompleted: console.log("mirrored", LayoutMirroring.enabled)
}

