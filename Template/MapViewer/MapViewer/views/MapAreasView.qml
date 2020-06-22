import QtQuick 2.7
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Platform 1.0
import Esri.ArcGISRuntime 100.7


import "../controls" as Controls

ListView {
    id: mapAreasView

    signal mapAreaSelected (int index)
    signal currentMapAreaSelectionUpdated ()

    property var offlineMapJob

    property var mapPortalItemId
    property var thumbnailUrl
    property var thumbnailImgName
    property var  mapAreas:[]

    property var mapareaiddownloading:[]
    property var downloadList:[]
    property var processingList:[]
    property bool processing:false
    property string fontNameFallbacks: "Helvetica,Avenir"
    signal downloadCompleted(var message,var body)



    topMargin: 16 * scaleFactor
    leftMargin: 16 * scaleFactor

    anchors.fill:parent
    footer:Rectangle{
        height:70 * scaleFactor
        width:mapAreasView.width
        color:"transparent"
    }
    clip: true
    spacing: 10 * scaleFactor
    focus:true

    property real columns: app.isLarge ? 2 : 3

    delegate: Pane {
        id: container

        padding: 10 * scaleFactor
        height: app.units(80)
        width: parent.width - 32 * scaleFactor
        Material.elevation: 1

        Rectangle {
            width:parent.width
            height:parent.height

            RowLayout {
                id: cardContent
                anchors.fill: parent
                spacing: 0

                property int cardMargins: 3/4 * app.defaultMargin

                function updateSelectionInModel(index)
                {
                    for(var k=0;k<=mapAreasModel.count;k++)
                    {
                        if(k === index)
                        {

                            mapAreasModel.setProperty(k, "isSelected", true)
                        }
                        else
                        {

                            mapAreasModel.setProperty(k, "isSelected", false)
                        }

                    }


                }
                Rectangle {

                    property real aspectRatio: (200/133)
                    Layout.preferredHeight: parent.height
                    Layout.preferredWidth: aspectRatio * Layout.preferredHeight// parent.width//thumbnail.width + 2 * app.baseUnit
                    Layout.margins: 0

                    Image {
                        id: thumbnail
                        anchors.fill: parent
                        Layout.margins: 0
                        cache: true
                        source: thumbnailurl

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                cardContent.updateSelectionInModel(index)
                                mapPage.highlightMapArea(index)
                            }
                        }
                    }
                }

                Item {
                    Layout.preferredWidth: 10 * scaleFactor
                }

                Rectangle {
                    id:rect
                    Layout.preferredHeight:cols.height
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignLeft

                    ColumnLayout {
                        id:cols
                        spacing: 0
                        width:parent.width - 30 * scaleFactor

                        Text{

                            id: lbl
                            objectName: "label"
                            visible: text.length > 0
                            text: title

                            color: app.baseTextColor
                            Layout.preferredWidth:rect.width
                            Layout.alignment: Qt.AlignLeft
                            horizontalAlignment: Text.AlignLeft
                            font.bold:isSelected?true:false
                            font.pixelSize: 1.0 * app.baseFontSize

                            maximumLineCount: 2


                            elide: Text.ElideRight
                            wrapMode: Text.WordWrap
                        }



                        RowLayout{
                            spacing: 5 * app.scaleFactor
                            Layout.alignment: Qt.AlignLeft

                            Text{

                                text:modifiedDate > ""?modifiedDate:createdDate
                                font.pixelSize: app.textFontSize
                                font.family: app.baseFontFamily
                                color: app.subTitleTextColor

                            }
                            Rectangle {
                                id:icon
                                Layout.preferredWidth: 4
                                Layout.preferredHeight:4
                                radius: 2
                                color: "grey"
                                Layout.alignment: Qt.AlignVCenter
                            }
                            Text{
                                text:size
                                font.pixelSize: app.textFontSize
                                font.family: app.baseFontFamily
                                color: app.subTitleTextColor
                            }


                        }

                    }
                    MouseArea {

                        anchors.fill: parent
                        onClicked: {

                            cardContent.updateSelectionInModel(index)
                            mapPage.highlightMapArea(index)
                        }
                    }
                }

                Rectangle{
                    Layout.preferredHeight: 50 * scaleFactor//app.iconSize//downloadBtn.height//10 * scaleFactor
                    Layout.preferredWidth: 50 * scaleFactor //app.iconSize//downloadBtn.width//10 * scaleFactor
                    Layout.alignment: Qt.AlignCenter

                    Controls.Icon {
                            anchors.fill: parent

                        id: downloadBtn
                        visible: !isDownloading
                        imageSource: isPresent?"../images/more.png":"../images/download.png"
                        enabled: !isPresent?(size > "0 Bytes"?true:false):true
                        anchors.centerIn: parent
                        maskColor: app.primaryColor
                        MouseArea {
                            anchors.fill: parent

                            onClicked: {
                                if(isPresent)
                                {
                                    more.close()
                                    more.open()
                                }
                                else
                                {
                                    more.close()
                                    thumbnailUrl = thumbnailurl
                                    cardContent.updateSelectionInModel(index)

                                    mapView.setViewpointGeometryAndPadding(polygonGraphicsOverlay.extent,100)
                                    mapPage.highlightMapArea(index)
                                    var downloadObj = {}
                                    downloadObj["index"] = index
                                    downloadObj["thumbnailImg"] = thumbnailImg


                                    downloadList.push(downloadObj)

                                    mapAreasModel.setProperty(index, "isDownloading", true)
                                    processDownloadList()

                                }
                            }
                        }
                    }

                    BusyIndicator {
                        id: busyIndicator
                        height: app.iconSize
                        width: height
                        visible:isDownloading
                        Material.primary: app.primaryColor
                        Material.accent: app.primaryColor
                        anchors.centerIn: parent
                    }

                }
            }
        }





        //popup Menu
        Controls.PopupMenu {
            id: more
            isInteractive: false

            property string kRefresh: qsTr("Remove")

            defaultMargin: app.defaultMargin
            backgroundColor: "#FFFFFF"
            highlightColor: Qt.darker(app.backgroundColor, 1.1)
            textColor: app.baseTextColor
            primaryColor: app.primaryColor


            menuItems: [
                {"itemLabel": qsTr("Open"),"lcolor":""},

                {"itemLabel": qsTr("Remove"),"lcolor":"red"},

            ]

            Material.primary: app.primaryColor
            Material.background: backgroundColor

            height: app.units(88)

            x: parent.width - width - app.baseUnit
            y: 0

            onMenuItemSelected: {
                switch (itemLabel) {

                case qsTr("Remove"):
                    processDeleteMapArea(mapAreas[index].mapArea.portalItem.itemId,mapAreas[index].mapArea.portalItem.title)

                    break

                case qsTr("Open"):
                    openMapArea(index)
                    break

                }
            }


            function openMapArea()
            {
                var fileName = "mapareasinfos.json"
                //iterate through the subfolders


                if (offlineMapAreaCache.fileFolder.fileExists(fileName)) {
                    var fileContent = offlineMapAreaCache.fileFolder.readJsonFile(fileName)
                    var maparea = fileContent.results.filter(item => item.id === mapAreas[index].mapArea.portalItem.itemId)
                    if(maparea !== null && maparea.length > 0){

                        var furl = offlineMapAreaCache.fileFolder.path + "/" + mapPage.portalItem.id +"/" + mapAreas[index].mapArea.portalItem.itemId + "/p13/"


                        var mapProperties = {"fileUrl":furl, "gdbpath":maparea[0].gdbpath,
                            "basemaps":maparea[0].basemaps,"isMapArea":true,
                            "title":maparea[0].title,"owner":maparea[0].owner,"modifiedDate":maparea[0].modifiedDate,"extent":mapAreas[index].areaOfInterest.extent}
                        mapPage.portalItem_main = mapPage.portalItem
                        mapPage.mapProperties_main = mapPage.mapProperties
                        mapPage.mapProperties_main["isMapArea"] = false

                        mapPage.mapProperties = mapProperties
                        mapPage.portalItem = maparea[0]

                    }

                }
            }

            function processDeleteMapArea(mapareaId,title) {


                app.messageDialog.width = messageDialog.units(300)
                app.messageDialog.standardButtons = Dialog.Cancel | Dialog.Ok


                app.messageDialog.show(qsTr("Remove offline area"),qsTr("This will remove the downloaded offline map area %1 from the device. Would you like to continue?").arg(title))

                app.messageDialog.connectToAccepted(function () {
                    deleteMapArea(mapareaId)
                })
            }

            function deleteMapArea(mapareaId)
            {
                var fileName = "mapareasinfos.json"

                var mapAreaPath = offlineMapAreaCache.fileFolder.path + "/"+ mapPage.portalItem.id
                let mapAreafileInfo = AppFramework.fileInfo(mapAreaPath)
                //fileInfo.folder points to previous folder
                if (mapAreafileInfo.folder.fileExists(fileName)) {
                    var   fileContent = mapAreafileInfo.folder.readJsonFile(fileName)
                    var results = fileContent.results
                    existingmapareas = results.filter(item => item.id !== mapareaId)
                    fileContent.results = existingmapareas

                    //delete the folder
                    var thumbnailFolder = mapareaId + "_thumbnail"
                    var mapareacontentpath = [mapAreaPath,thumbnailFolder].join("/")
                    let fileFolder= AppFramework.fileFolder(mapareacontentpath)
                    var isthumbnaildeleted = fileFolder.removeFolder()
                    var mapareacontents = [mapAreaPath,mapareaId].join("/")
                    let mapareafileFolder = AppFramework.fileFolder(mapareacontents)
                    var isdeleted = mapareafileFolder.removeFolder()
                    if(isdeleted)
                    {
                        mapAreafileInfo.folder.writeJsonFile(fileName, fileContent)
                        // portalSearch.removeMapAreaFromLocal(mapareaId)
                        updateModel(mapareaId,false)
                        portalSearch.populateLocalMapPackages()


                    }

                }

            }



            function titleCase(str) {
                return str.toLowerCase().split(" ").map(function(word) {
                    return (word.charAt(0).toUpperCase() + word.slice(1));
                }).join(" ");
            }
        }



        Component.onCompleted: {

        }
    }

    FileFolder{
        id:mapAreaFolder

    }

    FileFolder{
        id:mapAreaContentFolder


    }
    FileFolder{
        id:mapAreaThumbnailFolder

    }

    Component{
        id: networkRequestComponent
        NetworkRequest{
            id: networkRequest

            property var name;
            property var callback;

            method: "GET"
            ignoreSslErrors: true



            onReadyStateChanged: {
                if (readyState === NetworkRequest.DONE ){
                    if(errorCode != 0){
                        fileFolder.removeFile(networkRequest.name);
                        loadStatus = 2;

                    } else {

                        if (callback) {
                            callback();
                        }
                    }
                }
            }

            function downloadImage(downloadedmapareaId,callback){

                networkRequest.url = thumbnailUrl;

                networkRequest.responsePath = mapAreaThumbnailFolder.path + "/" + downloadedmapareaId + "_thumbnail" + "/" + thumbnailImgName;
                networkRequest.callback = callback;
                networkRequest.send();

            }
        }
    }

    Controls.BaseText {
        id: message

        visible: model.count <= 0 && text > ""
        maximumLineCount: 5
        elide: Text.ElideRight
        width: parent.width
        height: parent.height
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        text: qsTr("There are no offline map areas.")
    }

    function units (num) {
        return num ? num * AppFramework.displayScaleFactor : num
    }

    function processDownloadList()
    {

        if(downloadList.length > 0)
        {

            var downloadObj = downloadList.pop()
            var downloadIndx = downloadObj.index
            var thumbnailImg = downloadObj.thumbnailImg
            processingList.push(downloadIndx)
            downloadMapArea(downloadIndx,thumbnailImg)
        }



    }



    function downloadMapArea(downloadIndx,thumbnailImg)
    {
        Platform.stayAwake = true
        var _mapArea = mapAreas[downloadIndx].mapArea
        if(_mapArea)
        {

            var storageBasePath = offlineMapAreaCache.fileFolder.path
            var mapareapath = [storageBasePath,mapPage.portalItem.id].join("/")

            var lastindex = thumbnailImg.lastIndexOf('/')
            thumbnailImgName = thumbnailImg.substring(lastindex + 1)



            mapPortalItemId = mapPage.portalItem.id
            var mapareapath1 = [storageBasePath,mapPage.portalItem.id,_mapArea.portalItem.itemId].join("/")




            mapAreaContentFolder.path = mapareapath


            var mapAreaitemFolder = mapAreaContentFolder.folder(_mapArea.portalItem.itemId)
            var foldermade3 = mapAreaitemFolder.makeFolder()
            var downloadPath = ""
            if(Qt.platform.os === "windows")
                downloadPath = "file:///"+ mapareapath1
            else
                downloadPath = "file://"+ mapareapath1

            let fileInfo_todelete = AppFramework.fileInfo(mapareapath1)
            let fileFolder_todel = fileInfo_todelete.folder
            fileFolder_todel.removeFolder(_mapArea.portalItem.itemId,true)

            fileFolder_todel.removeFolder(_mapArea.portalItem)







            //create the folder for thumbnail
            mapAreaThumbnailFolder.path = mapareapath //mapareapath2
            var mapAreathumbnailFolder1 = mapAreaThumbnailFolder.folder(_mapArea.portalItem.itemId + "_thumbnail")
            var foldermade4 = mapAreathumbnailFolder1.makeFolder()
            console.log("started offline job" + downloadPath )
            createAndStartOfflineJob(_mapArea,downloadPath,downloadIndx)


        }
        else
        {
            console.log("mapArea is  null")
            mapPage.showDownloadFailed(qsTr("Offline map area failed to download."))
           // mapAreaToastMessage.display(qsTr("Offline map area failed to download."))
            mapAreasView.model.setProperty(downloadIndx,"isDownloading",false)
        }

    }
    PortalItem {
        id: mapPortalItem

        itemId: mapPage.portalItem.id

    }

    OfflineMapTask {
        id: offlineMapAreaTask
        portalItem: mapPortalItem

    }

    function createAndStartOfflineJob(_mapArea,downloadPath,downloadIndx)
    {

        //clear the downloadPath

        var offlineMapJob = offlineMapAreaTask.downloadPreplannedOfflineMap(_mapArea,downloadPath)
        // console.log("in offline job" + downloadPath )




        offlineMapJob.resultChanged.connect(function(){

            if(offlineMapJob.result){

                if(!offlineMapJob.result.hasErrors)
                {
                    var mapareadownloaded = mapAreas[downloadIndx]
                    downloadThumbnail(_mapArea.portalItem.itemId,saveMapInfo(_mapArea.portalItem.itemId,mapareadownloaded))
                    //console.log("Success:Map Area  download")
                }
                else
                {

                    var errormsg = ""
                    if(offlineMapJob.result.layerErrors && offlineMapJob.result.layerErrors.length > 0)
                    {
                        if(offlineMapJob.result.layerErrors.length > 0)
                        {

                            errormsg = offlineMapJob.result.layerErrors[0].error.message + "."+ offlineMapJob.result.layerErrors[0].error.additionalMessage
                        }

                    }
                    if(errormsg > "")
                    {
                        mapPage.showDownloadFailedMessage(errormsg,_mapArea.portalItem.title)

                    }
                    else
                        mapPage.showDownloadFailedMessage(qsTr("Unknown Error"),_mapArea.portalItem.title)





                    //console.log("Error:Map Area failed to download")
                    mapAreasView.model.setProperty(downloadIndx,"isDownloading",false)
                }


            }
        })
        offlineMapJob.start()

    }


    function updateDownloadJobStatus(jobStatus){
        console.log("Map Area  download started jobstatus changed")

    }

    function downloadThumbnail(downloadedmapareaId,callback)
    {
        var component = networkRequestComponent;
        var networkRequest = component.createObject(parent);
        networkRequest.downloadImage(downloadedmapareaId,callback);
    }
    function saveMapInfo (downloadedmapareaId,mapareadownloaded) {
        var fileName = "mapareasinfos.json"
        var mapAreafileName = "mobile_map.marea"
        var fileContent = {"results": []}
        var mapAreaFileContent = ""
        var gdbpath =""
        var basemaps = []

        var storageBasePath = offlineMapAreaCache.fileFolder.path




        var mapareacontentpath = [storageBasePath,mapPortalItemId,downloadedmapareaId,"p13",mapAreafileName].join("/")
        let fileInfo = AppFramework.fileInfo(mapareacontentpath)
        let mapAreaContentFolder = fileInfo.folder

        var _size = mapAreaContentFolder.size
        //
        if(_size < 1024)
            _size = _size + " Bytes"
        else
            _size = app.getFileSize(_size)


        if (mapAreaContentFolder.fileExists(mapAreafileName)) {
            mapAreaFileContent = mapAreaContentFolder.readJsonFile(mapAreafileName)
        }


        var mapareacontainerpath = [storageBasePath,mapPortalItemId].join("/")
        let fileInfoMapAreaContainer = AppFramework.fileInfo(mapareacontainerpath)
        let mapAreaContainerFolder = fileInfoMapAreaContainer.folder
        if (mapAreaContainerFolder.fileExists(fileName)) {
            fileContent = mapAreaContainerFolder.readJsonFile(fileName)
        }
        if(mapAreaFileContent.packages)
        {
            for (var i=0; i< mapAreaFileContent["packages"].length; i++)
            {
                var pitem = mapAreaFileContent["packages"][i]
                if(pitem.itemType === "SQLite Geodatabase")
                    gdbpath = pitem.path.split('./')[1]
                else if((pitem.itemType === "Vector Tile Package") || (pitem.itemType === "Tile Package"))
                {
                    var  vtpkpath = pitem.path.split('./')[1]
                    basemaps.push(vtpkpath)
                }

            }
        }



        var item = {
            "type":"maparea",
            "mapid":mapPage.portalItem.id,
            "id":downloadedmapareaId,
            "thumbnailUrl":thumbnailImgName,
            "gdbpath": gdbpath,
            "basemaps": basemaps,
            "title":mapareadownloaded.title,
            "createdDate":mapareadownloaded.createdDate,
            "size":_size,
            "owner":mapareadownloaded.owner,
            "modifiedDate":mapareadownloaded.modifiedDate

        }

        fileContent.results.push(item)
        mapAreaContainerFolder.writeJsonFile(fileName, fileContent)

        //update the model
        updateModel(downloadedmapareaId,true)

        mapPage.showDownloadCompletedMessage(qsTr("Download Complete."),mapareadownloaded.title)

        mapareaiddownloading = ""


        portalSearch.populateLocalMapPackages()
        Platform.stayAwake = false

        processDownloadList()

    }



    function updateModel(mapareaId,value)
    {

        for(var k=0;k<mapAreasView.model.count; k ++){

            var _mapArea = mapAreasView.model.get(k)
            if(_mapArea.portalItem.itemId === mapareaId)
            {
                mapAreasView.model.setProperty(k,"isPresent",value)
                mapAreasView.model.setProperty(k,"isDownloading",false)
            }

        }



    }




    function checkStatus()
    {
        if(offlineMapJob.result){
            if(!offlineMapJob.hasErrors)
            {
                downloadThumbnail(saveMapInfo)
                console.log("statusSuccess:Map Area  download")
            }
            else
                console.log("Error:Map Area failed to download")


        }
    }

    function downloadComplete(downloadPreplannedOfflineMapResult)
    {
        if(offlineMapJob.result){
            if(!offlineMapJob.hasErrors)
            {
                downloadThumbnail(saveMapInfo)
                console.log("Success:Map Area  download")
            }
            else
                console.log("Error:Map Area failed to download")


        }


    }

    function updateCurrentSelection (index) {
        for (var i=0; i<mapAreasView.model.count; i++) {
            if (i === index) {
                mapAreasView.model.setProperty(i, "isChecked", true)
            } else {
                mapAreasView.model.setProperty(i, "isChecked", false)
            }
        }
        currentMapAreaSelectionUpdated()
    }
}
