import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtGraphicalEffects 1.0
import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Platform 1.0
import ArcGIS.AppFramework.Networking 1.0
import ArcGIS.AppFramework.Labs 1.0
import "Styles"
import "Views"

Page {
    id: page

    anchors.fill: parent

    property string closedReason: ""

    Flickable {
        id: flickable

        anchors.fill: parent
        anchors.margins: 10

        contentWidth: columnLayout.width
        contentHeight: columnLayout.height
        clip: true

        ColumnLayout {
            id: columnLayout

            width: flickable.width

            Button {
                text: qsTr( "DocumentDialog.Open" )

                onClicked: openDocumentDialog()
            }

            Heading3Label {
                text: qsTr( "documentDialog.fileUrl" )
            }

            TextBox {
                Layout.fillWidth: true
                text: documentDialog.fileUrl|| ""
                readOnly: true
            }

            Heading3Label {
                text: qsTr( "documentDialog.filePath" )
            }

            TextBox {
                Layout.fillWidth: true
                text: documentDialog.filePath || ""
                readOnly: true
            }

            Heading3Label {
                text: qsTr( "documentDialog.status" )
            }

            TextBox {
                Layout.fillWidth: true
                text: documentDialog.status + " " + documentDialog.statusText
                readOnly: true
            }

            Heading3Label {
                text: qsTr( "closedReason" )
            }

            TextBox {
                Layout.fillWidth: true
                text: closedReason || ""
                readOnly: true
            }

            Heading3Label {
                text: qsTr( "AppFramework.version" )
            }

            TextBox {
                Layout.fillWidth: true
                text: AppFramework.version
                readOnly: true
            }

            Heading3Label {
                text: qsTr( "networkRequest.url" )
            }

            TextBox {
                Layout.fillWidth: true
                text: networkRequest.url
                readOnly: true
            }

            Heading3Label {
                text: qsTr( "networkRequest.errorCode" )
            }

            TextBox {
                Layout.fillWidth: true
                text: networkRequest.errorCode + " " + networkRequest.errorText
                readOnly: true
            }

            Heading3Label {
                text: qsTr( "networkRequest.status" )
            }

            TextBox {
                Layout.fillWidth: true
                text: networkRequest.status + " " + networkRequest.statusText
                readOnly: true
            }

            Heading3Label {
                text: qsTr( "networkRequest.responseHeaders" )
            }

            TextBox {
                Layout.fillWidth: true
                text: JSON.stringify( networkRequest.responseHeaders, undefined, 2 )
                readOnly: true
            }

            Heading3Label {
                text: qsTr( "networkRequest.responseText" )
            }

            TextBox {
                Layout.fillWidth: true
                text: networkRequest.responseText
                readOnly: true
            }

        }
    }

    Styles {
        id: styles
    }

    DocumentDialog {
        id: documentDialog

        property EnumInfo statusEnum: Labs.enumInfo( documentDialog, "DocumentDialogStatus" )
        property string statusText: statusEnum.toKey( status )

        onAccepted: {
            closedReason = qsTr( "Accepted" );

            networkRequest.url = fileUrl;
            networkRequest.send();
        }

        onRejected: {
            closedReason = qsTr( "Rejected" );
        }
    }

    NetworkRequest {
        id: networkRequest
    }

    function openDocumentDialog() {
        closedReason = "";

        documentDialog.open()
    }

}
