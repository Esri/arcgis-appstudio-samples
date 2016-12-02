//------------------------------------------------------------------------------

import QtQuick 2.2
import QtQuick.Controls 1.1
import QtPositioning 5.2

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import ArcGIS.AppFramework.Runtime 1.0

App {
    id: app

    height: 640
    width: 950

    readonly property color hoverColor: "#e1f0fb"
    readonly property color pressedColor: "#90cdf2"
    readonly property color selectedColor: "#aadbfa"
    readonly property color darkTextColor: "#4c4c4c"
    readonly property color lightTextColor: "#f7f8f8"
    readonly property color featurePopupBackgroundColor: "seashell"

    readonly property int compactThreshold: 450
    readonly property bool compactLayout: width <= compactThreshold
    readonly property real sidePanelWidth: 300 * AppFramework.displayScaleFactor
    readonly property real sidePanelRatio: 0.4

    readonly property int identifyTolerance: 10

    readonly property bool singleMap: app.info.propertyValue("galleryMapsQuery", "").substr(0, 3) === "id:"

    property alias folder: appFolder

    property alias stackView: stackView

    readonly property bool hasDisclaimer: app.info.itemInfo.licenseInfo > ""


    //--------------------------------------------------------------------------

    Component.onCompleted: {
        //ArcGISRuntime.loggingEnabled = true;
        IdentityManager.ignoreSslErrors = true;
        console.log("path", app.info.path);
    }

    //--------------------------------------------------------------------------

    FileFolder {
        id: appFolder
        path: app.info.path
    }

    //--------------------------------------------------------------------------

    StackView {
        id: stackView

        anchors.fill: parent

        initialItem: startPage

        function showNext() {
            if (app.settings.boolValue("dontShowDisclaimer", false) || !hasDisclaimer) {
                showGallery();
            } else {
                push(disclaimerPage);
            }
        }

        function showGallery() {
            if (singleMap) {
                push(mapViewPage);
                currentItem.loadWebMap(app.info.propertyValue("galleryMapsQuery", "").substr(3));
            } else {
                push(mapsGalleryPage);
            }
        }

        function showMap(itemInfo) {
            push(mapViewPage);
            currentItem.loadWebMap(itemInfo.itemId);
        }
    }

    //--------------------------------------------------------------------------

    Component {
        id: startPage

        StartPage {
            onSignInClicked: {
                stackView.showNext();
//                myPortal.signIn();
            }

            onInfoClicked: {
                stackView.push(aboutPage);
            }
        }
    }

    //--------------------------------------------------------------------------

    Component {
        id: aboutPage

        AppAboutPage {
            stackView: app.stackView
        }
    }

    //--------------------------------------------------------------------------

    Component {
        id: disclaimerPage


        AppDisclaimerPage {
            stackView: app.stackView

            onContinueClicked: {
                stackView.pop();
                stackView.showGallery();
            }
        }
    }

    //--------------------------------------------------------------------------

    Component {
        id: mapsGalleryPage

        MapsGalleryPage {
            portal: myPortal

            onExitClicked: {
                myPortal.signOut();
                stackView.pop();
            }

            onMapSelected: {
                stackView.showMap(itemInfo);
            }
        }
    }

    //--------------------------------------------------------------------------

    Component {
        id: mapViewPage

        MapViewPage {
            portal: myPortal
            positionSource: myPositionSource

            onExit: {
                stackView.pop();
            }
        }
    }

    //--------------------------------------------------------------------------

    Portal {
        id: myPortal

        credentials: UserCredentials {
            userName: "arcpaddemo"
            password: "arcpaddemo"
        }

        onSignInComplete: {
            stackView.showGallery();
        }
    }

    //--------------------------------------------------------------------------

    FileFolder {
        id: mapsFolder

        path: "~/ArcGIS/MapViewer"
    }

    PositionSource {
        id: myPositionSource
        active: app.info.propertyValue("positionSourceActive", true);
    }

    //--------------------------------------------------------------------------
}

