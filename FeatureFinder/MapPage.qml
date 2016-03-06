import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.1
import QtQuick.Controls.Styles 1.3

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import ArcGIS.AppFramework.Runtime 1.0
import ArcGIS.AppFramework.Runtime.Controls 1.0

import "components"

Item {
    property string queryField: "PARCELID"

    Envelope {
        id: extent
        xMin: -9814842.76890117
        yMin: 5125201.006590235
        xMax: -9810642.951896958
        yMax: 5129088.380780631
    }

    Map {
        id: map

        anchors.fill: parent

        wrapAroundEnabled: true
        zoomByPinchingEnabled: true
        extent: extent

        ArcGISTiledMapServiceLayer {
            url: "http://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer"
        }

        ArcGISFeatureLayer {
            id: featLayer
            url: "http://tryitlive.arcgis.com/arcgis/rest/services/TaxParcelQueryIL/MapServer/0"
            selectionColor: "red"

            onQueryFeaturesStatusChanged: {
                if (queryFeaturesStatus === Enums.QueryFeaturesStatusCompleted) {
                    var filterValuesList = []
                    for (var i = 0; i < queryFeaturesResult.count; i++) {
                        filterValuesList.push(queryFeaturesResult.graphics[i].attributes[queryField])
                    }

                    // Update list of values in search box with list
                    featureFinder.updateValuesList(filterValuesList)
                }
            }

            onSelectFeaturesStatusChanged: {
                if (selectFeaturesStatus === Enums.SelectFeaturesStatusCompleted) {
                    var geom = selectFeaturesResult.graphics[0].geometry
                    map.zoomToScale(5000)
                    map.panTo(geom)
                }
            }
        }

        Query {
            id: queryAttr
            returnGeometry: false
            outFields: queryField
            maxFeatures: 100
        }

        Query {
            id: queryGeom
            returnGeometry: true
            maxFeatures: 1
        }

        FeatureFinder {
            id: featureFinder
            height: 40*scaleFactor
            width: parent.width - (40*app.scaleFactor)

            // Optional properties
            searchBoxPlaceHolderText: "Parcel ID"
            fontFamilyName: app.fontSourceSansProReg.name

            anchors {
                top: parent.top
                topMargin: 15*app.scaleFactor
                horizontalCenter: parent.horizontalCenter
            }

            onTextEntered: {
                // Query feature layer for list of possible values
                queryAttr.where = queryField + " LIKE '" + text + "%'"
                featLayer.queryFeatures(queryAttr)
            }

            onItemClicked: {
                // Zoom to feature
                itemChosen(text)
            }

            onReturnPressed: {
                // Zoom to feature
                itemChosen(text)
            }

            onClearText: {
                // Empty filtered list
                updateValuesList([])
                // Clear selection
                featLayer.clearSelection()
            }
        }
    }

    function itemChosen(text) {
        // Clear selection
        featLayer.clearSelection()
        // Select feature
        queryGeom.where = queryField + " = '" + text + "'"
        featLayer.selectFeatures(queryGeom, Enums.SelectionMethodNew)

        // Re-set search box text
        featureFinder.resetSearchBox(text)
    }
}

