/* Copyright 2019 Esri
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0
import QtQuick.Controls.Material 2.1

import ArcGIS.AppFramework 1.0

Popup {
    id: root

    property int transitionDuration: 200
    property real pageExtent: 0
    property real base: root.height
    property real panelHeaderHeight:root.units(10)
    property real defaultMargin: root.units(16)
    property real appHeaderHeight: 0
    property real iconSize: units(16)
    property string transitionProperty: "y"
    property string title: ""
    property color backgroundColor: "#FFFFFF"
    property color headerBackgroundColor: "#CCCCCC"

    property color separatorColor: "#4C4C4C"
    property bool fullView: false
    property bool isLargeScreen: false

    property bool showPageCount: false
    property int pageCount: 1
    property int currentPageNumber: 1
    property bool isHeaderVisible:true

    property Item content: Item {}

    property alias panelContent: panelContent

    signal expandButtonClicked ()
    signal previousButtonClicked ()
    signal nextButtonClicked ()

    signal backButtonPressed ()

    width: parent ? parent.width : undefined
    height: parent ? parent.height : undefined

    topPadding: 0
    topMargin: 0



    closePolicy: Popup.NoAutoClose

    enter: createTransition("y", 200, root.base, root.pageExtent + panelHeader.height, Easing.InOutQuad)

    exit: createTransition("y", 200, root.pageExtent + panelHeader.height, root.base, Easing.InOutQuad)

    Item {
        id: screenSizeState

        states: [
            State {
                name: "LARGE"
                when: isLargeScreen

                PropertyChanges {
                    target: root
                    fullView: true


                    leftMargin: app.isIphoneX && app.isLandscape ? app.widthOffset + app.defaultMargin : 0.5 * root.defaultMargin
                    bottomMargin: 1.5 * root.defaultMargin
                    height: (parent ? root.parent.height : root.units(690)) - bottomMargin - topMargin - panelHeaderHeight + 20 * scaleFactor

                    width: 0.33 * parent.width
                }

                PropertyChanges {
                    target: expandBtn
                    visible: false
                }

                PropertyChanges {
                    target: panelHeader
                    Material.elevation: 0
                }
            }
        ]
    }


    contentItem: BasePage {
        id: panelContent

        padding: 0

       Material.background: root.backgroundColor
        anchors {
            fill: parent
            margins: 0
        }

        header: ToolBar {
            id: panelHeader
            visible:isHeaderVisible

            height: root.panelHeaderHeight
            padding: 0
            spacing: 0
            anchors {

                right: parent.right
                left: parent.left
                margins: 0
            }
            Material.background: root.headerBackgroundColor
            Material.elevation: 0

            FocusScope {
                anchors.fill: parent
                focus: true
                Keys.onReleased: {
                    if (event.key === Qt.Key_Back || event.key === Qt.Key_Escape){
                        event.accepted = true
                        backButtonPressed()
                    }
                }
            ColumnLayout {
                anchors {
                    fill: parent
                    margins: 0
                }

                spacing: 0

                RowLayout {
                    id: headerBtns
                    spacing: 0


                    Layout.fillWidth: true
                    Layout.margins: 0

                    Icon {
                        id: closeBtn

                        Material.background: root.backgroundColor
                        Material.elevation: 0
                        maskColor: "#4c4c4c"
                        imageSource: "images/close.png"

                        onClicked: {
                            root.close()
                        }
                    }

                    Icon {
                        id: backBtn

                        visible: false
                        Material.background: root.backgroundColor
                        Material.elevation: 0
                        Layout.alignment: Qt.AlignVCenter
                        maskColor: "#4c4c4c"
                        imageSource: "images/back.png"

                        onClicked: {
                            root.collapseFullView()
                        }
                    }

                    BaseText {
                        id: titleText

                        visible: !root.showPageCount
                        text: root.title
                        elide: Text.ElideRight
                        maximumLineCount: 1
                        font.family: titleFontFamily
                        Layout.alignment: Qt.AlignVCenter
                        verticalAlignment: Text.AlignVCenter
                        Layout.preferredWidth: parent.width - closeBtn.width - expandBtn.width - 4 * root.defaultMargin
                        Layout.preferredHeight: contentHeight
                    }

                    RowLayout {
                        id: pageCount
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignHCenter
                        visible: root.showPageCount

                        SpaceFiller { Layout.preferredWidth: parent.width/4 }

                        Icon {
                            id: previousPage

                            Material.background: root.backgroundColor
                            Material.elevation: 0
                            maskColor: "#4c4c4c"
                            enabled: root.currentPageNumber > 1
                            rotation: 90
                            imageSource: "images/arrowDown.png"
                            Layout.alignment: Qt.AlignHCenter

                            onClicked: {
                                previousButtonClicked()
                            }
                        }

                        BaseText {
                            id: countText

                            text: qsTr("%1 of %2").arg(root.currentPageNumber).arg(root.pageCount)
                            elide: Text.ElideRight
                            maximumLineCount: 1
                            font.family: titleFontFamily
                            verticalAlignment: Text.AlignVCenter
                            Layout.alignment: Qt.AlignHCenter

                        }

                        Icon {
                            id: nextPage

                            Material.background: root.backgroundColor
                            Material.elevation: 0
                            maskColor: "#4c4c4c"
                            enabled: root.currentPageNumber < root.pageCount
                            rotation: -90
                            imageSource: "images/arrowDown.png"
                            Layout.alignment: Qt.AlignHCenter

                            onClicked: {
                                nextButtonClicked()
                            }
                        }

                        SpaceFiller { Layout.preferredWidth: parent.width/4 + closeBtn.width }
                    }

                    SpaceFiller { Layout.fillHeight: false }

                    Icon {
                        id: expandBtn

                        Material.background: root.backgroundColor
                        Material.elevation: 0
                        maskColor: "#4c4c4c"
                        rotation: 180
                        imageSource: "images/arrowDown.png"

                        onClicked: {
                            panelContent.state = "FULL_VIEW"
                            expandButtonClicked()
                        }
                    }
                }



            }
            }
        }

        contentItem: root.content

        states: [
            State {
                name: "FULL_VIEW"

                PropertyChanges {
                    target: root
                    y: panelHeader.height
                    fullView: true
                }
                PropertyChanges {
                    target: expandBtn
                    visible: false
                }
                PropertyChanges {
                    target: closeBtn
                    visible: false
                }
                PropertyChanges {
                    target: backBtn
                    visible: true
                }
            }
        ]

        transitions: Transition {
            NumberAnimation {
                id: yAnimation

                properties: "y"
                duration: root.transitionDuration
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        preventStealing: true
        onWheel: {
            wheel.accepted = true
        }
    }

    Component {
        id: transitionObject

        Transition {
            id: transition

            property string transitionProperty
            property int duration
            property real from
            property real to
            property int easingType

            NumberAnimation {
                property: transition.transitionProperty
                duration: transition.duration
                from: transition.from
                to: transition.to
                easing.type: transition.easingType
            }
        }
    }

    onCurrentPageNumberChanged: {
        nextPage.enabled = root.currentPageNumber < root.pageCount
        previousPage.enabled = root.currentPageNumber > 1
    }

    onPageCountChanged: {
        nextPage.enabled = root.currentPageNumber < root.pageCount
        previousPage.enabled = root.currentPageNumber > 1
    }

    onNextButtonClicked: {
        if (root.currentPageNumber < root.pageCount) {
            root.currentPageNumber += 1
        }
    }

    onPreviousButtonClicked: {
        if (root.currentPageNumber > 1) {
            root.currentPageNumber -= 1
        }
    }

    onClosed: {
        root.reset ()
    }

    function show () {
        root.open()
    }

    function hide () {
        root.reset()
        root.close()
    }

    function reset () {
        root.title = ""
        root.showPageCount = false
        root.pageCount = 1
        root.currentPageNumber = 1
    }

    function collapseFullView () {
        panelContent.state = ""
    }

    function createTransition (transitionProperty, duration, from, to, easingType) {
        var transition = transitionObject.createObject(root)
        transition.transitionProperty = transitionProperty || "y"
        transition.duration = duration || 200
        transition.from = from || root.height
        transition.to = to || 0
        transition.easingType = easingType || Easing.InOutQuad
        return transition
    }

    function toggle () {
        return visible ? close () : open ()
    }

    function units (num) {
        return num ? num * AppFramework.displayScaleFactor : num
    }
}
