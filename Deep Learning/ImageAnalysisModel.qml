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

import ArcGIS.AppFramework 1.0

Item {
    id: modelInfo

    //--------------------------------------------------------------------------

    property url source
    property string modelType
    property var labels: []
    property var colors: ({})

    property string name
    property string description

    property bool debug

    //--------------------------------------------------------------------------

    LoggingCategory {
        id: logCategory

        name: AppFramework.typeOf(modelInfo, true)
    }

    //--------------------------------------------------------------------------

    onSourceChanged: {
        Qt.callLater(update);
    }

    //--------------------------------------------------------------------------

    function update() {
        var fileInfo = AppFramework.fileInfo(source);

        if (debug) {
            console.log(logCategory, arguments.callee.name, "source:", fileInfo.baseName, source);
        }

        if (fileInfo.folder.fileExists(fileInfo.baseName + ".emd")) {
            readEMD(fileInfo);
        } else {
            modelType = "";
        }

        if (fileInfo.folder.fileExists(fileInfo.baseName + ".txt")) {
            readLabels(fileInfo);
        }

        if (debug) {
            console.log(logCategory, "labels:", labels.length, JSON.stringify(modelInfo.labels, undefined, 2));
            console.log(logCategory, "colors:", JSON.stringify(modelInfo.colors, undefined, 2));
        }
    }

    //--------------------------------------------------------------------------

    function readEMD(fileInfo) {
        if (debug) {
            console.log(logCategory, arguments.callee.name, "Reading emd:", fileInfo.pathName);
        }

        var labels = [];
        var colors = {};

        var emd = fileInfo.folder.readJsonFile(fileInfo.baseName + ".emd");
        modelType = emd.ModelType || "";

        if (Array.isArray(emd.Classes)) {
            emd.Classes.forEach(function (modelClass, index) {
                labels.push(modelClass.Name);

                if (Array.isArray(modelClass.Color)) {
                    var color = Qt.rgba(modelClass.Color[0] / 255,
                                        modelClass.Color[1] / 255,
                                        modelClass.Color[2] / 255,
                                        1);

                    colors[modelClass.Name] = color;
                }
            });
        }

        modelInfo.labels = labels;
        modelInfo.colors = colors;
    }

    //--------------------------------------------------------------------------

    function readLabels(fileInfo) {
        if (debug) {
            console.log(logCategory, arguments.callee.name, "Reading txt labels");
        }

        var text = fileInfo.folder.readTextFile(fileInfo.baseName + ".txt");
        labels = text.split("\n").map(label => label.trim()).filter(label => label > "");

        modelInfo.labels = labels;
    }

    //--------------------------------------------------------------------------
}
