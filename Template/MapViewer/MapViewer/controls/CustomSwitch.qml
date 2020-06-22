import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.1

import ArcGIS.AppFramework 1.0

Switch {
    id: root
    
    property real size: root.units(47)
    property real indicatorWidth: size
    property real indicatorHeight: 0.4 * indicatorWidth
    property real indicatorRadius: root.units(12)
    property color primaryColor: "steelBlue"
    property color backgroundColor: "#4C4C4C"
    
    
    Layout.alignment: Qt.AlignRight
    Layout.fillHeight: true
    
    indicator: Rectangle {
        implicitWidth: root.indicatorWidth
        implicitHeight: root.indicatorHeight
        x: root.leftPadding
        y: 0.5 * parent.height - 0.5 * height
        radius: root.indicatorRadius
        color: root.checked ? Qt.lighter(root.primaryColor, 2.2) : Qt.darker(root.backgroundColor, 1.2)
        border.color: root.checked ? Qt.lighter(root.primaryColor, 2.2) : Qt.darker(root.backgroundColor, 1.2)
        
        Rectangle {
            x: root.checked ? parent.width - width : 0
            Behavior on x {
                NumberAnimation {
                    duration: 100
                }
            }
            width: 1.5 * parent.implicitHeight
            height: width
            radius: 0.5 * width
            anchors.verticalCenter: parent.verticalCenter
            color: root.checked ? root.primaryColor: "#FFFFFF"
            border.color: root.checked ?  root.primaryColor : Qt.darker(root.backgroundColor, 1.2)
        }
    }

    function units (num) {
        return num ? num * AppFramework.displayScaleFactor : num
    }
}
