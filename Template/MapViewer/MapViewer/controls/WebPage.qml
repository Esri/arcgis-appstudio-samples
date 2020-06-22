import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.WebView 1.0

PopupPage {
    id: root

    property url link: ""
    property bool showCloseButton: true
    property real headerHeight: root.getAppProperty(app.headerHeight, root.units(56))

    signal closed ()

    contentItem: BasePage {

        width: parent.width
        height: parent.height

        header: ToolBar {

            id: header

            height: root.headerHeight
            width: parent.width

            RowLayout {
                anchors.fill: parent

                Icon {
                    visible: root.showCloseButton
                    imageSource: "images/close.png"

                    onClicked: {
                        root.close()
                    }
                }

                SpaceFiller {}

                Icon {
                    imageSource: "images/refresh.png"

                    onClicked: {
                        webItem.reload()
                    }
                }

                Icon {
                    imageSource: "images/openExternally.png"

                    onClicked: {
                        Qt.openUrlExternally(webItem.url)
                    }
                }
            }
        }

        contentItem: WebView {
            id: webItem

            anchors {
                top: header.bottom
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
            clip: true
        }
    }

    onVisibleChanged: {
        if (!visible) {
            closed()
        }
    }

    Component.onDestruction: {
    }

    function loadPage (url) {
        if(url) {
            webItem.url = url
            root.open()
        }
    }

    function getAppProperty (appProperty, fallback) {
        if (!fallback) fallback = ""
        try {
            return appProperty ? appProperty : fallback
        } catch (err) {
            return fallback
        }
    }

    function units (num) {
        return num ? num * AppFramework.displayScaleFactor : num
    }

}
