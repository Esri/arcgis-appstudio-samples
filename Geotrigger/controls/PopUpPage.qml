import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0
import QtQuick.Controls.Material 2.1

import ArcGIS.AppFramework 1.0

Rectangle {
    id:popUp
    anchors.fill: parent
    color: "#80000000"

    MouseArea {
        anchors.fill: parent
        onClicked: {
            mouse.accepted = false
        }
    }

    Rectangle {
        id:popUpWindow
        height: 200 * scaleFactor
        width: 280 * scaleFactor
        anchors.centerIn: parent
        radius: 3 * scaleFactor
        Material.background:  "#FAFAFA"
        Material.elevation:24

        Text {
            id: titleText
            text: qsTr("Choose a sample")
            font{
                pixelSize:app.baseFontSize
                bold:true
            }
            padding: 24 * scaleFactor
            anchors.top:parent.top
            anchors.bottom:popUpListView.top
        }

        ListView{
            id:popUpListView
            anchors.topMargin: 64 * scaleFactor
            anchors.fill: parent
            model:ListModel {
                id:sampleItems

                ListElement {
                    name:"Simulated Path";
                    url:"../samples/SimulatedPath.qml";
                    description:
                        "   <p>
                                This sample demonstrates how geotriggers work using a simulated path as the location data source. Click any garden section or point of interest buttons to view the feature's information.
                            </p>
                            <p>
                                To learn more about Geotriggers, check out the documentation for ArcGIS Runtime API for Qt,
                                    <a href='https://developers.arcgis.com/qt/device-location/work-with-geotriggers/'>
                                        <span style='text-decoration: underline; color:#0000ff;'>
                                            Work With Geotriggers
                                        </span>
                                    </a>,
                                and the QML sample this application is based on,
                                    <a href='https://developers.arcgis.com/qt/qml/sample-code/set-up-location-driven-geotriggers/'>
                                        <span style='text-decoration: underline; color:#0000ff;'>Set up Location-Driven Geotriggers</span>
                                    </a>.
                            </p>
                            <p>
                                Note: AppStudio 5.2 or higher is required.
                            </p>
                            <p>
                                <a href='https://geonet.esri.com/groups/appstudio/blog/2016/12/06/how-to-describe-our-resources-in-terms-of-difficulty-complexity-and-time-to-digest'>
                                    <span style='text-decoration: underline; color:#0000ff;'>
                                        Resource Level:
                                    </span>
                                </a> 🍌🍌
                            </p>"
                }

                ListElement {
                    name:"Current Device Location";
                    url:"../samples/CurrentDeviceLocation.qml";
                    description:
                        "   <p>
                                This sample demonstrates how geotriggers work using current device location as the location data source. Move near a feature to trigger the geotrigger notification event and click the button to display that feature's information.
                                Features are queried within a set radius distance. After moving half the raidus distance from the initial location, features will be queried again using the new location.
                            </p>
                            <p>
                                To learn more about Geotriggers, check out the documentation for ArcGIS Runtime API for Qt,
                                    <a href='https://developers.arcgis.com/qt/device-location/work-with-geotriggers/'>
                                        <span style='text-decoration: underline; color:#0000ff;'>
                                            Work With Geotriggers
                                        </span>
                                    </a>,
                                and the QML sample this application is based on,
                                    <a href='https://developers.arcgis.com/qt/qml/sample-code/set-up-location-driven-geotriggers/'>
                                        <span style='text-decoration: underline; color:#0000ff;'>Set up Location-Driven Geotriggers</span>
                                    </a>.
                            </p>
                            <p>
                                Note: AppStudio 5.2 or higher is required.
                            </p>
                            <p>
                                <a href='https://geonet.esri.com/groups/appstudio/blog/2016/12/06/how-to-describe-our-resources-in-terms-of-difficulty-complexity-and-time-to-digest'>
                                    <span style='text-decoration: underline; color:#0000ff;'>
                                        Resource Level:
                                    </span>
                                </a> 🍌🍌
                            </p>"
                    }

            }

            onCurrentIndexChanged: {
                qmlfile = sampleItems.get(currentIndex).url
                sampleName = sampleItems.get(currentIndex).name
                descriptionText =sampleItems.get(currentIndex).description
            }
            delegate: Rectangle{
                width:280 * scaleFactor
                height: 40 * scaleFactor
                color: index===popUpListView.currentIndex? "#808c499c":"transparent"

                Label{
                    anchors.verticalCenter: parent.verticalCenter
                    padding: 24 * scaleFactor
                    font {
                        pixelSize: app.baseFontSize * 0.8
                    }
                    text:name
                }

                MouseArea{
                    anchors.fill:parent
                    onClicked: {
                        popUp.visible = 0
                        popUpListView.currentIndex = index
                        qmlfile = sampleItems.get(index).url
                        sampleName = sampleItems.get(index).name
                        descriptionText =sampleItems.get(index).description
                    }
                }
            }

            Text{
                id:cancelText
                anchors.bottom: parent.bottom
                anchors.right:parent.right
                anchors.bottomMargin: 13 * scaleFactor
                anchors.rightMargin: 16 * scaleFactor
                text:qsTr("CANCEL")
                color:"#8f499c"
                font{
                    pixelSize: baseFontSize * 0.9
                    bold:true
                }

                MouseArea{
                    anchors.fill: parent
                    onClicked :{
                        popUp.visible = 0
                    }
                }
            }
        }
    }

    DropShadow {
        id: headerbarShadow
        source: popUpWindow
        anchors.fill: popUpWindow
        width: source.width
        height: source.height
        cached: true
        radius: 8.0
        samples: 17
        color: "#80000000"
        smooth: true
    }
}




