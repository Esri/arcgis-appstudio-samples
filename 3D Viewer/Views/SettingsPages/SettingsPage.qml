import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2

Page {
    id: settingsPage

    header: ToolBar {
        height: 56 * constants.scaleFactor
        Material.primary: colors.black
        Material.elevation: 0

        RowLayout {
            anchors.fill: parent
            spacing: 0

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                Label {
                    anchors.fill: parent

                    text: strings.app_settings
                    color: colors.white
                    font.family: fonts.avenirNextDemi
                    font.pixelSize: 20 * constants.scaleFactor
                    elide: Text.ElideRight
                    clip: true

                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter

                    leftPadding: 16 * constants.scaleFactor
                    rightPadding: 16 * constants.scaleFactor
                }
            }
        }
    }
}
