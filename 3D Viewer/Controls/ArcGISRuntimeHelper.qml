import QtQuick 2.9

import Esri.ArcGISRuntime 100.5

Item {
    id: root

    function changePointToLatitudeLongitude(point, format, decimalPlaces, type) {
        return formatCoordinates(CoordinateFormatter.toLatitudeLongitude(point, format, decimalPlaces), type);
    }

    function formatCoordinates(text, type) {
        var _array = text.split(" ");

        switch (type) {
        case "DMS":
            text = "%1° %2' %3  %4° %5' %6".arg(_array[0]).arg(_array[1]).arg(_array[2]).arg(_array[3]).arg(_array[4]).arg(_array[5]);
            break;

        default:
            console.error("Error in ArcGISRuntimeHelper formatCoordinates type %1 is not supported.".arg(type));
            break;
        }

        var _directions = ["N", "S", "E", "W"]

        for (var i = 0; i < _directions.length; i++) {
            var _direction = _directions[i];

            text = text.replace(_direction, " %1".arg(_direction));
        }

        return text;
    }

    function setCamera(sceneView, camera) {
        sceneView.setViewpointCameraAndSeconds(camera, constants.normalDuration / 100);
    }

    function cameraRotateAround(sceneView, point, deltaRotation) {
        var _camera = sceneView.currentViewpointCamera.rotateAround(
                    point,
                    deltaRotation.heading,
                    deltaRotation.pitch,
                    deltaRotation.roll);

        setCamera(sceneView, _camera);
    }

    function cameraRotateTo(sceneView, rotation) {
        var _camera = sceneView.currentViewpointCamera.rotateTo(
                    rotation.heading,
                    rotation.pitch,
                    rotation.roll
                    );

        setCamera(sceneView, _camera);
    }

    function calculateDistanceBetweenPoints(point1, point2, distanceUnit, angularUnit, geodeticCurveType) {
        point1 = GeometryEngine.project(point1, SpatialReference.createWebMercator());
        point2 = GeometryEngine.project(point2, SpatialReference.createWebMercator());

        return GeometryEngine.distanceGeodetic(point1, point2, distanceUnit, angularUnit, geodeticCurveType);
    }

    function convertUnit(value, unit) {
        var _value = value;

        switch (unit) {
        case "m":
            return _value.toFixed(2);

        case "km":
            _value = _value / 1000;
            return _value < 10000000 ? _value.toFixed(2) : _value.toExponential(3);
        }
    }

    function createCamera(camera, wkid) {
        var _cameraPosition = camera.position;

        var _point = ArcGISRuntimeEnvironment.createObject(
                    "Point", {
                        x: _cameraPosition.x,
                        y: _cameraPosition.y,
                        z: _cameraPosition.z,
                        spatialReference: ArcGISRuntimeEnvironment.createObject(
                                              "SpatialReference", {
                                                  wkid: _cameraPosition.spatialReference.wkid
                                              })
                    })

        var _location = GeometryEngine.project(
                    _point, ArcGISRuntimeEnvironment.createObject(
                        "SpatialReference", {
                            wkid: wkid
                        }));

        var _heading = camera.heading;
        var _pitch = camera.tilt;

        return ArcGISRuntimeEnvironment.createObject(
                    "Camera", {
                        heading: _heading,
                        pitch: _pitch,
                        roll: 0,
                        location: _location
                    })
    }
}
