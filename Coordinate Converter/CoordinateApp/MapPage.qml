import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtPositioning 5.12
import QtLocation 5.12

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Sql 1.0

import "Styles"

Page {
    id: mapPage

    property string errorMessage: ""

    onVisibleChanged: {
        if ( visible ) {
            map.center = coordinate;
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10

        NormalComboBox {
            id: inputCoordinates

            Layout.fillWidth: true

            editable: true
            model: mapSamples
            textRole: "text"

            delegate: Item {
                height: rowLayout.height
                width: parent.width

                RowLayout {
                    id: rowLayout

                    width: parent.width

                    ItemDelegate {
                        Layout.fillWidth: true

                        text: modelData.text
                    }

                    ItemDelegate {
                        text: modelData.label
                    }
                }

                MouseArea {
                    anchors.fill: parent

                    onClicked: {
                        inputCoordinates.popup.close();
                        inputCoordinates.currentIndex = index;
                        Qt.callLater( () => {
                                         parseText = modelData.text;
                                         parseInput();
                                         map.zoomLevel = 16;
                                     } );
                    }
                }
            }

            /*
            onCurrentTextChanged: {
                if ( currentIndex === -1 ) {
                    return;
                }

                parseText = currentText;
                parseInput();
            }
            */

            onAccepted: {
                parseText = editText;
                parseInput();
            }
        }

        NormalText {
            Layout.fillWidth: true
            text: errorMessage
            color: "red"
            visible: errorMessage !== ""
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }

        Map {
            id: map

            Layout.fillWidth: true
            Layout.fillHeight: true

            plugin: Plugin {
                preferred: [ "AppStudio" ]
            }

            activeMapType: supportedMapTypes[0]
            zoomLevel: 14

            onCopyrightLinkActivated: Qt.openUrlExternally(link);

            onCenterChanged: convert()

            MapQuickItem {
                anchorPoint.x: image.width / 2
                anchorPoint.y: image.height

                coordinate: coordinateApp.coordinate

                sourceItem: Image {
                    id: image

                    width: 26 * AppFramework.displayScaleFactor
                    height: 48 * AppFramework.displayScaleFactor
                    source: "Images/pin.png"
                    fillMode: Image.PreserveAspectFit
                    opacity: 0.8
                }
            }
        }

        Flow {
            Layout.fillWidth: true

            spacing: 10
            clip: true

            Heading3Label {
                text: qsTr( "Pin coordinates:" )
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            }

            NormalText {
                text: convertText
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            }
        }

    }

    function convert()
    {
        coordinate = QtPositioning.coordinate(
                    map.center.latitude,
                    map.center.longitude );
        convertInfo = convertOptions ?
                    Coordinate.convert( coordinate, convertFormat, convertOptions ) :
                    Coordinate.convert( coordinate, convertFormat );
        convertText = convertInfoToText( convertInfo );
        parseText = convertText;
    }

    function parseInput()
    {
        errorMessage = "";
        parseInfo = parseOptions ?
                Coordinate.parse( parseText, parseOptions ) :
                Coordinate.parse( parseText );
        if ( !parseInfo.coordinateValid )
        {
            errorMessage = qsTr( "Invalid coordinate, try again!" );
            return;
        }
        coordinate = QtPositioning.coordinate(
                    parseInfo.coordinate.latitude,
                    parseInfo.coordinate.longitude );
        map.center = coordinate;
    }
}
