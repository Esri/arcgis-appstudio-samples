import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.12
import QtQuick.Dialogs 1.3
import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Platform 1.0

Frame {

    id: dbObj
    property string fileID
    property string fileName
    property string fileSuffix
    property int fileSize
    property var fileData

    contentWidth: columnLayout.width
    contentHeight: columnLayout.height
    width: parent.width

    ColumnLayout {

        id: columnLayout
        width: parent.width
        clip: true
        spacing: 5

        AppTextBody {
            text: qsTr("ID: %1").arg(dbObj.fileID)
        }

        AppTextBody {
            text: qsTr("File name: %1").arg(dbObj.fileName)
        }

        AppTextBody {
            text: qsTr("File suffix: %1").arg(dbObj.fileSuffix)
        }

        AppTextBody {
            text: qsTr("File size: %1").arg(dbObj.fileData.byteLength)
        }

        RowFlow {
            leftItem: AppButton {
                text: "Write to file"
                onClicked: {
                    writeToFileColumn.visible = !writeToFileColumn.visible
                }
            }

            rightItem: AppButton {
                text: "Delete"
                onClicked: {
                    confirmDeleteDialog.open()
                }
            }
        }

        // Since FileFolder.writeFile() is not working properly on Android at the moment,
        // Android specific implementation is used in the below section.
        ColumnLayout {
            id: writeToFileColumn
            visible: false
            width: parent.width

            AppTextHeading {
                visible: AppFramework.osName !== "Android"
                text: "Target file name"
            }

            TextField {
                visible: AppFramework.osName !== "Android"
                id: fileNameInput
                width: parent.width * 0.8
                text: dbObj.fileName
                Layout.fillWidth: true
            }

            AppTextHeading {
                text: AppFramework.osName === "Android" ? "Target file" : "Target folder"
            }

            Text {
                id: selectedFolderText
                Layout.fillWidth: true
                wrapMode: Text.Wrap
            }

            RowFlow {
                leftItem: AppButton {
                    text: AppFramework.osName === "Android" ? "Create file" : "Select folder"
                    onClicked: {
                        // On Android, open the DocumentDialog to create a new file instead of selecting a folder
                        if (AppFramework.osName === "Android") {
                            selectFolderDialog.selectFolder = false;
                            selectFolderDialog.selectExisting = false;
                        }
                        // On non Android platforms, open the DocumentDialog to select a folder to write the new file
                        selectFolderDialog.open()
                    }
                }
                rightItem: AppButton {
                    text: "Write"
                    onClicked: {
                        if (selectFolderDialog.fileUrl == "") {
                            warningDialog.open()
                        } else {
                            // On Android, write the data to a new file by passing the url of the newly created file to File component
                            // and using File.write()
                            if (AppFramework.osName === "Android") {
                                let newFile = AppFramework.file(selectFolderDialog.fileUrl);
                                newFile.open(File.OpenModeWriteOnly);
                                newFile.write(dbObj.fileData);
                                newFile.close();
                            }
                            // On non Android platform, write the data to a new file by using FileFolder.writeFile()
                            else {
                                writeDataToFile(dbObj.fileData, fileNameInput.text, selectFolderDialog.fileUrl);
                            }

                        }
                    }
                }
            }
        }
    }

    DocumentDialog {
        id: selectFolderDialog
        selectFolder: true
        onAccepted: {
            selectedFolderText.text = selectFolderDialog.fileUrl
        }
    }

    AppDialog {
        id: warningDialog
        width: app.width - 20
        standardButtons: Dialog.Ok
        textBody: AppFramework.osName === "Android" ? "Please create a new file" : "Please select a folder"
    }

    AppDialog {
        id: confirmDeleteDialog
        width: app.width - 20
        standardButtons: Dialog.Ok | Dialog.Cancel
        textBody: "Delete this file from the database?"

        onAccepted: {
            dbDeleteFile(db, dbObj.fileID)
            updateDBView()
        }
    }

    function writeDataToFile(fileData, newFileName, newFileFolderPath) {
        let newFileFolder = AppFramework.fileFolder(newFileFolderPath);
        newFileFolder.writeFile(newFileName, fileData);
    }

}
