/* ******************************************
Copyright 2015 Esri

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and limitations under the License.​
******************************************* */

import QtQuick 2.3
import QtQuick.Controls 1.2
import QtPositioning 5.3

import ArcGIS.AppFramework 1.0

import "components"

App {
    id: app
    width: 350
    height: 500

    property double scaleFactor : AppFramework.displayScaleFactor
    property double mapScale: 80000
    property color headerBackgroundColor : "#4169e1"
    property color textColor : "#ffffff"
    property alias customTitleFont: titleFont
    property alias cusomTextFont: textFont

    property int baseFontSize: Math.min(20, 20 * app.scaleFactor)
    property int titleFontSize: baseFontSize * 1
    property int textFontSize: baseFontSize * 0.7

    //Google Analytics tracking - uncomment if needed
//    Tracking {
//        id: tracking
//        trackingId: app.info.itemId
//        appName: app.info.title
//        appVersion: app.info.version

//        Component.onCompleted: {
//            ready()
//        }
//    }


    Component.onCompleted: {
        console.log(JSON.stringify(AppFramework.network.defaultConfiguration, undefined, 2));
        console.log(JSON.stringify(AppFramework.network.addresses, undefined, 2));
    }


    FontLoader {
        id: titleFont
    }

    FontLoader {
        id: textFont
    }


    StackView {

        id: stackView

        anchors.fill: parent

        initialItem: landingPage
    }

    Component {
        id: landingPage
        LandingPage {
            textColor: textColor
            backGroundColor: "#ECECEC"
            headerColor: "white"
            buttonColor: app.headerBackgroundColor
            buttonText: "Lets Go!"
            titleText: "Quake App"
            titleFontPointSize: app.baseFontSize * 1.2
            width: stackView.width

            onDone: {
                stackView.push(mapPage);
            }
        }
    }

    Component {
        id: mapPage
        MapPage {

        }
    }

}

