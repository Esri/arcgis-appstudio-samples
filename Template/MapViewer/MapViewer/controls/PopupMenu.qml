import QtQuick 2.7
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1

import ArcGIS.AppFramework 1.0

Popup {
    id: root

    property var menuItems: []
    property real defaultMargin: root.units(16)
    property color backgroundColor: "#F7F8F8"
    property color highlightColor: Qt.darker(backgroundColor, 1.1)
    property color textColor: "#F7F8F8"
    property color primaryColor: "#166DB2"
    property int defaultContentWidth: 0
    property int maxWidth: units(200)
    property int minWidth: units(130)
    property bool isInteractive:true

    signal menuItemSelected (string itemLabel)

    leftPadding: 0
    rightPadding: 0

    width: defaultContentWidth

    ListView {
        anchors.fill: parent
        model: menuModel
        interactive: isInteractive
        delegate:  Card {
            id: menuItem

            headerHeight: 0
            footerHeight: 0
            padding: 0
            spacing: root.defaultMargin
            highlightColor: root.highlightColor
            backgroundColor: root.backgroundColor
            height: label.contentHeight + root.defaultMargin
            propagateComposedEvents: false
            preventStealing: false
            mouseAccepted: true
            Material.elevation: 0

            content: Pane {
                anchors.fill: parent
                leftPadding: root.defaultMargin
                rightPadding: root.defaultMargin
                topPadding: 0
                bottomPadding: 0

                RowLayout {
                    anchors.fill: parent

                    BaseText {
                        id: label

                        text: itemLabel
                        verticalAlignment: Text.AlignVCenter
                        color: typeof (lcolor) !== "undefined" ? lcolor:root.textColor
                        maximumLineCount: 2
                        Layout.fillWidth: true
                        elide: Text.ElideRight

                        onContentWidthChanged: {
                            if (root.defaultContentWidth < contentWidth) {
                                if (contentWidth < minWidth) {
                                    root.defaultContentWidth = minWidth + 2 * defaultMargin
                                } else if (contentWidth > maxWidth) {
                                    root.defaultContentWidth = maxWidth + 2 * defaultMargin
                                } else {
                                    root.defaultContentWidth = contentWidth + 2 * defaultMargin
                                }
                            }
                        }
                    }
                }
            }

            onClicked: {
                menuItemSelected(itemLabel)
            }
        }
    }

    ListModel {
        id: menuModel
    }

    onMenuItemSelected: {
        close()
    }

    onVisibleChanged: {
        if (visible) {
            updateMenu()
        }
    }

    function updateMenu () {
        menuModel.clear()
        for (var i=0; i<root.menuItems.length; i++) {
            menuModel.append(root.menuItems[i])
        }
    }

    function appendUniqueItemToMenuList (item, keyCheck) {
        if (!keyCheck) keyCheck = "itemLabel"
        var hasItem = false
        for (var i=0; i<menuItems.length; i++) {
            if (menuItems[i][keyCheck] === item[keyCheck]) {
                hasItem = true
                break
            }
        }
        if (!hasItem) menuItems.push(item)
    }

    function removeItemFromMenuList (item, keyCheck) {
        if (!keyCheck) keyCheck = "itemLabel"
        var newList = []
        for (var i=0; i<menuItems.length; i++) {
            if (menuItems[i][keyCheck] === item[keyCheck]) continue
            newList.push(menuItems[i])
        }
        menuItems = newList
    }

    function appendItemsToMenuList (items) {
        root.menuItems = items.concat(root.menuItems)
    }

    function units (num) {
        return num ? num * AppFramework.displayScaleFactor : num
    }
}
