import QtQuick 2.2
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.1
import QtMultimedia 5.2
import Qt.labs.folderlistmodel 2.1

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import ArcGIS.AppFramework.Runtime 1.0

Rectangle {
    Layout.alignment: Qt.AlignTop
    Layout.fillHeight: true
    //color: app.pageBackgroundColor
    color: "transparent"
    Layout.preferredWidth: parent.width
    Layout.preferredHeight: parent.height - createPage_headerBar.height


    // Attribute fields


//    IntValidator{
//        id: intValidator
//    }
//    DoubleValidator{
//        id: dblValidator
//        notation: DoubleValidator.StandardNotation
//    }
//    function setValidatorValues(chosenValidator){

//    }

    AttributesPage {
        id: attributesListView

        width: Math.min(parent.width-20*app.scaleFactor, 400*app.scaleFactor)
        height: 50*app.scaleFactor
        anchors.topMargin: 20 * app.scaleFactor
        anchors.bottomMargin: 20 * app.scaleFactor
        anchors.horizontalCenter: parent.horizontalCenter
//        color: "transparent"
    }


}
