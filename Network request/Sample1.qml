import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.1
import QtPositioning 5.3

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import ArcGIS.AppFramework.Runtime 1.0
import ArcGIS.AppFramework.Runtime.Controls 1.0

Tab {
    title: "ArcGIS REST"

    Item {



    NetworkRequest {
        id: networkRequest
        url: "http://arcgis-server1022-2082234468.us-east-1.elb.amazonaws.com/arcgis/rest/services/MobileApps/Water_Leaks_VGI/FeatureServer"
        responseType: "json"
    }

    Flickable {
        anchors {
            fill:parent
            margins: 10 * AppFramework.displayScaleFactor
        }
        contentHeight: jsonText.height
        contentWidth: jsonText.width

        clip: true

        Text {
            id: jsonText
            clip: true
            text : JSON.stringify(networkRequest.response, undefined, 2)
        }
    }

    Component.onCompleted: {
        networkRequest.send( {"f":"pjson"} )
    }
        }
}
