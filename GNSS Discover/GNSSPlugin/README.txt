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


//------------------------------------------------------------------------------


/*
The QML components in the GNSSPlugin directory provide an easy way to manage,
connect to, and configure external GNSS providers. The plugin provides five
main components:

GNSSManager - This component manages the connection to external GNSS providers,
provides position updates, and displays error or warning messages. (REQUIRED)

GNSSSettingsPages - This component provides the GNSS settings UI. (REQUIRED)

GNSSSettingsButton - A button that opens the GNSS settings UI. (OPTIONAL)

GNSSStatusPages - This component provides the GNSS status UI. (OPTIONAL)

GNSSStatusButton - A button that indicates the connection status and opens
the GNSS status UI. Note that the status button will only be visible if the
GNSSManager has been started and is connected to a location provider. (OPTIONAL)

The following steps are required to make use of the GNSSPlugin:

1) Import the QML components:

    import "./GNSSPlugin"

2) Instantiate the main components and connect them with each other. The
GNSSManager and GNSSSettingsPages are required, the GNSSStatusPages component
is optional.

    GNSSManager {
        id: gnssManager

        gnssSettingsPages: gnssSettingsPages
    }

    GNSSSettingsPages {
        id: gnssSettingsPages

        gnssManager: gnssManager
    }

    GNSSStatusPages {
        id: gnssStatusPages

        gnssManager: gnssManager
        gnssSettingsPages: gnssSettingsPages
    }

All the main components above allow for customisation of various aspects of the
UI such as colors, spacings, font styles, and others. Refer to the respective
components to see which properties can be modified. If your app uses a StackView
assign a reference to it to the 'stackView' property of the GNSSSettingsPages
and the GNSSStatusPages.

3) Instantiate the optional UI access buttons and connect with the respective
UI pages:

    GNSSSettingsButton {
        gnssSettingsPages: gnssSettingsPages
    }

    GNSSStatusButton {
        gnssStatusPages: gnssStatusPages
    }

The UI pages may also be displayed directly without using the buttons by calling:

    gnssSettingsPages.showLocationSettings()
    gnssStatusPages.showGNSSStatus()

If your app uses a StackView pass a reference to it to these methods.

4) If you are using the MapView component of the Esri ArcGISRuntime you can
directly set the GNSSManager as the position source to receive position updates:

    import Esri.ArcGISRuntime 100.8

    MapView {
        locationDisplay {
            dataSource: DefaultLocationDataSource {
                positionInfoSource: gnssManager
            }
        }

        // ... set the Map and MapView properties ...

        // start the location display
        Component.onCompleted: locationDisplay.start()
    }

5) If you use the QtLocation Map QML component or if you need to know the current
position for further processing call

    gnssManager.start()
    gnssManager.stop()

to start/stop the position source and connect to the last used location provider.

You can retrieve the current position by listening to the 'onNewPosition' signal
of the GNSSManager:

    Connections {
        target: gnssManager

        function onNewPosition(position) {
            // ... do something, e.g. update Map centre ...
            // the 'position' parameter contains the current position
        }
    }
*/


//------------------------------------------------------------------------------
