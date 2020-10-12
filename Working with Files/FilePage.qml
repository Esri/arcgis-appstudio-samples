import QtQuick 2.13
import QtQuick.Layouts 1.13
import QtQuick.Controls 2.13
import QtQuick.Controls.Material 2.13

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Platform 1.0

Item{
    Flickable {

        anchors.fill: parent
        anchors.margins: 20
        contentHeight: column.height

        ColumnLayout {

            id: column
            width: parent.width
            spacing: 10

            AppButton {
                text: "Select File"

                onClicked: {
                    documentDialog.open()
                }
            }

            Frame {
                id: fileFrame
                contentWidth: columnLayout.width
                width: parent.width
                visible: false

                ColumnLayout {

                    id: columnLayout
                    width: parent.width

                    spacing: 5

                    AppTextHeading { text: "FileName" }
                    AppTextBody { id: fileNameText }

                    AppTextHeading { text: "FileUrl" }
                    AppTextBody { id: fileUrlText }

                    AppTextHeading { text: "FilePath" }
                    AppTextBody { id: filePathText }

                    AppTextHeading { text: "Size" }
                    AppTextBody { id: fileSizeText }

                    RowFlow {
                        leftItem: AppButton {
                            text: "Save to database"
                            enabled: db.isOpen
                            onClicked: {
                                if (file.exists) {
                                    file.open(File.OpenModeReadOnly);
                                    let fileData = file.readAll();
                                    dbInsertFile(db, fileInfo.fileName, fileInfo.suffix, fileInfo.size, fileData);
                                    file.close();
                                    updateDBView();
                                } else {
                                    warningDialog.open();
                                }
                            }
                        }
                        rightItem: AppButton {
                            text: "View file externally"
                            onClicked: {
                                if (file.exists) {
                                    AppFramework.openUrlExternally(file.url);
                                } else {
                                    warningDialog.open();
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    DocumentDialog {
        id: documentDialog

        onAccepted: {
            load_selected_file(documentDialog.fileUrl)
            fileFrame.visible = true;
        }
    }

    File {
         id: file
    }

    FileInfo {
        id: fileInfo
    }

    AppDialog {
        id: warningDialog
        width: app.width - 20
        standardButtons: Dialog.Ok
        textBody: "The file URL is invalid or has expired. Please select the file again."
    }

    function load_selected_file (fileUrl) {

        file.url = fileUrl;
        fileInfo.url = fileUrl;

        fileNameText.text = fileInfo.fileName;
        fileUrlText.text = fileInfo.url;
        filePathText.text = fileInfo.filePath;
        fileSizeText.text = fileInfo.size ;
    }
}
