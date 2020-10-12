import QtQuick 2.13
import QtQuick.Layouts 1.13
import QtQuick.Controls 2.13
import QtQuick.Controls.Material 2.13

import ArcGIS.AppFramework 1.0

Item{

    property alias repeater: dbRepeater

    Flickable {

        anchors.fill: parent
        anchors.margins: 20
        contentHeight: column.height

        ColumnLayout {

            id: column
            width: parent.width
            spacing: 10

            AppButton {
                text: "Refresh database"
                onClicked: updateDBView()
                enabled: db.isOpen
            }

            AppTextBody {
                id: dbConnectionStatus
                Layout.fillWidth: true
                wrapMode: Text.Wrap
                text: db.isOpen ? qsTr("Connected to: %1").arg(db.databaseName) : "Not connected to any database"
            }

            Repeater {
                id: dbRepeater
                DatabaseObject {
                    fileID: FileID
                    fileName: FileName
                    fileSuffix: FileSuffix
                    fileSize: FileSize
                    fileData: FileData
                }
            }
        }
    }
}
