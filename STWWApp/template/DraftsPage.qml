import QtQuick 2.2
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import ArcGIS.AppFramework.Runtime 1.0

import QtQuick.LocalStorage 2.0
import "LocalStorage.js" as LocStor

Rectangle {
    width: parent.width
    height: parent.height
    color: app.pageBackgroundColor
    signal next(string message)
    signal previous(string message)

    property int draftsCount: 0
    property bool isBusy: false

    ListModel {
        id: draftsModel
    }

    function submitDraft(id) {
        console.log("SubmitDraft:: Got id: ", id);
        var item_string = LocStor.get("drafts", id, null);
        console.log(item_string);
    }

    function deleteDraft(id) {
        isBusy = true;
        console.log("DeleteDraft:: Got id: ", id);

        var modelData = draftsModel.get(id);
        console.log(modelData.id);

        var itemId = modelData.id;

        var item_string = LocStor.get("drafts", itemId, null);
        console.log("SQL data to remove: ", item_string);
        if(item_string) {
            var result = LocStor.remove("drafts",itemId);
            console.log(result)
            isBusy = false
            initializeDraftsModel();
        }

        isBusy = false

    }

    function initializeDraftsModel(){
        isBusy = true;
        draftsModel.clear()

        draftsCount = 0

        var count = LocStor.getCount("drafts");
        console.log("#Items in database: ", count);

        if(count && parseInt(count)> 0) {
            draftsCount = parseInt(count)
        } else {
            app.hasDrafts = false
        }


        var results = LocStor.getAll("drafts");
        console.log(results);


        for(var i=0; i<results.length; i++) {
            var item_string = results[i];
            console.log("Got: ", i, item_string);

            if(item_string) {
                var item_append = {"id":-1,"created":"Bad Date","imageUrl":"","description":"Bad Data","attributes":""}
                var item_json = JSON.parse(item_string);
                if(item_json.created) {
                    item_append.id = item_json.created
                    item_append.created = new Date(item_json.created).toLocaleDateString()
                }
                if(item_json.imageFilePath) {
                    item_append.imageUrl = item_json.imageFilePath
                }

                if(item_json.description) {
                    item_append.description = item_json.description
                }

                draftsModel.append(item_append);
            }

        }

        isBusy = false;

        //draftsModel.append({"imageUrl":"","description": "Some tessadjsadjh ajkd ajdjad ajsdhsadashd asd jad kjasdhad kajd ad jkadjadhjahd jkajkdh ajkdjkad", "created": new Date().toDateString()})

    }

    Component.onCompleted: {

        initializeDraftsModel();
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            id: draftsPage_headerBar
            Layout.alignment: Qt.AlignTop
            //Layout.fillHeight: true
            color: app.headerBackgroundColor
            Layout.preferredWidth: parent.width
            Layout.preferredHeight: 50 * app.scaleFactor

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    mouse.accepted = false
                }
            }

            ImageButton {
                source: "images/back-left.png"
                height: 30 * app.scaleFactor
                width: 30 * app.scaleFactor
                checkedColor : "transparent"
                pressedColor : "transparent"
                hoverColor : "transparent"
                glowColor : "transparent"
                anchors.rightMargin: 10
                anchors.leftMargin: 10
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                onClicked: {
                    console.log("Back button from drafts page clicked")
                    previous("")
                }
            }

            Text {
                id: draftsPage_titleText
                text: "Saved Drafts"
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
                //anchors.leftMargin: 10
            }
        }

        Rectangle {
            Layout.alignment: Qt.AlignTop
            Layout.fillHeight: true
            //color: app.pageBackgroundColor
            Layout.preferredWidth: parent.width
            Layout.preferredHeight: parent.height - draftsPage_headerBar.height
            BusyIndicator {
                z:11
                visible: isBusy
                anchors.centerIn: parent
            }

            Text {
                visible: draftsModel.count < 1
                text: "No saved drafts to show!"
                textFormat: Text.StyledText
                anchors.centerIn: parent
                font {
                    pointSize: app.baseFontSize * 1.1
                }
                color: app.textColor
            }

            ListView {
                id: draftsListView
                visible: draftsModel.count > 0
                clip: true
                spacing: 8*app.scaleFactor
                width: parent.width
                height: parent.height
                //anchors.margins: 5*app.scaleFactor
                anchors.topMargin: 20*app.scaleFactor
                anchors.bottomMargin: 30*app.scaleFactor
                //anchors.fill: parent
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                orientation: ListView.Vertical
                model: draftsModel
                focus: true
                currentIndex: -1

                header: Text {
                    text: "Click Report to Edit or Delete"
                    height: 50*app.scaleFactor
                    textFormat: Text.StyledText
                    anchors.horizontalCenter: parent.horizontalCenter
                    //anchors.verticalCenter: parent.verticalCenter
                    anchors.topMargin: 20*app.scaleFactor
                    anchors.bottomMargin: 20*app.scaleFactor
                    font {
                        pointSize: app.baseFontSize * 0.9
                    }
                    color: app.textColor
                    maximumLineCount: 1
                    elide: Text.ElideRight
                }

                delegate: Component {

                    Rectangle{
                        id: draftItemContainer
                        width: parent.width
                        height: 100*app.scaleFactor
                        color: app.pageBackgroundColor
                        anchors.margins: 10*app.scaleFactor
                        anchors.horizontalCenter: parent.horizontalCenter



                        MouseArea {
                            anchors.fill: parent

                            onClicked: {
                                console.log("Item clicked ", index);
                                draftsListView.currentIndex = index;
                                optionButtons.visible = !optionButtons.visible
                            }
                        }

                        Image{
                            id: thumbnailImage
                            source: imageUrl
                            width : parent.height
                            height: width
                            anchors.leftMargin: 5*app.scaleFactor
                            fillMode: Image.PreserveAspectCrop
                            onStatusChanged: if (status == Image.Error) source = "images/item_thumbnail_square.png"


                            Rectangle {

                                id: optionButtons
                                //border.width: 2
                                width: parent.width*0.9
                                height: parent.height*0.9
                                anchors.centerIn: parent
                                color: "transparent"
                                visible: false
                                //anchors.verticalCenter: parent.verticalCenter

                                CustomButton {
                                    id: deleteButton
                                    buttonText: "Delete"
                                    buttonWidth: parent.width
                                    buttonHeight: parent.height/2
                                    buttonBorderRadius: 0
                                    buttonColor: "red"
                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: {
                                            console.log("Delete button clicked for item ", index, draftsListView.currentIndex)
                                            console.log(draftsListView.currentItem)
                                            deleteDraft(draftsListView.currentIndex)
                                        }
                                    }
                                }

                                CustomButton {
                                    id: editButton
                                    buttonText: "Edit"
                                    //visible: AppFramework.network.isOnline
                                    buttonBorderRadius: 0
                                    buttonWidth: parent.width
                                    buttonHeight: parent.height/2
                                    buttonColor: app.buttonColor
                                    anchors.topMargin: 2*app.scaleFactor
                                    anchors.top: deleteButton.bottom
                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: {
                                            submitDraft(draftsListView.currentIndex)
                                        }
                                    }
                                }
                            }
                        }
                        Text {
                            text: created + "<br><br>" + description
                            anchors.top: parent.top
                            anchors.left: thumbnailImage.right
                            anchors.right: parent.right
                            anchors.margins: 10*app.scaleFactor
                            wrapMode: Text.Wrap
                            font {
                                pointSize: app.baseFontSize * 0.7
                            }
                            maximumLineCount: 5
                            elide: Text.ElideRight
                            color: app.textColor
                        }

                    }
                }
            }
        }
    }
}
