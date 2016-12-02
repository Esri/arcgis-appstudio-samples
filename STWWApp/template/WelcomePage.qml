import QtQuick 2.2
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import ArcGIS.AppFramework.Runtime 1.0

import QtQuick.LocalStorage 2.0
import "LocalStorage.js" as LocStor

Rectangle {
    id:page1Container
    width: parent.width
    height: parent.height
    color: app.pageBackgroundColor
    //color: "transparent"
    signal next(string message)
    signal previous(string message)

    Image{
        //anchors.fill: parent
        anchors.top: parent.top
        width: parent.width
        height: parent.height - linksContainer.height
        //anchors.bottom: linksContainer.top
        source: app.landingpageBackground
        fillMode: Image.PreserveAspectCrop
        //z:-1
    }

    Component.onCompleted: {
        //LocStor.dropTable("drafts")

        var count = LocStor.getCount("drafts");
        if(count && count> 0) {
            app.hasDrafts = true
        }
    }


    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            id: page1_headerBar
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
                visible: false
                onClicked: {
                    console.log("Back button from map page clicked")
                    previous("")
                }
            }

            Text {
                id: page1_titleText
                text: app.info.title
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
            color: "transparent"
            //color: app.pageBackgroundColor
            Layout.preferredWidth: parent.width
            Layout.preferredHeight: parent.height - page1_headerBar.height

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    mouse.accepted = false
                }
            }

            Flickable {
                //anchors.fill: parent
                width: parent.width
                height: parent.height
                contentHeight: parent.height + 30

                clip: true

                Item {
                    anchors.fill: parent

                    anchors.topMargin: page1_headerBar.height + 10;

                    Text {
                        id: page1_description
                        text: app.info.snippet
                        textFormat: Text.StyledText
                        horizontalAlignment: Text.AlignHCenter
                        anchors {
                            margins: 10*app.scaleFactor
                            left: parent.left
                            right: parent.right
                        }
                        font {
                            pointSize: app.baseFontSize * 0.9
                        }

                        color: app.textColor
                        wrapMode: Text.Wrap
                        linkColor: "#e5e6e7"
                        onLinkActivated: {
                            Qt.openUrlExternally(link);
                        }
                    }

                    Text {
                        id: page1_networkStatus
                        text:"(" + (AppFramework.network.isOnline?"Online":"Offline") + ")"
                        textFormat: Text.StyledText
                        horizontalAlignment: Text.AlignHCenter
                        anchors {
                            margins: 10
                            left: parent.left
                            right: parent.right
                            top: page1_description.bottom
                        }
                        font {
                            pointSize: app.baseFontSize * 0.6
                        }
                        color: app.textColor
                    }

                    CustomButton{
                        id:page1_button1
                        buttonText: "NEW REPORT"
                        buttonColor: AppFramework.network.isOnline ? app.buttonColor : app.headerBackgroundColor
                        buttonFill: AppFramework.network.isOnline
                        buttonWidth: 300 * app.scaleFactor
                        buttonHeight: buttonWidth/5
                        anchors {
                            left: parent.left
                            right: parent.right
                            top: page1_networkStatus.bottom
                            topMargin: 40*app.scaleFactor
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                next("createnew")
                                console.log("attacmentURL:", app.theFeatureAttachment.url )
                                skipPressed = false;
                            }
                        }
                    }

                    CustomButton{
                        id:page1_button2
                        visible: app.hasDrafts
                        buttonText: "SAVED DRAFTS"
                        buttonFill: AppFramework.network.isOnline
                        buttonColor: AppFramework.network.isOnline ? app.buttonColor : app.headerBackgroundColor
                        buttonWidth: 300 * app.scaleFactor
                        buttonHeight: buttonWidth/5
                        anchors {
                            left: parent.left
                            right: parent.right
                            top: page1_button1.bottom
                            topMargin: 20*app.scaleFactor
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                next("drafts")
                            }
                        }
                    }

                    CustomButton{
                        id:page1_button3                        
                        visible: false
                        buttonText: "VIEW MY REPORTS"
                        buttonColor: app.buttonColor
                        buttonWidth: 300 * app.scaleFactor
                        buttonHeight: buttonWidth/5
                        anchors {
                            left: parent.left
                            right: parent.right
                            top: page1_button2.bottom
                            topMargin: 20*app.scaleFactor
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                next("viewmap")
                            }
                        }
                    }

                    GridView {
                        visible: false
                        width: parent.width; height: 240
                        cellWidth: 150; cellHeight: 120
                        clip:true
                        anchors.top: page1_button1.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                        model: ListModel {
                            ListElement {
                                    name: "Email Us"
                                    icon: "images/camera_icon.png"
                                }
                                ListElement {
                                    name: "Call Us"
                                    icon: "images/camera_icon.png"
                                }
                                ListElement {
                                    name: "View Results"
                                    icon: "images/camera_icon.png"
                                }
                                ListElement {
                                    name: "Follow Us"
                                    icon: "images/camera_icon.png"
                                }
                        }
                        delegate: Column {
                            Image { source: icon; width:80; height:80; anchors.horizontalCenter: parent.horizontalCenter }
                            Text { text: name; anchors.horizontalCenter: parent.horizontalCenter }
                        }

                    }
                }
            }
        }

        Rectangle {
            id: linksContainer
            //height: 40 * app.scaleFactor
            height: links.contentHeight + 10*app.scaleFactor
            width: Math.min(400*app.scaleFactor,parent.width)
            color: app.pageBackgroundColor
            anchors {
                bottom: parent.bottom
                //left: parent.left
                //right: parent.right
                horizontalCenter: parent.horizontalCenter
            }

            Text {
                id: links
                text: ""
                anchors.centerIn: parent
                anchors.fill: parent
                anchors.margins: 8*app.scaleFactor
                fontSizeMode: Text.HorizontalFit
                maximumLineCount: 1
                //elide: Text.ElideNone
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                textFormat: Text.StyledText
                wrapMode: Text.Wrap
                color: app.textColor
                onLinkActivated: {
                    Qt.openUrlExternally(link);
                }
//                font {
//                    pointSize: app.baseFontSize * 0.6
//                }

                Component.onCompleted: {
                    var str = [];
                    if(app.phoneNumber.length>1)
                        str.push("<a href='tel:" + app.phoneNumber +"'>" + app.phoneLabel + "</a>");
                    if(app.websiteUrl.length>1)
                        str.push("<a href='" + app.websiteUrl +"'>" + app.websiteLabel + "</a>");
                    if(app.emailAddress.length>1)
                        str.push("<a href='mailto:" + app.emailAddress +"'>" + app.emailLabel + "</a>");
                    if(app.socialMediaUrl.length>1)
                        str.push("<a href='" + app.socialMediaUrl +"'>" + app.socialMediaLabel + "</a>");

                    text = str.join(" | ");
                }
            }


            Flow {
                visible: false
                anchors {
                    fill: parent
                    topMargin: 10*app.scaleFactor
                    bottomMargin: 5*app.scaleFactor
                    leftMargin: 5*app.scaleFactor
                    rightMargin: 5*app.scaleFactor
                    verticalCenter: parent.verticalCenter
                    horizontalCenter: parent.horizontalCenter
                }

                width: parent.width

                spacing: 10*app.scaleFactor

                Text {
                    id: page1_phone
                    //width: parent.width*0.33
                    visible: app.phoneNumber.length>1?true:false
                    text: "<a href='tel:" + app.phoneNumber +"'>Call Us</a> | "
                    textFormat: Text.StyledText
                    linkColor: app.headerBackgroundColor
                    onLinkActivated: {
                        Qt.openUrlExternally(link);
                    }
                    font {
                        pointSize: app.baseFontSize * 0.7
                    }
                    color: app.textColor
                }

                Text {
                    id: page1_website
                    //width: parent.width*0.33
                    visible: (app.websiteUrl.length>1?true:false) && AppFramework.network.isOnline
                    text: "<a href='" + app.websiteUrl +"'>View All Reports</a> | "
                    textFormat: Text.StyledText
                    linkColor: app.headerBackgroundColor
                    onLinkActivated: {
                        Qt.openUrlExternally(link);
                    }
                    font {
                        pointSize: app.baseFontSize * 0.7
                    }
                    color: app.textColor
                }


                Text {
                    id: page1_email
                    //width: parent.width*0.33
                    visible: app.emailAddress.length>1?true:false
                    text: " <a href='mailto:" + app.emailAddress +"'>Email Us</a> |"
                    textFormat: Text.StyledText
                    linkColor: app.headerBackgroundColor
                    onLinkActivated: {
                        Qt.openUrlExternally(link);
                    }
                    font {
                        pointSize: app.baseFontSize * 0.7
                    }
                    color: app.textColor
                }


                Text {
                    id: page1_twitter
                    visible: (app.socialMediaUrl.length>1?true:false) && AppFramework.network.isOnline
                    text: " <a href='" + app.socialMediaUrl +"'>Follow Us</a>"
                    textFormat: Text.StyledText
                    linkColor: app.headerBackgroundColor
                    onLinkActivated: {
                        Qt.openUrlExternally(link);
                    }
                    font {
                        pointSize: app.baseFontSize * 0.7
                    }
                    color: app.textColor
                }
            }
        }

    }

}

