import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtGraphicalEffects 1.0
import QtQuick.Controls.Material 2.1
import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0

ToolButton {
    id: button

    property url imageSource
    property color overlayColor: app.primaryColor
    property color borderColor: overlayColor
    property bool isFilled: false
    property string title: ""

    contentItem: RowLayout {
        anchors.margins: 4 * app.scaleFactor
        anchors.centerIn: parent

        Item {
            Layout.preferredHeight: 20 * app.scaleFactor
            Layout.preferredWidth: 20 * app.scaleFactor

            Image{
                id: image

                anchors.fill: parent
                source: imageSource
                fillMode: Image.PreserveAspectFit
                asynchronous: true
            }

            ColorOverlay{
                id: colorOverlay
                anchors.fill: image
                source: image
                color: isFilled? app.secondaryColor: app.primaryColor
            }
        }

        Label {
            id: titleText

            text: title
            Layout.fillWidth: true
            elide: Label.ElideRight
            font.pixelSize: 13 * app.scaleFactor
            color: isFilled? app.secondaryColor: app.textColor
            Layout.alignment: Qt.AlignVCenter
        }
    }

    background: Rectangle {
        implicitWidth: button.width
        implicitHeight: button.height
        border.color: isFilled? colors.primaryColor: colors.btnBorderColor
        color: isFilled? app.primaryColor: app.secondaryColor
        border.width: 1 * app.scaleFactor
        radius: button.height / 2
    }
}
