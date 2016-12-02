import QtQuick 2.2
import QtQuick.Controls 1.1
import QtQuick.Window 2.0

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import ArcGIS.AppFramework.Runtime 1.0


DockPanel {
    id: actionsPanel

    property WebMap webMap

    leftEdge: parent.left
    rightEdge: parent.right
    topEdge: banner.bottom
    bottomEdge: parent.bottom
    lockRight: false
    landscape: true

    visibleHeight: parent.height
    visibleWidth: Math.min(app.width * 0.5, app.sidePanelWidth)

    color: "#e04c4c4c"

    border {
        width: 1
        color: "grey"
    }

    //--------------------------------------------------------------------------

    function hide() {
        actionsButton.checked = false;
    }

    //--------------------------------------------------------------------------

    MouseArea {
        anchors {
            fill: parent
        }

        onClicked: {
            hide();
        }
    }

    //--------------------------------------------------------------------------

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

            ActionItem {
                visible: !app.singleMap
                image:"images/collections.png"
                text: "Map Gallery"

                onClicked: {
                    stackView.pop();
                }
            }

            ActionItem {
                image:"images/legend.png"
                text: "Legend"
                // visible: legendPanel.view.model.count > 0

                onClicked: {
                    legendPanel.show = true;
                }
            }

            ActionItem {
                image:"images/bookmarks2.png"
                text: qsTr("Bookmarks")
                visible: typeof webMap.webMapInfo.bookmarks === 'object'

                onClicked: {
                    bookmarksPanel.show = true;
                }
            }

            ActionItem {
                image:"images/info2.png"
                text: "About this map"

                onClicked: {
                    stackView.push(mapAboutPage);
                }
            }

            SeparatorLine {
                visible: feedbackAction.visible
            }

            ActionItem {
                id: feedbackAction

                property string label: app.info.propertyValue("feedbackLabel", qsTr("Feedback"))
                property string url: app.info.propertyValue("feedbackUrl")

                text: label
                image: "images/feedback.png"
                visible: url > ""

                onClicked: {
                    console.log("feedback", url);

                    Qt.openUrlExternally(url);
                }
            }

            SeparatorLine {
            }

            ActionItem {
                image:"images/exit.png"
                text: ""

                onClicked: {
                    stackView.pop(null);
                }
            }
        }
    }

    //--------------------------------------------------------------------------
}
