//------------------------------------------------------------------------------
// vgi.qml
// Created 2014-11-03 10:06:49
//------------------------------------------------------------------------------

import QtQuick 2.2
import QtQuick.Controls 1.1

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import ArcGIS.AppFramework.Runtime.Dialogs 1.0
import ArcGIS.AppFramework.Runtime 1.0

import "LocalStorage.js" as LocalStorage

App {
    id: app
    width: 320
    height: 450

    property int scaleFactor : AppFramework.displayScaleFactor
    //property int baseFontSize : Math.min(20, 20 * scaleFactor)
    property int baseFontSize : Math.min(app.info.propertyValue("baseFontValue", 20), 20 * scaleFactor)
    property int titleFontScale: app.info.propertyValue("titleFontScale", 1.9)
    property int subTitleFontScale: app.info.propertyValue("subTitleFontScale", 0.7)

    property bool isSmallScreen: false
    property bool isPortait: false
    property bool isOnline: AppFramework.network.isOnline

    property bool featureServiceInfoComplete : false
    property string deviceOS: Qt.platform.os

    readonly property bool isDesktop: Qt.platform.os === "windows" || Qt.platform.os === "osx"

    /* *********** CONFIG ********************* */
    property string arcGISLicenseString: app.info.propertyValue("ArcGISLicenseString","");
    //property string landingpageBackground : app.info.propertyValue("startBackground","assets/background.png");
    property string landingpageBackground : app.folder.fileUrl(app.info.propertyValue("startBackground","images/background2.jpg"));
    property string logoImage :  app.folder.fileUrl(app.info.propertyValue("logoImage","images/esrilogo.png"));
    property string logoUrl : app.info.propertyValue("logoUrl","http://www.esri.com");
    property bool showDescriptionOnStartup : app.info.propertyValue("showDescriptionOnStartup",false);
    property bool startShowLogo : app.info.propertyValue("startShowLogo",true);
    property string loginImage : app.info.propertyValue("startButton","images/signin.png");
    property string pickListCaption: app.info.propertyValue("pickListCaption", "");

    //colors
    property color headerBackgroundColor: app.info.propertyValue("headerBackgroundColor","#165F8C");
    property color headerTextColor: app.info.propertyValue("headerTextColor","#FFF");
    property color pageBackgroundColor: app.info.propertyValue("pageBackgroundColor","#EBEBEB");
    property color buttonColor: app.info.propertyValue("buttonColor","orange");
    property string textColor : app.info.propertyValue("textColor","white");
    property color titleColor: app.info.propertyValue("titleColor","black");
    property color subtitleColor: app.info.propertyValue("subtitleColor","#51010a");

    //layers
    property string featureServiceURL : app.info.propertyValue("featureServiceURL","");
    property string featureLayerId : app.info.propertyValue("featureLayerId","");
    property string featureLayerName : app.info.propertyValue("featureLayerName","");
    property string featureLayerURL: featureServiceURL + "/" + featureLayerId;
    property string baseMapURL : app.info.propertyValue("baseMapURL","http://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer");
    property bool collectPhoto : app.info.propertyValue("collectPhoto",true);
    property bool allowPhotoToSkip : app.info.propertyValue("allowPhotoToSkip",true);

    //feedback
    property string websiteUrl : app.info.propertyValue("websiteUrl","www.arcgis.com");
    property string websiteLabel: app.info.propertyValue("websiteLabel", "Go to website");
    property string phoneNumber : app.info.propertyValue("phoneNumber","");
    property string phoneLabel: app.info.propertyValue("phoneLabel", "Call us");
    property string emailAddress : app.info.propertyValue("emailAddress","");
    property string emailLabel: app.info.propertyValue("emailLabel", "Email us");
    property string socialMediaUrl : app.info.propertyValue("socialMediaUrl","");
    property string socialMediaLabel : app.info.propertyValue("socialMediaLabel","Follow us");

    //Attributes
    property var attributesArray
    property string dateTimeFormat: app.info.propertyValue("dateTimeFormat", "dd/MM/yyyy")

    /* *********** CONFIG ********************* */



    /* *********** DOMAINS AND SUBTYPES ********************* */

    property variant domainValueArray: []
    property variant domainCodeArray: []

    property variant subTypeCodeArray: []
    property variant subTypeValueArray: []

    property variant domainRangeArray: []
    property variant delegateTypeArray:[]

    property var protoTypesArray: []
    property var protoTypesCodeArray: []

    property variant networkDomainsInfo

    property bool hasSubtypes: false
    property bool hasSubTypeDomain: false

    property var featureTypes
    property var featureType

    property var selectedFeatureType
    property var fields

    property int pickListIndex: 0

    //-------------------- Setup for the App ----------------------

    property string selectedImageFilePath: ""
    property string selectedImageFilePath_ORIG: ""
    property bool selectedImageHasGeolocation: false
    property var currentAddedFeatures : []

    property string featureServiceStatusString: "Working on it ..."
    property bool hasAttachment: false

    property var theFeatureToBeInsertedID: null
    property var theFeatureSucessfullyInsertedID: null
    property bool theFeatureEditingAllDone: false
    property bool theFeatureEditingSuccess: false
    property int theFeatureServiceWKID: -1
    property SpatialReference theFeatureServiceSpatialReference

    property bool hasDrafts: false

    property bool skipPressed: false

    property Point theNewPoint

    Graphic {
        id: selectedGraphic
        geometry: Point {
            x: 0
            y: 0
            spatialReference: {"wkid":102100}
        }
    }
    property alias selectedGraphic: selectedGraphic

    Component.onCompleted: {
        //console.log("########### Start Page ###########");
        //console.log("Setting ArcGIS Licence for the app: " + arcGISLicenseString);
        //AppFramework.network.proxy.url = "http://127.0.0.1:8888";
        //AppFramework.network.proxy.type = NetworkProxy.HttpProxy;
        ArcGISRuntime.license.setLicense(arcGISLicenseString);
        IdentityManager.ignoreSslErrors = true;

        attributesArray = {};
    }

    Connections {
        target: AppFramework.network.isOnline
        onIsOnlineChanged: {
            isOnline = AppFramework.network.isOnline
            if (!isOnline) {
                alertBox.visible = true;
            }
            else {
                alertBox.buttonText = "RETRY";
            }
        }
    }

    GeodatabaseAttachment {
        id: featureAttachment
    }
    property alias theFeatureAttachment: featureAttachment

    GeodatabaseFeatureServiceTable {
        id: theFeatureServiceTable

        url: app.featureLayerURL

        //credentials: userCredentials

        //        onCredentialsChanged: {
        //            console.log("user from GDBFST", credentials.userName)
        //            //theFeatureLayer.initialize()
        //            if (valid) {
        //                theFeatureLayer.featureTable = theFeatureServiceTable;
        //                //theFeatureLayer.initialize();
        //            }

        //        }

        onFeatureTableStatusChanged: {
            console.log("onFeatureTableStatusChanged", theFeatureServiceTable.featureTableStatus)
        }

        onInitializationErrorChanged: {
            console.log("Initialization error: ", initializationError)
        }

        onApplyFeatureEditsStatusChanged: {
            //Error thrown here
            ////console.log("ApplyEditsStatusChanged: ", applyFeatureEditsStatus);

            //if (applyFeatureEditsStatus === GeodatabaseFeatureServiceTable.ApplyEditsComplete) {
            if (applyFeatureEditsStatus === Enums.ApplyEditsStatusCompleted) {
                console.log("Apply Feature Edits Complete", skipPressed);
                app.featureServiceStatusString += "<br>Yay! New report was added."

                var newId = lookupObjectId(app.theFeatureToBeInsertedID);
                console.log("Old and New: ", app.theFeatureToBeInsertedID, newId)
                app.theFeatureSucessfullyInsertedID = newId;

                console.log("now looking for attachment...", skipPressed)
                //add attachment
                if ( app.hasAttachment && !skipPressed ) {
                    //if(app.hasAttachment){
                    app.featureServiceStatusString += "<br><br>Adding photo to report: " + newId;
                    console.log("Attaching file: ", app.selectedImageFilePath_ORIG);
                    //}

                    if (app.theFeatureAttachment.loadFromFile(app.selectedImageFilePath, "application/octet-stream")) {
                        app.featureServiceStatusString += "<br>Photo size is " + Math.round(app.theFeatureAttachment.size/1024) + " KB" ;
                        console.log("AddPhotoPage:: added the gdbAttachment", app.theFeatureAttachment.size);
                        app.theFeatureServiceTable.addAttachment(app.theFeatureSucessfullyInsertedID, app.theFeatureAttachment);
                    }
                }
                else {
                    app.featureServiceStatusString += "<br>Click Done to continue.";
                    console.log("should just be done...")
                    app.theFeatureEditingAllDone = true;
                    app.theFeatureEditingSuccess = true;
                }

                skipPressed = false;

            }
            //else if (applyFeatureEditsStatus === GeodatabaseFeatureServiceTable.ApplyEditsError) {
            else if (applyFeatureEditsStatus === Enums.ApplyEditsStatusErrored) {
                console.log("applyFeatureEditsErrors: " + applyFeatureEditsErrors.length);
                app.featureServiceStatusString = "Sorry there was an error!"
                app.theFeatureEditingAllDone = true
                app.theFeatureEditingSuccess = false
            }
        }

        onApplyAttachmentEditsStatusChanged: {
            //if (applyAttachmentEditsStatus === GeodatabaseFeatureServiceTable.ApplyEditsComplete) {
            if (applyAttachmentEditsStatus === Enums.AttachmentEditStatusCompleted) {
                //console.log("Apply Attachment Edits Complete");
                app.featureServiceStatusString += "<br>Photo added successfully."
                app.theFeatureEditingAllDone = true
                app.theFeatureEditingSuccess = true
            }
            //else if (applyAttachmentEditsStatus === GeodatabaseFeatureServiceTable.ApplyEditsError) {
            else if (applyAttachmentEditsStatus === Enums.AttachmentEditStatusErrored) {
                console.log("applyAttachmentEditsErrors: " + applyAttachmentEditsErrors.length);
                app.featureServiceStatusString = "<br>Sorry could not add photo!";
                app.theFeatureEditingAllDone = true
                app.theFeatureEditingSuccess = false
            }
        }

        onAddAttachmentStatusChanged: {
            if (addAttachmentStatus === Enums.AttachmentEditStatusCompleted) {
                //if (addAttachmentStatus === GeodatabaseFeatureTable.AttachmentEditComplete) {
                //console.log("Attachment added, attachment id: " + addAttachmentResult.attachmentObjectId);
                //updatingText.text = ("Attachment added, attachment id: " + addAttachmentResult.attachmentObjectId)

                applyAttachmentEdits();

            }
            //else if (addAttachmentStatus === GeodatabaseFeatureTable.AttachmentEditError) {
            else if (addAttachmentStatus === Enums.AttachmentEditStatusErrored) {
                //console.log("Attachment add failed: " + addAttachmentResult.error.description);
                //updatingText.text = "Attachment add failed: " + addAttachmentResult.error.description
            }

        }

        function fieldArray() {
            var array = [];
            for (var i = 0; i < fields.length; i++) {
                array.push(fields[i]);
            }

            for (var i = 0; i < featureTypes.length; i++) {
                //array.push(featureTypes[i]);
                //array.push(featureTypes[i].domains);
                array.push( { "name": featureTypes[i].domains[0] });
            }
            return array;
        }

        function lookupField(name) {
            return fieldArray().filter(function(e) { return e.name == name; })[0];
        }

    }



    //    GeodatabaseFeatureServiceTable2 {
    //        id: theFeatureServiceTable

    //        url: app.featureLayerURL

    //        onFeatureTableStatusChanged: {
    //            console.log("onFeatureTableStatusChanged", theFeatureServiceTable.featureTableStatus)
    //        }


    //        onInitializationErrorChanged: {
    //            console.log("Initialization error: ", initializationError)
    //        }

    //        onApplyFeatureEditsStatusChanged: {
    //            //Error thrown here
    //            ////console.log("ApplyEditsStatusChanged: ", applyFeatureEditsStatus);

    //            //if (applyFeatureEditsStatus === GeodatabaseFeatureServiceTable.ApplyEditsComplete) {
    //            if (applyFeatureEditsStatus === Enums.ApplyEditsStatusCompleted) {
    //                console.log("Apply Feature Edits Complete", skipPressed);
    //                app.featureServiceStatusString += "<br>Yay! New report was added."

    //                var newId = lookupObjectId(app.theFeatureToBeInsertedID);
    //                console.log("Old and New: ", app.theFeatureToBeInsertedID, newId)
    //                app.theFeatureSucessfullyInsertedID = newId;

    //                console.log("now looking for attachment...", skipPressed)
    //                //add attachment
    //                if ( app.hasAttachment && !skipPressed ) {
    //                    //if(app.hasAttachment){
    //                        app.featureServiceStatusString += "<br><br>Adding photo to report: " + newId;
    //                        console.log("Attaching file: ", app.selectedImageFilePath_ORIG);
    //                    //}

    //                    if (app.theFeatureAttachment.loadFromFile(app.selectedImageFilePath, "application/octet-stream")) {
    //                        app.featureServiceStatusString += "<br>Photo size is " + Math.round(app.theFeatureAttachment.size/1024) + " KB" ;
    //                        console.log("AddPhotoPage:: added the gdbAttachment", app.theFeatureAttachment.size);
    //                        app.theFeatureServiceTable.addAttachment(app.theFeatureSucessfullyInsertedID, app.theFeatureAttachment);
    //                    }
    //                }
    //                else {
    //                    app.featureServiceStatusString += "<br>Click Done to continue.";
    //                    console.log("should just be done...")
    //                    app.theFeatureEditingAllDone = true;
    //                    app.theFeatureEditingSuccess = true;
    //                }

    //                skipPressed = false;

    //            }
    //            //else if (applyFeatureEditsStatus === GeodatabaseFeatureServiceTable.ApplyEditsError) {
    //            else if (applyFeatureEditsStatus === Enums.ApplyEditsStatusErrored) {
    //                console.log("applyFeatureEditsErrors: " + applyFeatureEditsErrors.length);
    //                app.featureServiceStatusString = "Sorry there was an error!"
    //                app.theFeatureEditingAllDone = true
    //                app.theFeatureEditingSuccess = false
    //            }
    //        }

    //        onApplyAttachmentEditsStatusChanged: {
    //            //if (applyAttachmentEditsStatus === GeodatabaseFeatureServiceTable.ApplyEditsComplete) {
    //            if (applyAttachmentEditsStatus === Enums.AttachmentEditStatusCompleted) {
    //                //console.log("Apply Attachment Edits Complete");
    //                app.featureServiceStatusString += "<br>Photo added successfully."
    //                app.theFeatureEditingAllDone = true
    //                app.theFeatureEditingSuccess = true
    //            }
    //            //else if (applyAttachmentEditsStatus === GeodatabaseFeatureServiceTable.ApplyEditsError) {
    //            else if (applyAttachmentEditsStatus === Enums.AttachmentEditStatusErrored) {
    //                console.log("applyAttachmentEditsErrors: " + applyAttachmentEditsErrors.length);
    //                app.featureServiceStatusString = "<br>Sorry could not add photo!";
    //                app.theFeatureEditingAllDone = true
    //                app.theFeatureEditingSuccess = false
    //            }
    //        }

    //        onAddAttachmentStatusChanged: {
    //                if (addAttachmentStatus === Enums.AttachmentEditStatusCompleted) {
    //                    //if (addAttachmentStatus === GeodatabaseFeatureTable.AttachmentEditComplete) {
    //                    //console.log("Attachment added, attachment id: " + addAttachmentResult.attachmentObjectId);
    //                    //updatingText.text = ("Attachment added, attachment id: " + addAttachmentResult.attachmentObjectId)

    //                    applyAttachmentEdits();

    //                }
    //                //else if (addAttachmentStatus === GeodatabaseFeatureTable.AttachmentEditError) {
    //                else if (addAttachmentStatus === Enums.AttachmentEditStatusErrored) {
    //                    //console.log("Attachment add failed: " + addAttachmentResult.error.description);
    //                    //updatingText.text = "Attachment add failed: " + addAttachmentResult.error.description
    //                }

    //        }

    //    }
    property alias theFeatureServiceTable: theFeatureServiceTable

    Point {
        id: pointGeometry
        x: 200
        y: 200
    }

    //    Portal {
    //        id: portal
    //        url: app.info.propertyValue("portalURL", "https://www.arcgis.com")
    //        onSignInComplete: {
    //            serviceInfoTask.fetchFeatureServiceInfo();
    //            portalSignInDialog.close();
    //            theFeatureLayer.initialize();
    //        }
    //    }

    //    PortalSignInDialog {
    //        id: portalSignInDialog
    //        portal: portal
    //    }

    //    Connections{
    //        target: ArcGISRuntime.identityManager

    //        onUserCredentialsRequired: {
    //            if (!portalSignInDialog.portal.signedIn){
    //                portalSignInDialog.open()
    //            }
    //        }
    //    }

    //    UserCredentials {
    //        id: userCredentials
    //        userName: "arcpaddemo"
    //        password: "arcpaddemo"
    //    }

    ServiceInfoTask {
        id: serviceInfoTask
        url: featureServiceURL
        onFeatureServiceInfoStatusChanged: {
            console.log("fs status", featureServiceInfoStatus)
            if(featureServiceInfoStatus == Enums.FeatureServiceInfoStatusCompleted) {
                app.theFeatureServiceWKID = featureServiceInfo.spatialReference.wkid;
                app.theFeatureServiceSpatialReference = featureServiceInfo.spatialReference;
                console.log("!!!feature service info complete")

                featureServiceInfoComplete = true;

                //theFeatureServiceTable.credentials = portal.credentials;
                app.theFeatureLayer.initialize();
            }
            else if ( featureServiceInfoStatus == Enums.FeatureServiceInfoStatusErrored ) {
                console.log("!!!the feature service info errored.", featureServiceInfoError.message);
                if (serviceInfoTask.featureServiceInfoStatus === Enums.FeatureServiceInfoStatusErrored){
                    console.log( serviceInfoTask.featureServiceInfoError.details, serviceInfoTask.featureServiceInfoError.code );
                    alertBox.text = serviceInfoTask.featureServiceInfoError.message;

                    if (serviceInfoTask.featureServiceInfoError.message === "Unable to generate token.") {
                        alertBox.text = "The app is trying to access a secured service, but unfortuantely doesn't support them. The app will have to quit.";
                        alertBox.actionRequest = alertBox.actionMode[0];
                        alertBox.buttonText = "OK";
                    }
                    else {
                        if ( !isOnline ) {
                            alertBox.text = "Data not available. Turn off airplane mode or check data connection and retry.";
                            alertBox.actionRequest = alertBox.actionMode[1];
                            alertBox.buttonText = "WAITING...";
                        }
                        else {
                            alertBox.buttonText = "RETRY";
                        }
                    }

                    alertBox.visible = true;
                }
            }
        }

        Component.onCompleted: {
            fetchFeatureServiceInfo();
        }
    }

    FeatureLayer {
        id: theFeatureLayer
        featureTable: theFeatureServiceTable.valid ? theFeatureServiceTable : null

        // credentials: userCredentials

        onStatusChanged: {
            console.log("valid", theFeatureServiceTable.valid)
            console.log("thefeatureLayer status:", status);
            if(status == Enums.LayerStatusInitialized) {
                console.log("Feature layer complete");
                console.log("Editable: ", theFeatureServiceTable.isEditable, " | Has attachments: ", theFeatureServiceTable.hasAttachments);

                fields = theFeatureServiceTable.editableAttributeFields;

                //Checking for Subtype information

                if ( theFeatureServiceTable.typeIdField > ""){
                    console.log("This service has a sub Type::", theFeatureServiceTable.typeIdField);
                    hasSubtypes = true;
                    featureTypes = theFeatureServiceTable.featureTypes;
                }
                else {
                    console.log("This service DOES NOT have a sub Type::");
                }

                for ( var j = 0; j < fields.length; j++ ) {
                    var hasDomain = false;
                    var isRangeDomain = false;
                    if ( fields[j].domain !== null){
                        hasDomain = true;
                        if (fields[j].domain.objectType === "RangeDomain" ) {
                            isRangeDomain = true
                        }
                    }

                    var isSubTypeField = false;
                    if ( fields[j].name === theFeatureServiceTable.typeIdField ){
                        isSubTypeField = true;
                    }

                    //                    theFeatureAttributesModel.append({"fieldName": fields[j].name, "fieldAlias": fields[j].alias, "fieldType": fields[j].fieldTypeString, "fieldValue": "", "domainName":"", "domainType":""})
                    var defaultFieldValue = 0;
                    theFeatureAttributesModel.append({"fieldIndex": j, "fieldName": fields[j].name, "fieldAlias": fields[j].alias, "fieldType": fields[j].fieldTypeString, "fieldValue": "", "defaultNumber": defaultFieldValue, "isSubTypeField": isSubTypeField, "hasSubTypeDomain" : false, "hasDomain": hasDomain, "isRangeDomain": isRangeDomain })
                }

                app.hasAttachment = theFeatureServiceTable.hasAttachments;

                //read and set the types model
                //console.log("Renderer type: ", theFeatureLayer.renderer.rendererType);

                if(theFeatureLayer.renderer.rendererType === Enums.RendererTypeUniqueValue) {
                    //theFeatureTypesModel.clear();

                    var values = theFeatureLayer.renderer.uniqueValues;
                    //console.log("values json::", JSON.stringify(values, undefined, 2));

                    for(var i=0; i< values.length; i++) {
                        var url = "";
                        //if (values[i].type === 8){
                        if(values[i].symbol.json.imageData) {
                            url = "data:image/png;base64," + values[i].symbol.json.imageData
                            //console.log("image url::", url);
                        } else {
                            url = values[i].symbol.symbolImage(pointGeometry, "transparent").url;
                            url = Qt.resolvedUrl(url);
                            ////console.log(AppFramework.resolvedPath(url));
                        }
                        if(values[i].symbol.json.imageData) {
                            url = "data:image/png;base64," + values[i].symbol.json.imageData
                            //                                console.log("image url::", url);
                        } else {
                            url = values[i].symbol.symbolImage(pointGeometry, "transparent").url;
                            url = Qt.resolvedUrl(url);
                            ////console.log(AppFramework.resolvedPath(url));
                        }
                        //}

                        //console.log("Image URL: ", url);

                        theFeatureTypesModel.append({"label": values[i].label, "value" : values[i]["value"].toString(), "description": values[i].description, "imageUrl": url});
                        protoTypesArray.push(values[i].label);
                    }
                }

                //console.log("Feature service display field: ", theFeatureServiceTable.displayField);

                //console.log(app.emailAddress, app.phoneNumber, app.websiteUrl, app.socialMediaUrl);

                //console.log("Folder path: ", appFolder.path);

                //console.log("Types count: ", theFeatureTypesModel.count, " | Attributes count: ", theFeatureAttributesModel.count);

                //console.log("Featurelayer spatial ref: ", JSON.stringify(theFeatureLayer.fullExtent.json), theFeatureLayer.fullExtent.spatialReference.wkid);
            }

            if(status == Enums.LayerStatusErrored) {
                console.log("Layer create error: ", error)
            }
        }
    }

    property alias theFeatureLayer: theFeatureLayer

    ListModel {
        id: theFeatureTypesModel
    }

    ListModel {
        id: theFeatureAttributesModel
    }

    VisualItemModel  {
        id: theFeatureAttributesVisualModel
    }

    //--------------------------------------------------------------------------

    FileFolder {
        id: appFolder
        //path: "~/ArcGIS/GeoReporterV1/"
    }
    //--------------------------------

    StackView {
        id: stackView
        anchors.fill: parent
        initialItem: landingPage

        function showWelcomePage() {
            stackView.clear()
            push(welcomePage)
        }

        function showMapPage() {
            push(mapPage)
        }
        function showDraftsPage() {
            push(draftsPage)
        }
        function showAddPhotoPage() {
            push(addPhotoPage)
        }
        function showRefineLocationPage(){
            push(refineLocationPage)
        }
        function showAddDetailsPage(){
            push(addDetailsPage)
        }
        function showResultsPage() {
            push(resultsPage)
        }
    }

    //--------------------------------

    Component {
        id: landingPage

        LandingPage {
            onSignInClicked: {
                app.isSmallScreen = (parent.width || parent.height) < 400*app.scaleFactor
                app.isPortait = parent.height > parent.width

                //console.log("##StartPage:: DisplayScaleFactor: ", scaleFactor, " isSmallScreen: ", isSmallScreen, " isPortarit: ", isPortait);
                stackView.push(welcomePage);
            }

            Component.onCompleted: {
                //console.log("Calling initialize on feature layer: " + featureLayerURL)
                //app.theFeatureLayer.initialize();
            }
        }
    }

    //--------------------------------------------------------------------------
    Component {
        id: welcomePage

        WelcomePage {

            onNext: {
                //console.log("Next clicked from page1 with value: " + message);
                switch(message) {
                case "viewmap": stackView.showMapPage(); break;
                case "createnew": if(app.hasAttachment) {
                        stackView.showAddPhotoPage();
                        break;
                    } else {
                        stackView.showRefineLocationPage();
                        //stackView.showAddDetailsPage();
                        break;
                    }
                case "drafts": stackView.showDraftsPage();break;
                case "details" : stackView.showAddDetailsPage();break
                }
            }

            onPrevious: {
                stackView.pop();
            }
        }
    }
    //--------------------------------------------------------------------------
    Component {
        id: mapPage
        MapPage {
            onPrevious: {
                stackView.pop();
            }
        }
    }
    //--------------------------------------------------------------------------
    Component {
        id: draftsPage
        DraftsPage {
            onPrevious: {
                stackView.pop();
            }
        }
    }
    //--------------------------------------------------------------------------
    Component {
        id: addPhotoPage
        AddPhotoPage {
            onNext: {
                //console.log("Next clicked from page1 with value: " + message);
                stackView.showRefineLocationPage();
            }
            onPrevious: {
                stackView.pop();
            }
        }
    }
    //--------------------------------------------------------------------------
    Component {
        id: refineLocationPage
        RefineLocationPage {
            onNext: {
                //console.log("Next clicked from page1 with value: " + message);
                stackView.showAddDetailsPage();
            }
            onPrevious: {
                stackView.pop();
            }
        }
    }
    //--------------------------------------------------------------------------
    Component {
        id: addDetailsPage
        AddDetailsPage {
            onNext: {
                //console.log("Next clicked from page1 with value: " + message);

                if(message == "welcome") {
                    stackView.showWelcomePage()
                } else {
                    stackView.showResultsPage()
                }
            }
            onPrevious: {
                stackView.pop();
            }
        }
    }
    //--------------------------------------------------------------------------
    Component {
        id: resultsPage
        ResultsPage {
            onNext: {
                //console.log("Next clicked from page1 with value: " + message);
                stackView.showWelcomePage()
            }
            onPrevious: {
                stackView.pop();
            }
        }
    }

    //--------------------------------------------------------------------------


    AlertBox {
        id: alertBox
        //visible: AppFramework.network.isOnline
    }

}
