import QtQuick 2.7
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1

import ArcGIS.AppFramework 1.0

Page {
    id:page

    Loader{
        id: loader
        anchors.fill: parent
    }

    footer:TabBar {
        Material.background: app.appBackgroundColor
        Material.accent: app.accentColor
        padding: 0
        Repeater {
            model: tabViewModel
            TabButton {
                text: name
            }
        }
        onCurrentIndexChanged: {
            navigateToPage(currentIndex);
        }
    }

    function navigateToPage(index){

        switch(index){
        case 0:
            loader.sourceComponent = page1ViewPage;
            break;
        case 1:
            loader.sourceComponent = page2ViewPage;
            break;
        case 2:
            loader.sourceComponent = page3ViewPage;;
            break;
        case 3:
            loader.sourceComponent = page4ViewPage;;
            break;
        default:
            break;
        }

    }
}
