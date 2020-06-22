import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.12

import Esri.ArcGISRuntime 100.7

import "../controls" as Controls

ListView {
    id: legendView

    anchors.fill:parent
    footer:Rectangle{
        height:100 * scaleFactor
        width:legendView.width
        color:"transparent"
    }

    clip: true

    delegate: LegendDelegate {
        showLegend: true
    }

    section {
        property: "displayName"
        delegate: Label {
            leftPadding: units(16)
            rightPadding: leftPadding
            topPadding:units(16)
            width: parent.width
            text: section
            wrapMode: Label.Wrap
            clip: true
        }
    }

    Controls.BaseText {
        id: message

        visible: model.count <= 0 && text > ""
        maximumLineCount: 5
        elide: Text.ElideRight
        width: parent.width
        height: parent.height
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        text: qsTr("There are no legends to show.")
    }
}
