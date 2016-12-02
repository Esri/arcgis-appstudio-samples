import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2
import QtQuick.Window 2.0
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Runtime 1.0

//------------------------------------------------------------------------------

Dialog {
    id: portalSignInDialog

    property Portal portal
    property alias usernameLabel: usernameText.text
    property alias username: usernameField.text
    property alias passwordLabel: passwordText.text
    property alias password: passwordField.text
    property bool busy: false
    property string message : ""
    property alias saveUserLabel: saveUserCheckBox.text
    property alias saveUserChecked: saveUserCheckBox.checked
    property alias saveUserVisible : saveUserCheckBox.visible
    property alias acceptLabel : acceptButton.text
    property alias rejectLabel : rejectButton.text
    property string settingsGroup: "Portal"
    property alias bannerImage: image.source
    property alias bannerColor: banner.color
    property bool showPortalUrl: false

    title: busy ? qsTr("Signing In") : qsTr("Sign In")

    Component.onCompleted: {
        portal.url = "https://www.arcgis.com";

        if (app.settings) {
            saveUserChecked = app.settings.boolValue(settingsGroup + "/saveUsername", true);
            username = app.settings.value(settingsGroup + "/username", "");

            var url = app.settings.value(settingsGroup + "/portalUrl", "");
            if (url > "") {
                portal.url = url;
                showPortalUrl = true;
            }
        }

        console.log("portalUrl:", portal.url);
    }

    Connections {
        target: portal


        onSignInComplete: {
            busy = false;

            if (settingsGroup) {
                if (saveUserChecked) {
                    app.settings.setValue(settingsGroup + "/username", username);
                } else {
                    app.settings.remove(settingsGroup + "/username");
                }
                app.settings.setValue(settingsGroup + "/saveUsername", saveUserChecked);
            }

            close();
        }

        onSignInError: {
            messageText.text = error.message + "\r\n" + error.details;
            busy = false;
        }
    }

    contentItem: Rectangle {
        implicitWidth: Math.min(400 * AppFramework.displayScaleFactor, Screen.desktopAvailableWidth * 0.95)
        implicitHeight: Math.min(320 * AppFramework.displayScaleFactor, Screen.desktopAvailableHeight * 0.95)
        //implicitWidth: 400
        //implicitHeight: 300

        color: "white"

        Rectangle {
            id: banner

            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }

            height: titleText.paintedHeight + 20 * AppFramework.displayScaleFactor
            color: "#0079C1"

            Image {
                id: image

                anchors.fill: parent

                height: titleText.paintedHeight + 20 * AppFramework.displayScaleFactor
                fillMode: Image.PreserveAspectCrop
                visible: source > ""
            }

            Text {
                id: titleText

                anchors {
                    fill: parent
                    leftMargin: 10 * AppFramework.displayScaleFactor
                }
                text: portalSignInDialog.title
                color: "white"
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter

                font {
                    pointSize: 30
                    bold: true
                }
            }
        }

        FocusScope {
            id: inputArea

            anchors {
                top: banner.bottom
                topMargin: 30 * AppFramework.displayScaleFactor
                left: parent.left
                leftMargin: 20 * AppFramework.displayScaleFactor
                right: parent.right
                rightMargin: 20 * AppFramework.displayScaleFactor
                bottom: parent.bottom
                bottomMargin: 20 * AppFramework.displayScaleFactor
            }

            ColumnLayout {
                anchors {
                    fill: parent
                }

                spacing: 5 * AppFramework.displayScaleFactor

                Text {
                    Layout.fillWidth: true

                    visible: showPortalUrl
                    text: qsTr("Portal Url: <b>%1</b>").arg(portal.url)

                    horizontalAlignment: Text.AlignLeft
                    font {
                        pointSize: 14
                        italic: true
                    }
                    color: "red"
                    textFormat: Text.RichText
                }

                Text {
                    id: usernameText

                    Layout.fillWidth: true

                    text: qsTr("Username")
                    horizontalAlignment: Text.AlignLeft
                    font {
                        pointSize: 14
                        bold: true
                    }
                }

                TextField {
                    id: usernameField

                    Layout.fillWidth: true

                    placeholderText: usernameLabel
                    font {
                        pointSize: 16
                    }
                    style: TextFieldStyle {
                        renderType: Text.QtRendering
                    }
                    activeFocusOnTab: true
                    focus: true
                    inputMethodHints: Qt.ImhNoAutoUppercase + Qt.ImhNoPredictiveText + Qt.ImhSensitiveData

                    onAccepted: {
                        acceptButton.tryClick();
                    }
                }

                Text {
                    id: passwordText

                    Layout.fillWidth: true

                    text: qsTr("Password")
                    horizontalAlignment: Text.AlignLeft
                    font: usernameText.font
                }

                TextField {
                    id: passwordField

                    Layout.fillWidth: true

                    echoMode: TextInput.Password
                    placeholderText: passwordLabel
                    font: usernameField.font
                    style: usernameField.style
                    activeFocusOnTab: true

                    onAccepted: {
                        acceptButton.tryClick();
                    }
                }

                CheckBox {
                    id: saveUserCheckBox

                    Layout.fillWidth: true

                    text: qsTr("Remember me")
                    visible: app.settings != null

                    style: CheckBoxStyle {
                        label: Item {
                            implicitWidth: text.implicitWidth + 2
                            implicitHeight: text.implicitHeight
                            baselineOffset: text.baselineOffset

                            Rectangle {
                                anchors.fill: text
                                anchors.margins: -1
                                anchors.leftMargin: -3
                                anchors.rightMargin: -3
                                visible: control.activeFocus
                                height: 6
                                radius: 3
                                color: "#224f9fef"
                                border.color: "#47b"
                                opacity: 0.6
                            }

                            Text {
                                id: text

                                text: control.text
                                anchors.fill: parent
                                color: "black"
                                renderType: Text.QtRendering
                            }
                        }
                    }
                }

                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }

                Text {
                    id: messageText

                    Layout.fillWidth: true

                    text: message
                    wrapMode: Text.Wrap

                    color: "red"
                    font {
                        pointSize: 14
                        italic: true
                        bold: true
                    }
                }

                RowLayout {
                    Layout.fillWidth: true

                    Button {
                        id: acceptButton

                        text: busy ? qsTr("Signing In") : qsTr("Sign In")
                        isDefault: true
                        enabled: !busy && username.trim().length > 0 && password.trim().length > 0
                        onClicked: {
                            tryClick();
                        }

                        function tryClick() {
                            if (!enabled) {
                                return;
                            }

                            busy = true;
                            message = "";

                            portal.credentials.userName = username.trim();
                            portal.credentials.password = password.trim();
                            portal.signIn();
                        }

                        style: ButtonStyle {
                            padding {
                                left: 10 * AppFramework.displayScaleFactor
                                right: 10 * AppFramework.displayScaleFactor
                            }

                            label: Text {
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignHCenter
                                color: control.enabled ? (control.isDefault ? "white" : "dimgray") : "gray"
                                text: control.text
                                font {
                                    pointSize: 14
                                    capitalization: Font.AllUppercase
                                }
                            }

                            background: Rectangle {
                                color: (control.hovered | control.pressed) ? (control.isDefault ? "#e36b00" : "darkgray") : (control.isDefault ? "#e98d32" : "lightgray")
                                border {
                                    color: control.activeFocus ? (control.isDefault ? "#e36b00" : "darkgray") : "transparent"
                                    width: control.activeFocus ? 2 : 1
                                }
                                radius: 4
                                //implicitWidth: 150
                            }
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                        height: 1
                    }

                    Button {
                        id: rejectButton

                        text: qsTr("Cancel")
                        enabled: !busy
                        onClicked: {
                            close();
                            rejected();
                        }
                        style: acceptButton.style
                    }
                }
            }
        }

        BusyIndicator {
            id: busyIndicator
            running: busy
            anchors.centerIn: parent
        }
    }

    Component {
        id: spacer

        Rectangle {
            width: parent.width
            height: 10
        }
    }
}
