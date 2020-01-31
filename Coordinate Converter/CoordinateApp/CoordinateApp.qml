import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtPositioning 5.12
import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Sql 1.0

import "Styles"

Page {
    id: coordinateApp

    property var coordinate: QtPositioning.coordinate( 40.68921, -74.04466 )

    property FileFolder dataFolder: FileFolder { url: "Data" }
    property string parseText: ""
    property var parseOptions: null
    property var parseInfo: ( { } )
    property var parseSamples: dataFolder.readTextFile( "ParseSamples.txt" ).split( /\r?\n/ )

    property string convertFormat: "dd"
    property var convertOptions: null
    property var convertInfo: ( { } )
    property string convertText: ""

    property var mapSamples: JSON.parse( dataFolder.readTextFile( "MapSamples.txt" ) )

    ColumnLayout {
        anchors.fill: parent

        TabBar {
            id: tabBar

            Layout.fillWidth: true

            NormalTabButton {
                text: qsTr( "Parse" )
            }

            NormalTabButton {
                text: qsTr( "Convert" )
            }

            NormalTabButton {
                text: qsTr( "Map" )
            }
        }

        StackLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true

            currentIndex: tabBar.currentIndex

            CoordinateParsePage {
            }

            CoordinateConvertPage {
            }

            MapPage {
            }
        }
    }

    Styles {
        id: styles
    }

    AppToast {
        id: toast

        background: "#8f499c"
        color: "white"
        font.pointSize: 12

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 20
    }

    function copyToClipboard( text, info )
    {
        AppFramework.clipboard.copy( text );
        toast.show( info );
    }

    function updateConvertInfo()
    {
        convertInfo = convertOptions ?
                    Coordinate.convert( coordinate, convertFormat, convertOptions ) :
                    Coordinate.convert( coordinate, convertFormat );
    }

    function convertInfoToText( info )
    {
        if ( !info.formatValid )
        {
            return "";
        }

        switch ( info.format )
        {

        case "dd":
            return "%1 %2"
                .arg( info.dd.latitudeText  )
                .arg( info.dd.longitudeText  );

        case "ddm":
            return "%1 %2"
                .arg( info.ddm.latitudeText  )
                .arg( info.ddm.longitudeText  );

        case "dms":
            return "%1 %2"
                .arg( info.dms.latitudeText  )
                .arg( info.dms.longitudeText  );

        case "srs":
            return "SRID=%1 %2 %3"
                .arg( info.srs.srid )
                .arg( info.srs.x.toFixed( 8 ) )
                .arg( info.srs.y.toFixed( 8 ) );

        case "utm":
            return "%1%2 %3 %4"
                .arg( info.utm.zone )
                .arg( info.utm.band )
                .arg( info.utm.easting.toFixed( 0 ) )
                .arg( info.utm.northing.toFixed( 0 ) );

        case "universalGrid":
            switch ( info.universalGrid.type )
            {
            case "UTM":
                return "UTM %1%2 %3 %4"
                    .arg( info.universalGrid.zone )
                    .arg( info.universalGrid.band )
                    .arg( info.universalGrid.easting.toFixed( 0 ) )
                    .arg( info.universalGrid.northing.toFixed( 0 ) );
            case "UPS":
                return "UPS %1 %2 %3"
                    .arg( info.universalGrid.band )
                    .arg( info.universalGrid.easting.toFixed( 0 ) )
                    .arg( info.universalGrid.northing.toFixed( 0 ) );
            default:
                return "";
            }

        case "ups":
            return "%1 %2 %3"
                .arg( info.ups.band )
                .arg( info.ups.easting.toFixed( 0 ) )
                .arg( info.ups.northing.toFixed( 0 ) );

        case "mgrs":
            return info.mgrs.text;

        }

        return "";
    }

}

