import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Styles 1.4
import QtGraphicalEffects 1.0
import QtQuick.Controls.Material 2.1

import ArcGIS.AppFramework 1.0
import Esri.ArcGISRuntime 100.10


Item {

    property real scaleFactor: AppFramework.displayScaleFactor
    property real rotationValue: 0.0
    property int  scaleIndex: -1

    PointBuilder {
        id: ptBuilder
        spatialReference: Factory.SpatialReference.createWgs84()
    }

    EnvelopeBuilder {
        id: envBuilder
        spatialReference: Factory.SpatialReference.createWgs84()
    }

    MapView {
        id: mv
        anchors.fill: parent

        Map {
            BasemapOpenStreetMap {}
            initialViewpoint:springViewpoint
        }

        //Busy Indicator
        BusyIndicator {
            anchors.centerIn: parent
            height: 48 * scaleFactor
            width: height
            running: true
            Material.accent:"#8f499c"
            visible: (mv.drawStatus === Enums.DrawStatusInProgress)
        }
    }

    // Create the intial Viewpoint
    ViewpointExtent {
        id: springViewpoint
        extent: Envelope {
            xMin: -12338668.348591767
            xMax: -12338247.594362013
            yMin: 5546908.424239618
            yMax: 5547223.989911933
            spatialReference: SpatialReference { wkid: 102100 }
        }
    }

    ComboBox {
        id: comboBoxViewpoint
        anchors.left:  parent.left
        anchors.top:  parent.top
        anchors.margins: 10 * scaleFactor
        width: 200 * scaleFactor
        height: 30 * scaleFactor
        clip:true
        Material.accent:"#8f499c"
        background: Rectangle {
            radius: 6 * scaleFactor
            border.color: "darkgrey"
            width: 200 * scaleFactor
            height: 30 * scaleFactor
        }
        model: ["Animation","Center","Center and scale","Geometry","Geometry and padding","Rotation","Scale 1:5,000,000","Scale 1:10,000,000",]
        onCurrentTextChanged: {
            changeCurrentViewpoint();
        }

        function changeCurrentViewpoint()

        {
            switch (comboBoxViewpoint.currentText) {
            case "Center":
                ptBuilder.setXY(-117.195681, 34.056218); // Esri Headquarters
                mv.setViewpointCenter(ptBuilder.geometry);
                break;
            case "Center and scale":
                ptBuilder.setXY(-157.564, 20.677); // Hawai'i
                mv.setViewpointCenterAndScale(ptBuilder.geometry, 4000000.0);
                break;
            case "Geometry":
                envBuilder.setXY(117.380, 39.920, 116.400, 39.940); // Beijing
                mv.setViewpointGeometry(envBuilder.geometry);
                break;
            case "Geometry and padding":
                envBuilder.setXY(117.380, 39.920, 116.400, 39.940); // Beijing
                mv.setViewpointGeometryAndPadding(envBuilder.geometry, 200 * screenRatio());
                break;
            case "Rotation":
                rotationValue = (rotationValue + 45.0) % 360.0;
                mv.setViewpointRotation(rotationValue);
                break;
            case "Scale 1:5,000,000":
                mv.setViewpointScale(5000000.0);
                break;
            case "Scale 1:10,000,000":
                mv.setViewpointScale(10000000.0);
                break;
            case "Animation":
                mv.setViewpointWithAnimationCurve(springViewpoint, 4.0, Enums.AnimationCurveEaseInOutCubic);
                break;
            }
        }
    }

    function screenRatio() {
        var width = mv.mapWidth;
        var height = mv.mapHeight;
        return height > width ? width / height : height / width;
    }
}
