import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtPositioning 5.12
import QtLocation 5.12

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Sql 1.0

import "Styles"

Page {
    id: page

    title: qsTr( "Coordinate.parse" )

    property var parseInfo: { coordinateValid: false }

    onVisibleChanged: {
        if ( visible ) {
            inputText.editText = parseText;
        }
    }

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

            Heading1Text {
                Layout.fillWidth: true

                text: qsTr( "Coordinate.parse() sample " )
                horizontalAlignment: Qt.AlignHCenter
            }

            Item {
                Layout.preferredHeight: 20
            }

            GridLayout {
                Layout.fillWidth: true

                columns: page.width > page.height ? 2 : 1

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.preferredWidth: 200
                    Layout.alignment: Qt.AlignTop

                    Heading2Label {
                        text: qsTr( "Text" )
                    }

                    NormalComboBox {
                        id: inputText
                        Layout.fillWidth: true
                        editable: true
                        model: parseSamples

                        onCurrentTextChanged: {
                            if ( currentIndex === -1 ) {
                                return;
                            }

                            parseText = currentText;
                            updateResults();
                        }

                        onEditTextChanged: {
                            parseText = editText;
                            updateResults();
                        }
                    }

                    Item {
                        Layout.preferredHeight: 10
                    }

                    Heading2Label {
                        text: qsTr( "Options" )
                    }

                    Item {
                        Layout.preferredHeight: 10
                    }

                    Heading3Label {
                        text: qsTr( "Formats" )
                    }

                    Flow {
                        Layout.fillWidth: true

                        spacing: 10

                        Repeater {
                            model: Coordinate.availableParseFormats

                            NormalCheckBox {
                                text: modelData
                                checked: parseFormats[ modelData ]

                                onCheckedChanged: {
                                    parseFormats[ modelData ] = checked;
                                    updateOptions();
                                    updateResults();
                                }
                            }
                        }

                    }

                    Heading2Label {
                        text: qsTr( "Sample Code")
                    }

                    NormalText {
                        id: sampleCode
                        Layout.fillWidth: true
                        text: generateSampleCode( parseText, parseOptions )
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    }

                    NormalButton {
                        text: qsTr( "Copy" )

                        onClicked: copyToClipboard( sampleCode.text, qsTr( "Sample Code copied" ) )
                    }

                    Item {
                        Layout.preferredHeight: 10
                    }

                }

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.preferredWidth: 200
                    Layout.alignment: Qt.AlignTop

                    Heading2Label {
                        text: qsTr( "Results" )
                    }

                    Item {
                        Layout.preferredHeight: 10
                    }

                    Heading3Label {
                        text: qsTr( "formatValid")
                    }

                    NormalText {
                        Layout.fillWidth: true
                        text: parseInfo.formatValid ? "true" : "false"
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    }

                    Item {
                        Layout.preferredHeight: 10
                    }

                    Heading3Label {
                        text: qsTr( "format" )
                    }

                    NormalText {
                        Layout.fillWidth: true
                        text: parseInfo.formatValid ? parseInfo.format : "undefined"
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    }

                    Item {
                        Layout.preferredHeight: 10
                    }

                    Heading3Label {
                        text: qsTr( "coordinateValid" )
                    }

                    NormalText {
                        Layout.fillWidth: true
                        text: parseInfo.coordinateValid ? "true" : "false"
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    }

                    Item {
                        Layout.preferredHeight: 10
                    }

                    Heading3Label {
                        text: qsTr( "coordinate" )
                    }

                    NormalText {
                        Layout.fillWidth: true
                        text: parseInfo.coordinateValid ? JSON.stringify( parseInfo.coordinate, undefined, 2 ) : "undefined"
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    }

                    Item {
                        Layout.preferredHeight: 10
                    }

                    Heading3Label {
                        text: qsTr( "JSON" )
                    }

                    NormalText {
                        id: parseInfoText
                        Layout.fillWidth: true
                        text: JSON.stringify( parseInfo, undefined, 2 )
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    }

                    NormalButton {
                        text: qsTr( "Copy" )

                        onClicked: copyToClipboard( parseInfoText.text, qsTr( "Results copied" ) )
                    }

                }
            }

            Item {
                Layout.preferredHeight: 100
            }

        }
    }

    Menu {
        id: parseSamplesMenu

        x: ( parent.width - width ) / 2
        y: 20
        width: parent.width / 2
        height: parent.height - 40

        Repeater {
            model: parseSamples

            NormalMenuItem {
                text: modelData

                onTriggered: inputText.text = modelData
            }
        }
    }

    PropertySet {
        id: parseFormats

        Component.onCompleted: {
            for ( const format of Coordinate.availableParseFormats ) {
                parseFormats[ format ] = false;
            }
        }
    }

    Component.onCompleted: Qt.callLater( updateOptions )

    function updateOptions() {
        let formats = [ ];

        for ( let format of Coordinate.availableParseFormats ) {
            if ( parseFormats[ format ] ) {
                formats.push( format );
            }
        }

        parseOptions = formats.length ? { "formats": formats } : null;
    }

    function generateSampleCode( text, options ) {
        if ( text === "" ) {
            let err = new Error( "No text supplied" );
            console.log( err.stack );
            return "";
        }

        let code = [ ];
        code.push( "let text = %1;".arg (JSON.stringify( text ) ) );
        if ( options ) {
            code.push( "let options = %1;".arg( JSON.stringify( options ) ) );
            code.push( "let info = Coordinate.parse( text, options );" );
        } else {
            code.push( "let info = Coordinate.parse( text );" );
        }
        code.push( "console.log( info.formatValid ); ");
        code.push( "console.log( info.format); ");
        code.push( "console.log( info.coordinateValid ); ");
        code.push( "console.log( JSON.stringify( info.coordinate, undefined, 2 ) );" );
        code.push( "console.log( JSON.stringify( info, undefined, 2 ) );" );
        return code.join( "\n" ) + "\n";
    }

    function updateResults() {
        parseInfo = parseOptions ?
                    Coordinate.parse( parseText, parseOptions ) :
                    Coordinate.parse( parseText );

        if ( parseInfo.coordinateValid ) {
            coordinate = QtPositioning.coordinate(
                        parseInfo.coordinate[ "latitude" ],
                        parseInfo.coordinate[ "longitude" ]
                        );
        }
    }

}
