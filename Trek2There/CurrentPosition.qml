/* Copyright 2016 Esri
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
import QtPositioning 5.3
import QtLocation 5.3

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0

//------------------------------------------------------------------------------

QtObject {
    id: currentPosition

    // PROPERTIES //////////////////////////////////////////////////////////////

    property var destinationCoordinate: null
    property var position
    property var positionCoordinate

    property KalmanCoordinate kalmanCoord: KalmanCoordinate{}
    property double kalmanLat
    property double kalmanLong
    property bool useKalman: false

    property double distanceToDestination: 0
    property double azimuthToDestination: NaN
    property double degreesOffCourse: 0
    property double etaSeconds: -1
    property date etaToDestination: new Date()

    property int minimumArrivalTimeInSeconds: 3 // seconds
    property double minimumAnticipatedSpeed: 1.4 // m/s
    property double maximumAnticipatedSpeed: 28 // m/s

    property int arrivalThresholdInMeters: 20 // TODO: Update arrival logic
    property int arrivalThresholdInSeconds: minimumArrivalTimeInSeconds

    signal atDestination()

    // SIGNALS /////////////////////////////////////////////////////////////////

    onPositionChanged: {
        calculate();
    }

    //--------------------------------------------------------------------------

    onAtDestination: {
        kalmanCoord.reset();
    }

    // METHODS /////////////////////////////////////////////////////////////////

    function clearData() {
        distanceToDestination = 0;
        azimuthToDestination = NaN;
        etaSeconds = -1;
    }

    //--------------------------------------------------------------------------

    function calculate() {

        positionCoordinate = position.coordinate;

        if(useKalman === true){
            var accuracy = (position.horizontalAccuracyValid === true) ? position.horizontalAccuracy : 0;
            var newCoord = kalmanCoord.process(positionCoordinate.latitude, positionCoordinate.longitude, accuracy, new Date().valueOf());
            kalmanLat = newCoord[0];
            kalmanLong = newCoord[1]
            positionCoordinate = QtPositioning.coordinate(kalmanLat,kalmanLong);
        }

        distanceToDestination = positionCoordinate.distanceTo(destinationCoordinate);

        if(distanceToDestination < arrivalThresholdInMeters ){
            atDestination();
        }

        azimuthToDestination = positionCoordinate.azimuthTo(destinationCoordinate);

        if (position.speedValid && position.speed > 0) {
            etaSeconds = distanceToDestination / position.speed;
            arrivalThresholdInSeconds = minimumArrivalTimeInSeconds * (position.speed / minimumAnticipatedSpeed);
            etaToDestination = new Date((new Date().valueOf()) + etaSeconds * 1000);
            if(etaSeconds < arrivalThresholdInSeconds){
                atDestination();
            }
        } else {
            etaSeconds = -1;
            arrivalThresholdInSeconds = minimumArrivalTimeInSeconds * 2;
            etaToDestination = new Date();
        }

        if (position.directionValid) {
            degreesOffCourse = (azimuthToDestination - position.direction);
        }
        else{
            degreesOffCourse = 0;
        }

        if(logTreks){
            // [timestamp, pos_lat, pos_long, pos_dir, klat, klong, az_to, dist_to, degrees_off]
            trekLogger.recordPosition([
                                          Date().valueOf(),
                                          positionCoordinate.latitude.toString(),
                                          positionCoordinate.longitude.toString(),
                                          ( (position.directionValid) ? position.direction.toString() : "invalid direction" ),
                                          ( (useKalman) ? kalmanLat.toString() : "kalman turned off" ),
                                          ( (useKalman) ? kalmanLong.toString() : "kalman turned off" ),
                                          azimuthToDestination.toString(),
                                          distanceToDestination.toString(),
                                          degreesOffCourse.toString()
                                      ]);
        }
    }
}
