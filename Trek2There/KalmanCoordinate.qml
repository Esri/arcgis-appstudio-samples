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

import QtQuick 2.0

QtObject {

    id: kalmanFilteredCoordinate

    // PROPERTIES //////////////////////////////////////////////////////////////

    readonly property double minAccuracy: 1

    property double metersPerSecond: 3
    property double latitude: 0
    property double longitude: 0
    property double variance: -1
    property var timeStampInMillseconds: null
    property var kalmanCoordinate: null

    // METHODS /////////////////////////////////////////////////////////////////

    function process(inLat, inLong, inAccuracy, inTimestamp){

        if(inAccuracy < minAccuracy){
            inAccuracy = minAccuracy;
        }

        if(variance < 0){ // Uninitilized
            timeStampInMillseconds = inTimestamp;
            latitude = inLat;
            longitude = inLong;
            variance = inAccuracy * inAccuracy;
        }
        else{
            var thisMomentInMilliseconds = inTimestamp - timeStampInMillseconds;

            if(thisMomentInMilliseconds > 0){

                variance += thisMomentInMilliseconds * metersPerSecond * metersPerSecond / 1000;

                timeStampInMillseconds = inTimestamp;

                // TODO: original developer suggests using speed here to better estimate current position
            }
        }

        var k = variance / (variance + inAccuracy * inAccuracy);

        latitude += k * (inLat - latitude);
        longitude += k * (inLong - longitude);

        kalmanCoordinate = [latitude, longitude];

        variance = (1 - k) * variance;

        return kalmanCoordinate;
    }

    //--------------------------------------------------------------------------

    function reset(){
        variance = -1;
        latitude = 0;
        longitude = 0;
        timeStampInMillseconds = null;
    }

}
