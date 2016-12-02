import QtQuick 2.2
import QtQuick.Controls 1.1
import QtQuick.Window 2.0

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import ArcGIS.AppFramework.Runtime 1.0


Rectangle {
    id: aboutPage

    property StackView stackView

    color: "#f7f8f8"

    //--------------------------------------------------------------------------

    TitleBar {
        id: titleBar

        title: webMap.itemInfo.title

        backButton {
            visible: true

            onClicked: {
                stackView.pop();
            }
        }
    }

    //--------------------------------------------------------------------------

    TabView {

        anchors {
            left: parent.left
            right: parent.right
            top: titleBar.bottom
            bottom: parent.bottom
        }

        Component.onCompleted: {
            addTab(qsTr("About"), aboutTab);

            if (webMap.itemInfo.licenseInfo > "" || webMap.itemInfo.accessInformation > "") {
                addTab(qsTr("Usage"), usageTab);
            }
        }

    }

    //--------------------------------------------------------------------------

    Component {
        id: aboutTab

        Item {
            Flickable {
                id: flickableDescription

                anchors {
                    fill: parent
                    margins: 10
                }

                contentWidth: descriptionContent.width
                contentHeight: descriptionContent.height
                flickableDirection: Flickable.VerticalFlick
                clip: true

                Column {
                    id: descriptionContent

                    width: flickableDescription.width
                    spacing: 10

                    Text {
                        id: infoText

                        width: parent.width

                        text: webMap.itemInfo.description
                        textFormat: Text.RichText
                        font {
                            pointSize: 16
                        }

                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        elide: Text.ElideRight

                        onLinkActivated: {
                            Qt.openUrlExternally(link);
                        }
                    }
                }
            }
        }
    }

    Component {
        id: usageTab


        Item {
            Flickable {
                id: flickableCredits

                anchors {
                    fill: parent
                    margins: 10
                }

                contentWidth: creditsContent.width
                contentHeight: creditsContent.height
                flickableDirection: Flickable.VerticalFlick
                clip: true

                Column {
                    id: creditsContent

                    width: flickableCredits.width
                    spacing: 10

                    AboutInfoText {
                        headingText: qsTr("Access and Use Constraints")
                        text: webMap.itemInfo.licenseInfo
                        html: true
                    }

                    AboutInfoText {
                        headingText: qsTr("Credits")
                        text: webMap.itemInfo.accessInformation
                    }
                }
            }
        }
    }
}
