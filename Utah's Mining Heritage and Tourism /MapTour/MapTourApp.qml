/* Copyright 2015 Esri
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

import QtQuick 2.2
import QtQuick.Controls 1.1
import QtPositioning 5.2
import QtGraphicalEffects 1.0
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.1

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Runtime 1.0

App {
    id: app
    width: 400
    height: 640

    Component.onCompleted: {
        ArcGISRuntime.loggingEnabled = false;
        IdentityManager.ignoreSslErrors = true;
    }

    property alias customTitleFont : customTitleFont
    property alias customTextFont : customTextFont

    property bool isOnline: AppFramework.network.isOnline

    property int scaleFactor : AppFramework.displayScaleFactor

    //property int baseFontSize : Math.min(20, 20 * scaleFactor)
    property int baseFontSize : app.info.propertyValue("baseFontSize", 20 * scaleFactor)

    property color valuehighlightColor: "#00ffffff"

    property color selectColor: "yellow"

    property bool isSmallScreen: false
    property bool isPortait: false
    property bool isSignedIn : false

    //***************** Config *************************

    property string galleryPageBackground : app.folder.fileUrl(app.info.propertyValue("galleryBackground","images/background3.jpg"));
    property string landingpageBackground : app.folder.fileUrl(app.info.propertyValue("startBackground","images/background1.jpg"));
    property string logoImage :  app.folder.fileUrl(app.info.propertyValue("logoImage","images/esrilogo.png"));
    property string loginImage : app.folder.fileUrl(app.info.propertyValue("startButton","images/signin.png"));
    property string logoUrl : app.info.propertyValue("logoUrl","http://www.esri.com");
    property bool doLogin : app.info.propertyValue("doLogin",false);
    property bool showDescriptionOnStartup : app.info.propertyValue("showDescriptionOnStartup",false);
    property bool showLogo : app.info.propertyValue("startShowLogo",true);
    property string customTitleFontTTF: app.info.propertyValue("customTitleFontTTF","");
    property string customTextFontTTF: app.info.propertyValue("customTextFontTTF","");
    property string portalQueryItemTypes: app.info.propertyValue("portalQueryItemTypes","type:\"Web Mapping Application\"")
    //portal
    property var orgId : app.info.propertyValue("orgId", null);
    property var queryString :app.info.propertyValue("queryString", null);

    property var sortOrder: app.info.propertyValue("portalSortOrder","desc");
    property var sortField: app.info.propertyValue("portalSortField","modified");
    //colors
    property color headerBackgroundColor: app.info.propertyValue("textBackgroundColor","#4c4c4c");
    property string textColor : app.info.propertyValue("textColor","white");
    property color titleColor: app.info.propertyValue("titleColor","black");
    property color subtitleColor: app.info.propertyValue("subtitleColor","#51010a");
    //maptour
    property bool autoCropImage: app.info.propertyValue("autoCropImage",true);
    property bool showGallery: app.info.propertyValue("showGallery",true);
    property var webmapid: app.info.propertyValue("webmapid","");
    property var tourLayerId: app.info.propertyValue("tourlayerId","");
    property var mapScale: app.info.propertyValue("mapScale","70000");
    property bool showBasemapSwitcher: app.info.propertyValue("showBasemapSwitcher",true);
    property string basemapUrl: app.info.propertyValue("basemapUrl","http://services.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer");

    //custom fields
    property string titleField: app.info.propertyValue("maptour_titleField","NAME");
    property string descField: app.info.propertyValue("maptour_descriptionField","CAPTION");
    property string thumbnailField: app.info.propertyValue("maptour_thumbnailField", "PIC_URL");
    property string imageField: app.info.propertyValue("maptour_imageField","THUMB_URL");
    property string iconColorField : app.info.propertyValue("maptour_iconColorField", "COLOR");
    property bool customRenderer : app.info.propertyValue("maptour_customRenderer",true);
    property bool customSort : app.info.propertyValue("maptour_customSort",false);
    property string customSortField: app.info.propertyValue("maptour_customSortField","NUMBER");
    property string customSortOrder: app.info.propertyValue("maptour_customSortOrder","asc");

    //custom font if any
    FontLoader {
        id: customTitleFont
        source: app.folder.fileUrl(customTitleFontTTF)
    }

    FontLoader {
        id: customTextFont
        source: app.folder.fileUrl(customTextFontTTF)
    }


    StackView {

        id: stackView

        anchors.fill: parent

        initialItem: landingPage

        function showGallery() {
            push(galleryPage);
        }

        function showTour(itemInfo) {
            stackView.push(tourPage);
            stackView.currentItem.loadTour(itemInfo);
        }

    }

    //--------------------------------------------------------------------------

    Component {
        id: landingPage

        LandingPage {

            onSignInClicked: {

                app.isSmallScreen = (parent.width || parent.height) < 400*app.scaleFactor
                app.isPortait = parent.height > parent.width

                console.log("##StartPage:: DisplayScaleFactor: ", scaleFactor, " isSmallScreen: ", isSmallScreen, " isPortarit: ", isPortait);

                if (portalSignInDialog.portal.signedIn || !app.doLogin) {
                    if(!app.showGallery) {
                        stackView.showTour(null);
                    } else {
                        stackView.showGallery();
                    }
                } else {
                    portalSignInDialog.visible = true;
                }
            }
        }
    }

    //--------------------------------------------------------------------------

    Component {
        id: galleryPage

        GalleryPage {
            portal: portalSignInDialog.portal

            onExitClicked: {
                portal.signOut();
                stackView.pop();
            }

            onTourSelected: {
                tourItemData.downloadTour(itemInfo);
            }
        }
    }

    //--------------------------------------------------------------------------
    Component {
        id: tourPage

        TourPage {
            portal: portalSignInDialog.portal

            onExit: {
                stackView.pop();
            }
        }
    }
    //--------------------------------------------------------------------------

    PortalSignInDialog {
        id: portalSignInDialog

        settingsGroup: "portal"

        portal: Portal {

            onSignInComplete: {
                isSignedIn = true;
                stackView.showGallery();
            }

            onSignInError: {
                isSignedIn = false
                console.log("***** siginin error event *****");
            }
        }

        onRejected: {
            console.log("****** signin on closed event *****");
            stackView.showGallery();
        }
    }

    // ----------------------------------


    PortalDownloadItemData {
        id: tourItemData

        property PortalItemInfo itemInfo

        portal: portalSignInDialog.portal

        function downloadTour(itemInfo) {
            console.log("Itemid: ", itemInfo.itemId);
            toursFolder.makePath(itemInfo.itemId);

            //tourItemData.responseFilename =  AppFramework.resolvedPathUrl(toursFolder.filePath(itemInfo.itemId + "/mapTourInfo.json"));
            //console.log("*** Sathya filepath : " , tourItemData.responseFilename);
            //workaround for the new bug - commenting the next line
            //tourItemData.responseFilename =  toursFolder.fileUrl(itemInfo.itemId + "/mapTourInfo.json");

            tourItemData.itemInfo = itemInfo;
            tourItemData.downloadItemData(itemInfo);
        }

        onRequestStatusChanged: {
            switch (requestStatus) {
            case Enums.PortalRequestStatusInProgress:
                break;

            case Enums.PortalRequestStatusCompleted:
                console.log(responseFilename);
                //stackView.showTour(itemInfo);
                //workaround for the new bug
                stackView.showTour(JSON.parse(tourItemData.responseText));
                break;

            case Enums.PortalRequestStatusErrored:
                console.log("requestError.code: ", requestError.code);
                console.log("requestError.message: ", requestError.message);
                console.log("requestError.details: ", requestError.details);
                break;
            }
        }

    }

    //--------------------------------------------------------------------------

    FileFolder {
        id: toursFolder
        path: "~/ArcGIS/MapTours2"
    }

}

