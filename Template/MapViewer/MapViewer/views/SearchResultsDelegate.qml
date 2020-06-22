import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1

import "../controls" as Controls


ItemDelegate {
    id: searchResultsDelegate

    property string title: ""
    property string description: ""
    property real expandBtnWidth: app.units(40)
    property int currentIndex: ListView.view.currentIndex
    property bool showNavigationIcon: hasNavigationInfo

    signal clicked ()

    height: showInView ? app.units(66) : 0
    width: ListView.view.width
    visible: !heightAnimation.running
    topPadding: index === 0 ? app.baseUnit : 0
    bottomPadding: 0
    leftPadding: 0
    rightPadding: 0

    ButtonGroup.group: listView.buttonGroup

    Behavior on height {
        NumberAnimation {
            id: heightAnimation
            duration: 200
        }
    }

    Controls.Card {
        id: card

        headerHeight: 0
        footerHeight: 0
        padding: 0
        anchors.fill: parent
        highlightColor: Qt.darker(app.backgroundColor, 1.1)
        backgroundColor: "#FFFFFF"
        hoverAllowed: false // disable hover since it is interferring with the radiodelegate's ability to selectively highlight
        checked: searchResultsDelegate.checked || listView.model.currentIndex === initialIndex

        propagateComposedEvents: false
        Material.elevation: 0

        content: Pane {
            anchors.fill: parent
            rightPadding: app.defaultMargin
            leftPadding: navigationIcon.visible ? 0 : (1/2) * app.baseUnit
            topPadding: 0
            bottomPadding: 0

            Row {
                anchors {
                    fill: parent
                    leftMargin: app.baseUnit
                    rightMargin: app.baseUnit
                }
                spacing: 0.8 * app.baseUnit

                ColumnLayout {
                    id: navigationIcon

                    visible: showNavigationIcon
                    width: Math.min(parent.height, app.units(40))
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 0.5 * app.baseUnit

                    Image {
                        visible: !distance.startsWith("100+")
                        Layout.preferredWidth: 0.4 * app.iconSize
                        Layout.preferredHeight: width
                        Layout.alignment: Qt.AlignHCenter
                        source: "../images/navigation.png"
                        rotation: navigationIcon.visible ? degrees : 0
                        opacity: 0.4
                        mipmap: true
                    }

                    Controls.BaseText {
                        text: navigationIcon.visible ? distance : ""
                        Layout.preferredWidth: parent.width
                        Layout.alignment: Qt.AlignHCenter
                        horizontalAlignment: Text.AlignHCenter
                        font.pointSize: 0.8 * desc.font.pointSize
                        opacity: 0.5
                    }
                }

                ColumnLayout {

                    height: parent.height
                    width: navigationIcon.visible ? parent.width - navigationIcon.width : parent.width

                    spacing: 0

                    Controls.BaseText {
                        id: label

                        text: title
                        maximumLineCount: 1
                        elide: Text.ElideRight
                        Layout.preferredWidth: parent.width
                        Layout.preferredHeight: desc.text > "" ? (desc.lineCount > 1 ? (1/3) * parent.height : (1/2) * parent.height) : parent.height
                        verticalAlignment: desc.text > "" ? Text.AlignBottom : Text.AlignVCenter
                    }

                    Controls.BaseText {
                        id: desc

                        text: description
                        maximumLineCount: 2
                        font.pointSize: app.textFontSize
                        elide: Text.ElideRight
                        Layout.alignment: Qt.AlignTop
                        Layout.preferredWidth: parent.width
                        visible: desc.text > ""
                        opacity: 0.7
                        Layout.preferredHeight: desc.text > "" ? (lineCount > 1 ? (2/3) * parent.height : (1/2) * parent.height) : parent.height
                        verticalAlignment: lineCount > 1 ? Text.AlignVCenter : Text.AlignTop
                    }
                }
            }
        }

        onClicked: {
            searchResultsDelegate.clicked()
            searchResultsDelegate.checked = true
        }
    }

    Rectangle {
        visible: index && parent.height
        width: parent.width - app.defaultMargin
        height: app.units(1)
        color: app.separatorColor
        opacity: 0.5
        anchors {
            top: parent.top
            horizontalCenter: parent.horizontalCenter
        }
    }

    onClicked: {
        ListView.view.currentIndex = index
    }

    MouseArea {
        anchors.fill: parent
        propagateComposedEvents: false
        onClicked: card.clicked()
    }
}
