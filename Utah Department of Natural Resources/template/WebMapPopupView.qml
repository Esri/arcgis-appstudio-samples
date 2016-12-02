import QtQuick 2.2
import QtQuick.Controls 1.2

import ArcGIS.AppFramework.Runtime 1.0
import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0

import "WebMap.js" as JS

Rectangle {
    id: featurePopupView

    property var popupInfo
    property var attributes
    property string linkText
    property string title: JS.replaceVariables(popupInfo.title, attributes)
    property bool titleVisible: true

    width: 200
    height: 400

    color: "transparent"

//    onAttributesChanged: {
//        console.log(JSON.stringify(attributes, undefined, 2));
//    }

    Flickable {
        id: flickable

        anchors {
            fill: parent
            margins: 5
        }

        contentWidth: popupContent.width
        contentHeight: popupContent.height
        flickableDirection: Flickable.VerticalFlick
        clip: true

        Column {
            id: popupContent

            width: flickable.width
            spacing: 4

            // Title

            Text {
                id: titleText

                visible: titleVisible && text > ""
                width: parent.width

                text: title

                font {
                    pointSize: 16
                    bold: true
                }
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap
                elide: Text.ElideRight
            }

            Rectangle {
                visible: titleText.visible
                width: parent.width
                height: 1
                color: "darkgrey"
            }

            // Attribute fields

            Repeater {
                model: popupInfo.fieldInfos

                delegate: WebMapPopupFieldItem {
                    width: featurePopupView.width
                    fieldInfo: modelData
                    attributes: featurePopupView.attributes
                    linkText: featurePopupView.linkText
                }
            }

            // Media infos

            Repeater {
                model: popupInfo.mediaInfos

                delegate: WebMapPopupMediaItem {
                    width: featurePopupView.width
                    mediaInfo: modelData
                    attributes: featurePopupView.attributes
                }
            }

            // Attachments
        }
    }

    //--------------------------------------------------------------------------
}
