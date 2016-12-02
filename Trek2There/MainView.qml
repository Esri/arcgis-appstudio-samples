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

Item {

    id: mainView

    //--------------------------------------------------------------------------

    StackView {
        id: mainStackView
        anchors.fill: parent
        Layout.fillWidth: true
        Layout.fillHeight: true
        // initialItem: (showSafetyWarning === true || safteyWarningAccepted === false) ? disclaimerView : navigationView // disabled for v1.0
        initialItem: disclaimerView
    }

    //--------------------------------------------------------------------------

    Component{
          id: navigationView
          NavigationView{
              Layout.fillHeight: true
              Layout.fillWidth: true
          }
      }

    //--------------------------------------------------------------------------

    Component{
          id: disclaimerView
          DisclaimerView{
              Layout.fillHeight: true
              Layout.fillWidth: true
          }
      }

    //--------------------------------------------------------------------------

    Component{
        id: settingsView
        SettingsView{
            Layout.fillHeight: true
            Layout.fillWidth: true
        }
    }

    //--------------------------------------------------------------------------

    Component{
        id: aboutView
        AboutView{
            Layout.fillHeight: true
            Layout.fillWidth: true
        }
    }

    //--------------------------------------------------------------------------

}
