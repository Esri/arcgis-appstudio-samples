import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1

import "../controls" as Controls

ListView {
    id: contentView
    anchors.fill:parent
    footer:Rectangle{
        height:isIphoneX?120 * scaleFactor :100 * scaleFactor
        width:contentView.width
    }



    signal checked (string name, bool checked, int index)

    clip: true
    delegate: Controls.ContentPanelItem {
        txt: name
        isChecked: checkBox
        primaryColor: app.primaryColor
        accentColor: app.accentColor
        subLayersList:getSubLayers(sublayers)
        isVisible:isVisibleAtScale

        onChecked: {
            contentView.checked(name, checked, index)
        }
        property ListModel sublayersList : Controls.CustomListModel {}
        function getSubLayers(layers)
        {
            var sublayers = []
            if(layers)
            {
               sublayers = layers.split(',')

            sublayers.forEach(function(element){
                sublayersList.append({"layerName":element})
            }
                )
            }
            return sublayersList

        }
    }

    Controls.BaseText {
        id: message

        visible: model.count <= 0 && text > ""
        maximumLineCount: 5
        elide: Text.ElideRight
        width: parent.width
        height: parent.height
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        //text: qsTr("No layers to show.")
    }

}


