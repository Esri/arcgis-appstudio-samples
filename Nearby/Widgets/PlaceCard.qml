import QtQuick 2.9
import QtQuick.Controls 2.5
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0
import ArcGIS.AppFramework 1.0

Item {
    id: root

    property string title: ""
    property string placeDistance: ""
    property string placeAddress: ""
    property string category: ""
    property string phoneNumber: ""
    property string website: ""
    property bool isHighlighted: false
    property bool isClickable: false
    signal cardClicked
    signal directionsClicked
    signal websiteClicked
    signal callClicked
    Rectangle {
        id: card

        anchors.fill: parent
        radius: 4 * app.scaleFactor
        anchors.bottomMargin: appManager.isSmall? 24 * app.scaleFactor: 0
        anchors.rightMargin: 8 * app.scaleFactor
        anchors.leftMargin: 8 * app.scaleFactor
        color: appManager.isLarge? (isHighlighted? colors.lightGrey: colors.secondaryColor) : colors.secondaryColor
        Ink {
            anchors.fill: parent
            enabled: isClickable
            ColumnLayout {
                anchors.fill: parent
                spacing: 16
                anchors.margins: 16 * app.scaleFactor
                Item {
                    Layout.preferredHeight: 60 * app.scaleFactor
                    Layout.fillWidth: true
                    Label{
                        id: titleLabel
                        text: title
                        width: parent.width
                        color: app.textColor
                        font.pixelSize: 16 * app.scaleFactor
                        elide: Label.ElideRight
                        font.bold: true
                        anchors.top: parent.top
                        anchors.leftMargin: 16 * app.scaleFactor
                    }

                    Label{
                        id: categoryLabel
                        text: category
                        width: parent.width
                        color: colors.subTextColor
                        font.pixelSize: 12 * app.scaleFactor
                        elide: Label.ElideMiddle
                        anchors.top: titleLabel.bottom
                        anchors.margins: 4 * app.scaleFactor
                    }
                    Label {
                        id: addressLabel
                        text: placeAddress + " · " + placeDistance
                        width: parent.width
                        elide: Label.ElideMiddle
                        font.pixelSize: 13 * app.scaleFactor
                        wrapMode: Label.WordWrap
                        color: colors.subTextColor
                        anchors.top: categoryLabel.bottom
                        anchors.margins: 4 * app.scaleFactor
                    }
                }

                RowLayout {
                    id: actions
                    Layout.fillWidth: true
                    Layout.preferredHeight: 48 * app.scaleFactor
                    Layout.alignment: Qt.AlignBottom
                    spacing: 8 * app.scaleFactor
                    CustomRoundButton {
                        title: strings.directions
                        isFilled: true
                        Layout.preferredHeight: 36 * app.scaleFactor
                        Layout.preferredWidth: 100 * app.scaleFactor
                        Layout.alignment: Qt.AlignLeft
                        Material.elevation: 1
                        overlayColor: app.primaryColor
                        imageSource: sources.directionsBlackIcon
                        onClicked: {
                            directionsClicked();
                        }
                    }
                    CustomRoundButton {
                        title: strings.website
                        isFilled: false
                        visible: website !== ""
                        Layout.preferredHeight: 36 * app.scaleFactor
                        Layout.preferredWidth: 88 * app.scaleFactor
                        Layout.alignment: Qt.AlignLeft
                        Material.elevation: 1
                        overlayColor: app.primaryColor
                        imageSource: sources.publicBlackIcon
                        onClicked: {
                            websiteClicked();
                        }
                    }
                    CustomRoundButton {
                        title: strings.call
                        isFilled: false
                        visible: phoneNumber !== ""
                        Layout.preferredHeight: 36 * app.scaleFactor
                        Layout.preferredWidth: 68 * app.scaleFactor
                        Layout.alignment: Qt.AlignLeft
                        Material.elevation: 1
                        overlayColor: app.primaryColor
                        imageSource: sources.phoneBlackIcon
                        onClicked: {
                            callClicked();
                        }
                    }
                }
            }
            onClicked: {
                cardClicked();
            }
        }
    }
    DropShadow {
        anchors.fill: card
        horizontalOffset: isHighlighted? 1: 0
        verticalOffset: isHighlighted? 1: 0
        radius: 8.0
        samples: 17
        color: "#29000000"
        source: card
    }
}


