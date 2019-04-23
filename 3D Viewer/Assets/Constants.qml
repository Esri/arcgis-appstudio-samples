import QtQuick 2.9

import ArcGIS.AppFramework 1.0

Item {
    id: root

    readonly property string q_filter: "-type:\"Code Attachment\" -type:\"Featured Items\" -type:\"Symbol Set\" -type:\"Color Set\" -type:\"Windows Viewer Add In\" -type:\"Windows Viewer Configuration\" -type:\"Map Area\" -typekeywords:\"MapAreaPackage\""

    // Screen scale factor
    readonly property real scaleFactor: AppFramework.displayScaleFactor

    // Item loading number
    readonly property int loadingNumber: 16

    // Animation
    readonly property int normalDuration: 250
    readonly property int fastDuration: 250
}
