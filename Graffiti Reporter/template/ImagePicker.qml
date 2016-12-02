import QtQuick 2.2
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import QtMultimedia 5.2
import Qt.labs.folderlistmodel 2.1
import QtQuick.Window 2.2

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import ArcGIS.AppFramework.Runtime 1.0

//Thanks to
//http://doc.qt.digia.com/qtquick-components-symbian-1.1/demos-symbian-musicplayer-qml-filepickerpage-qml.html

Item {

    id: photoPickerWindow

    width: parent.width
    height: parent.height

    z: 88

    property string title: "Select Photo"

    visible: false

    property string folderLocation: (function(){
        var location = "file:///";

        switch (Qt.platform.os) {
              case "ios":
                  //location = "file:///var/mobile/Media/DCIM/"
                  location = AppFramework.resolvedPathUrl("~/Pictures");
                  break;

              case "android":
                  location = "file:///storage/sdcard0/DCIM/"
                  break;

              default:
                  location = AppFramework.resolvedPathUrl("~/Pictures");
              }

        return location;
    })()

    signal select(string fileName)

    FolderListModel {
        id: photoPickerListModel
        //nameFilters: ["*.jpg","*.png"]
        nameFilters: ["*.jpg",".JPG"]
        showDotAndDotDot: true
        showOnlyReadable: true
        sortField: FolderListModel.Time
        //folder: "file://"
        folder: folderLocation
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            id: headerBar
            Layout.alignment: Qt.AlignTop
            Layout.fillHeight: true
            color: app.headerBackgroundColor
            Layout.preferredWidth: parent.width
            Layout.preferredHeight: 50 * app.scaleFactor

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    mouse.accepted = false
                }
            }

            Text {
                id: titleText
                text: title
                textFormat: Text.StyledText
                anchors.centerIn: parent
                //anchors.left: parent.left
                //anchors.verticalCenter: parent.verticalCenter
                font {
                    pointSize: app.baseFontSize * 1.1
                }
                color: app.headerTextColor
                maximumLineCount: 1
                elide: Text.ElideRight
                anchors.leftMargin: 10
            }

            ImageButton {
                source: "images/close.png"
                rotation: -90
                height: 30 * app.scaleFactor
                width: 30 * app.scaleFactor
                checkedColor : "transparent"
                pressedColor : "transparent"
                hoverColor : "transparent"
                glowColor : "transparent"
                anchors.rightMargin: 10
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                onClicked: {
                    photoPickerWindow.visible = false
                }
            }
        }

        Rectangle {
            Layout.alignment: Qt.AlignTop
            Layout.fillHeight: true
            color: app.pageBackgroundColor
            Layout.preferredWidth: parent.width
            Layout.preferredHeight: parent.height - headerBar.height

            ListView {
                id: folderListView

                anchors.fill: parent
                model: photoPickerListModel
                delegate: photoPickerDelegate
                cacheBuffer: height
                clip: true
                spacing: 10*app.scaleFactor

                header: Text {
                        text: "Showing pictures from: " + folderLocation.toString()
                        textFormat: Text.StyledText
                        //anchors.centerIn: parent
                        anchors.left: parent.left
                        anchors.right: parent.right
                        wrapMode: Text.Wrap
                        font {
                            pointSize: app.baseFontSize * 0.5
                        }
                        color: app.textColor
                        maximumLineCount: 3
                        elide: Text.ElideRight
                        anchors.margins: 10*app.scaleFactor
                    }
            }

            Component {
                id: photoPickerDelegate

                Item {
                    height: 75 * app.scaleFactor
                    width: folderListView.width

                    Rectangle {
                        width: 4
                        height: parent.height
                        color: "#2d2875"
                    }

                    Image {
                        id: folderIcon
                        height: parent.height
                        width: height
                        fillMode: Image.PreserveAspectCrop
                        anchors { left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: 10*app.scaleFactor}
                        source: photoPickerListModel.isFolder(index)? "images/folder.png" : (photoPickerListModel.folder + "/" + fileName)
                        //visible: photoPickerListModel.isFolder(index)
                    }

                    Text {
                        anchors {
                            left: folderIcon.right
                            right: parent.right
                            leftMargin: 5
                            verticalCenter: parent.verticalCenter
                        }
                        elide: Text.ElideRight
                        font {
                            pointSize: app.baseFontSize * 0.6
                        }
                        font.letterSpacing: -1
                        color: app.textColor
                        text: fileName
                    }

                    MouseArea {
                        anchors.fill: parent

                        onClicked: {
                            if (photoPickerListModel.isFolder(index)) {
                                if (fileName == "..")
                                    photoPickerListModel.folder = photoPickerListModel.parentFolder
                                else if (fileName == ".") {
                                    //do nothing
                                } else
                                    photoPickerListModel.folder += "/" + fileName
                            } else {
                                var file = photoPickerListModel.folder + "/" + fileName
                                console.log(file);
                                select(file);
                                photoPickerWindow.visible = false;
                            }
                        }
                    }
                }
            }
        }
    }
}
