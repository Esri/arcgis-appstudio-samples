import QtQuick 2.2
import QtQuick.Controls 1.1
import QtQuick.Dialogs 1.2


import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import ArcGIS.AppFramework.Runtime 1.0

Image {
    signal signInClicked()

    //source: app.landingpageBackground
    source: app.folder.fileUrl(app.info.propertyValue("startBackground", "assets/startBackground.png"))
    fillMode: Image.PreserveAspectCrop

    //    Rectangle {
    //        anchors.fill: parent
    //        gradient: Gradient {
    //            GradientStop { position: 1.0; color: "#11000000";}
    //            GradientStop { position: 0.0; color: "#10000000";}
    //        }
    //    }

    Image {
        id: appLogoImage
        source: app.folder.fileUrl(app.info.propertyValue("logoImage", "template/images/esrilogo.png"))
        width: 140*app.scaleFactor
        fillMode: Image.PreserveAspectFit
        anchors {
            top: parent.top
            topMargin: 30*app.scaleFactor
            horizontalCenter: parent.horizontalCenter
        }
        //visible:false
    }

    Text {
        id: titleText

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            topMargin: 130*app.scaleFactor
        }

        text: app.info.title
        fontSizeMode: Text.Fit

        font {
            //pointSize: app.baseFontSize * 1.9
            pointSize: app.baseFontSize * app.titleFontScale

        }
        color: app.titleColor
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.Wrap
    }

    Text {
        id: subtitleText
        anchors {
            left: parent.left
            right: parent.right
            top: titleText.bottom
            topMargin: 30
        }

        text: app.info.snippet
        font {
            pointSize: app.baseFontSize * app.subTitleFontScale
        }
        color: app.subtitleColor
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.Wrap
    }

    Image {
        id: testimage
        source: app.loginImage
        visible: false
    }

    ImageButton {
        id: signInButton

        anchors {
            horizontalCenter: parent.horizontalCenter
            top: subtitleText.bottom
            topMargin: 40
        }

        checkedColor : "transparent"
        pressedColor : "transparent"
        hoverColor : "transparent"
        glowColor : "transparent"

        enabled: AppFramework.network.isOnline
        visible: featureServiceInfoComplete

        width: Math.min(testimage.sourceSize.width, 250) * app.scaleFactor
        height: Math.min(testimage.sourceSize.height, 125) * app.scaleFactor
        //source: app.loginImage
        source: app.folder.fileUrl(app.info.propertyValue("signInImage", "images/signin.png"))

        onClicked: {
                signInClicked();
        }

    }

    BusyIndicator {
        id: busyIndicator
        running: !featureServiceInfoComplete
        visible: running
        anchors.centerIn: signInButton
    }


    AlertBox {
        id: alertBox
            visible: !AppFramework.network.isOnline
            text: "Network not available. Turn off airplane mode or use wifi to access data."
        }

//    BusyIndicator {
//        id: busyIndicator

//        anchors.centerIn: signInButton
//        running: serviceInfoTask.featureServiceInfoStatus == Enums.FeatureServiceInfoStatusCompleted ? false : true
//    }

    Image {
        id: testimage2
        source: app.logoImage
        visible: false
    }


//    ImageButton {
//        id: logoButton

//        anchors {
//            left: parent.left
//            bottom: parent.bottom
//            margins: 10*app.scaleFactor
//        }

//        checkedColor : "transparent"
//        pressedColor : "transparent"
//        hoverColor : "transparent"
//        glowColor : "transparent"


//        width: Math.min(testimage2.sourceSize.width, 100) * app.scaleFactor
//        height: Math.min(testimage2.sourceSize.height, 80) * app.scaleFactor

//        source: app.logoImage
//        visible: app.startShowLogo

//        onClicked: {
//            Qt.openUrlExternally(app.logoUrl);
//        }
//    }

    ImageButton {

        anchors {
            right: parent.right
            bottom: parent.bottom
            margins: 10*app.scaleFactor
        }

        checkedColor : "transparent"
        pressedColor : "transparent"
        hoverColor : "transparent"
        glowColor : "transparent"

        height: 30 * app.scaleFactor
        width: 30 * app.scaleFactor

        source: "images/info.png"

        visible: app.showDescriptionOnStartup

        onClicked: {
            var html = app.info.description;
            if(app.info.accessInformation) {
                html+= "<br><br><b>Access Information:</b><br>" + app.info.accessInformation
            }

            html+= "<br><br><b>About the App:</b><br>" + "This app was built using the new AppStudio for ArcGIS. Mapping API provided by Esri.";

            aboutModalWindow.title = "About"
            aboutModalWindow.description = html
            aboutModalWindow.visible = true


        }

    }

    ModalWindow {
        id: aboutModalWindow
    }

    MessageDialog {
        id: aboutDialog
        onAccepted: {
            console.log("And of course you could only agree.")
        }
    }
}
