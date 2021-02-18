/* Copyright 2021 Esri
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

import QtQml 2.12
import QtQuick 2.12
import QtQuick.Controls 2.13
import QtMultimedia 5.12

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Multimedia 1.0
import ArcGIS.AppFramework.Labs.TensorFlow 1.0

VideoOutput {
    id: videoOutput

    //--------------------------------------------------------------------------

    property alias model: imageAnalysisModel
    property alias filter: imageAnalysisFilter
    property bool debug
    property real minimumScore

    //--------------------------------------------------------------------------

    focus : visible
    fillMode: VideoOutput.PreserveAspectCrop
    autoOrientation: true
    
    filters: [ imageAnalysisFilter ]

    //--------------------------------------------------------------------------

    ImageAnalysisModel {
        id: imageAnalysisModel
    }

    //--------------------------------------------------------------------------

    ImageAnalysisFilter {
        id: imageAnalysisFilter

        interval: 250

        debug: videoOutput.debug

        analyzer {
            modelSource: imageAnalysisModel.source
            classNames: imageAnalysisModel.labels
            minimumScore: videoOutput.minimumScore
        }

        overlay {
            visible: imageAnalysisModel.modelType === "ObjectDetection" || !imageAnalysisModel.modelType || videoOutput.debug
            showInferenceTime: videoOutput.debug
            font {
                pixelSize: 15
                bold: true
                family: Qt.application.font
            }
            scale: videoOutput.sourceRect.height / videoOutput.contentRect.height
        }

        resultsModel {
            unique: false
        }

        cameraOrientation: videoOutput.source.orientation
        videoOrientation: videoOutput.orientation
    }

    //--------------------------------------------------------------------------
}
