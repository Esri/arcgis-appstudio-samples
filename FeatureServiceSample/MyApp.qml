//------------------------------------------------------------------------------

import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.1

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Runtime 1.0
import ArcGIS.AppFramework.Controls 1.0

App {
    id: app
    width: 400
    height: 640

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        RowLayout {
            Button {
                text: "Food & Dining"

                onClicked: {
                    featureLayer.definitionExpression = "AppCategory = 'Food_and_Dining'"
                    //featureServiceTable.definitionExpression = "AppCategory = 'Food_and_Dining'"
                    var query = ArcGISRuntime.createObject("Query");
                    query.where = "AppCategory = 'Food_and_Dining'";
                    featureServiceTable.queryFeatures(query);
                }

            }
            Button {
                text: "All"

                onClicked: {
                    featureLayer.definitionExpression = ""
                    featureServiceTable.definitionExpression = ""
                    var query = ArcGISRuntime.createObject("Query");
                    query.where = "1=1";
                    featureServiceTable.queryFeatures(query)
                }

            }

            Button {
                text: "Favs"

                onClicked: {
                    featureLayer.definitionExpression = "" + featureServiceTable.objectIdField + " IN (1,2,3,4,5,258454)";
                    //featureServiceTable.definitionExpression = "" + featureServiceTable.objectIdField + " IN (1,2,3,4,5,258454)"
                    var query = ArcGISRuntime.createObject("Query");
                    query.objectIds = [1,2,3,4,5,258454]
                    featureServiceTable.queryFeatures(query);
                }

            }


            Button {
                text: "Zoom"
                onClicked: {
                    if(featureServiceTable.valid) {
                        console.log(featureServiceTable.spatialReference.wkid);
                        console.log(JSON.stringify(featureLayer.extent.json))

                    }

                }
            }
        }

        Map {

            id: map

            height: parent.height*0.7
            width: parent.width

            onExtentChanged: {
                console.log(map.mapScale, map.resolution)
            }

            ArcGISTiledMapServiceLayer {
                url: "http://server.arcgisonline.com/arcgis/rest/services/World_Street_Map/MapServer"
            }


            Envelope {
                id: zoomEnvelope
                spatialReference: map.spatialReference
            }

            GeodatabaseFeatureServiceTable {
                id: featureServiceTable
                url: "http://services5.arcgis.com/IbKW6GIsAIHQ6AoD/ArcGIS/rest/services/SaverPOIs/FeatureServer/0"

                onFeatureTableStatusChanged: {
                    console.log("onFeatureTableStatusChanged: ", featureTableStatus)

                    if(featureTableStatus == Enums.FeatureTableStatusInitialized) {
                        map.zoomTo(featureServiceTable.extent);
                    }
                }

                onQueryFeaturesStatusChanged: {
                    //console.log("Status:", queryFeaturesStatus)
                }

                onQueryFeaturesResultChanged: {
                    if(queryFeaturesStatus == Enums.QueryFeaturesStatusCompleted) {
                        //console.log("Result changed: ", queryFeaturesStatus)
                        console.log("Total Count#:", queryFeaturesResult.featureCount);

                        model.clear();

                        var mp = ArcGISRuntime.createObject("MultiPoint");

                        var iterator = queryFeaturesResult.iterator;


                        while(iterator.hasNext()) {
                            var feature = iterator.next();
                            var geom = feature.geometry;
                            mp.add(geom);
                            var attributeNames = feature.attributeNames
                            var attr = {};
                            for (var i in attributeNames)
                            {
                                var attrName = attributeNames[i]
                                //console.log(attrName + " " + feature.attributeValue(attrName))
                                attr[attrName] = feature.attributeValue(attrName)
                            }
                            //console.log(JSON.stringify(attr));
                            console.log(iterator.hasNext())
                            model.append(attr);
                        }

                        var env = mp.queryEnvelope();
                        console.log("Point Count: ", mp.pointCount)
                        console.log(JSON.stringify(env.json));
                        console.log("-----------------------");

                        //console.log(map.resolution, )
                        var dxy = parseInt(map.resolution*1.2)

                        map.zoomTo(env)


                    }
                }

                onDefinitionExpressionChanged: {
                    console.log("definition expression changed: ", definitionExpression.toString());

                }


                onInitializationErrorChanged: {
                    console.log("Initialization error: ", initializationError)
                }
            }


            FeatureLayer {
                id:featureLayer
                //featureTable: featureServiceTable
                featureTable: featureServiceTable.valid ? featureServiceTable : null
                visible: true

                onSelectionChanged: {
                    console.log(selectionIds);
                }

                onFeatureTableChanged: {
                    console.log("Feature table changed")
                }
            }





        }

        Rectangle {
            height: parent.height*0.3
            width: parent.width

            ListModel {
                id: model
            }

            ListView {
                id: listView
                anchors.fill: parent
                orientation: ListView.Horizontal
                model: model
                spacing: 5
                clip: true
                snapMode: ListView.SnapOneItem
                delegate: Rectangle {
                    color: "yellow"
                    width: listView.width
                    height:parent.height
                    Text {
                        text: Title
                        width: parent.width
                        color: "black"
                        font.pointSize: 15
                    }

                }

            }
        }

    }
}

