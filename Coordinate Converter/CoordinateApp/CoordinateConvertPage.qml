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

    title: qsTr( "Coordinate.convert" )

    property alias convertPrecision: convertPrecisionSlider.value
    property bool convertPrecisionEnabled: [ "dd", "ddm", "dms", "mgrs" ].indexOf( convertFormat ) !== -1
    property alias convertSpaces: convertSpacesCheckBox.checked
    property bool convertSpacesEnabled: [ "mgrs" ].indexOf( convertFormat ) !== -1
    property int convertSrid: convertSridTextField.text !== "" ? parseInt( convertSridTextField.text ) : 4326
    property bool convertSridEnabled: convertFormat === "srs"

    property var defaultPrecision: ( {
                                        "dd": 6,
                                        "ddm": 4,
                                        "dms": 4,
                                        "mgrs": 10
                                    } )

    onVisibleChanged: {
        if ( visible ) {
            convert();
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

                text: qsTr( "Coordinate.convert() sample" )
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
                        text: qsTr( "Coordinate" )
                    }

                    NormalLabel {
                        text: qsTr( "( %1, %2 ) ") .arg( coordinate.latitude.toFixed(6) ) .arg( coordinate.longitude.toFixed(6) )
                    }

                    Item {
                        Layout.preferredHeight: 10
                    }

                    Heading2Label {
                        text: qsTr( "Format" )
                    }

                    Flow {
                        Layout.fillWidth: true

                        spacing: 10

                        Repeater {
                            model: Coordinate.availableConvertFormats

                            NormalRadioButton {
                                text: modelData
                                checked: modelData === convertFormat

                                onClicked: {
                                    convertFormat = modelData;
                                    convertPrecision = defaultPrecision[ convertFormat ] || 4.0
                                    updateOptions();
                                }
                            }
                        }

                    }

                    Heading2Label {
                        text: qsTr( "Options" )
                        visible: convertOptions !== null
                    }

                    Item {
                        Layout.preferredHeight: 10
                    }

                    Heading3Label {
                        text: qsTr( "Precision (value: %1)" ).arg( convertPrecision )
                        visible: convertPrecisionEnabled
                    }

                    NormalSlider {
                        id: convertPrecisionSlider

                        Layout.fillWidth: true

                        from: 1
                        to: 10
                        snapMode: Slider.SnapOnRelease
                        stepSize: 1
                        value: 4.0
                        visible: convertPrecisionEnabled

                        onValueChanged: Qt.callLater( updateOptions )
                    }

                    Heading3Label {
                        text: qsTr( "Spaces" )
                        visible: convertSpacesEnabled
                    }

                    NormalCheckBox {
                        id: convertSpacesCheckBox

                        Layout.fillWidth: true

                        checked: true
                        visible: convertSpacesEnabled
                        text: qsTr( "Spaces" )

                        onCheckedChanged: Qt.callLater( updateOptions )
                    }

                    Heading3Label {
                        text: qsTr( "SRID" )
                        visible: convertSridEnabled
                    }

                    NormalTextField {
                        id: convertSridTextField

                        Layout.fillWidth: true

                        placeholderText: qsTr( "4326 (geographic), 3857 (web mercator)" )
                        validator: IntValidator { bottom: 1; top: 999999 }
                        visible: convertSridEnabled
                        selectByMouse: true

                        onTextChanged: Qt.callLater( updateOptions )
                    }

                    Heading3Label {
                        text: qsTr( "Sample code" )
                    }

                    NormalText {
                        id: sampleCode
                        Layout.fillWidth: true
                        text: generateSampleCode( coordinate, convertFormat, convertOptions )
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    }

                    NormalButton {
                        text: qsTr( "Copy" )

                        onClicked: copyToClipboard( sampleCode.text, qsTr( "Sample code copied" ) )
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
                        text: qsTr( "formatValid" )
                    }

                    NormalText {
                        Layout.fillWidth: true
                        text: convertInfo.formatValid ? "true" : "false"
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    }

                    Item {
                        Layout.preferredHeight: 10
                    }

                    Heading3Label {
                        text: qsTr( "text" )
                    }

                    NormalText {
                        id: resultText

                        Layout.fillWidth: true
                        text: convertText
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    }

                    NormalButton {
                        text: qsTr( "Copy" )

                        onClicked: {
                            copyToClipboard( convertText, qsTr( "Text copied" ) );
                        }
                    }

                    Item {
                        Layout.preferredHeight: 10
                    }

                    Heading3Label {
                        text: qsTr( "JSON" )
                    }

                    NormalText {
                        Layout.fillWidth: true
                        text: JSON.stringify( convertInfo, undefined, 2 )
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    }

                    NormalButton {
                        text: qsTr( "Copy" )

                        onClicked: copyToClipboard( convertInfo, qsTr( "Results copied" ) )
                    }
                }
            }

            Item {
                Layout.preferredHeight: 100
            }

        }
    }

    Component.onCompleted: Qt.callLater( updateOptions )

    function updateOptions()
    {
        let _options = null;
        if ( convertPrecisionEnabled || convertSpacesEnabled || convertSridEnabled )
        {
            _options = { };
            if ( convertPrecisionEnabled )
            {
                _options[ "precision" ] = convertPrecision;
            }
            if ( convertSpacesEnabled )
            {
                _options[ "spaces" ] = convertSpaces;
            }
            if ( convertSridEnabled )
            {
                _options[ "srid" ] = convertSrid;
            }
        }
        convertOptions = _options;
        convert();
    }

    function convert()
    {
        convertInfo = convertOptions ?
                    Coordinate.convert( coordinate, convertFormat, convertOptions ) :
                    Coordinate.convert( coordinate, convertFormat );
        convertText = convertInfoToText( convertInfo );
        parseText = convertText;
    }

    function generateSampleCode( coordinate, format, options )
    {
        let code = [ ];
        code.push( "let coordinate = QtPositioning.coordinate( %1, %2 );"
                  .arg( coordinate.latitude )
                  .arg( coordinate.longitude ) );
        code.push(  "let format = %1;".arg( JSON.stringify( format ) ) );
        if ( options )
        {
            code.push( "let options = %1;".arg( JSON.stringify( options ) ) );
            code.push( "let info = Coordinate.convert( coordinate, format, options );" );
        }
        else
        {
            code.push( "let info = Coordinate.convert( coordinate, format );" );
        }
        code.push( "console.log( info.formatValid ); ");
        switch ( format )
        {

        }

        switch ( format )
        {
        case "dd":
            code.push( "let text = \"%1 %2\" ");
            code.push( "           .arg( info.dd.latitudeText ) " );
            code.push( "           .arg( info.dd.longitudeText ); " );
            code.push( "console.log( text ); ");
            break;

        case "ddm":
            code.push( "let text = \"%1 %2\" ");
            code.push( "           .arg( info.ddm.latitudeText ) " );
            code.push( "           .arg( info.ddm.longitudeText ); " );
            code.push( "console.log( text ); ");
            break;

        case "dms":
            code.push( "let text = \"%1 %2\" ");
            code.push( "           .arg( info.dms.latitudeText ) " );
            code.push( "           .arg( info.dms.longitudeText ); " );
            code.push( "console.log( text ); ");
            break;

        case "srs":
            code.push( "let text = \"SRID=%1 %2 %3\" ");
            code.push( "           .arg( info.srs.srid ) " );
            code.push( "           .arg( info.srs.x.toFixed( 8 ) ) " );
            code.push( "           .arg( info.srs.y.toFixed( 8 ) ); " );
            code.push( "console.log( text ); ");
            break;

        case "utm":
            code.push( "let text = \"%1%2 %3 %4\" ");
            code.push( "           .arg( info.utm.zone ) " );
            code.push( "           .arg( info.utm.band ) " );
            code.push( "           .arg( info.utm.easting.toFixed( 8 ) ) " );
            code.push( "           .arg( info.utm.northing.toFixed( 8 ) ); " );
            code.push( "console.log( text ); ");
            break;

        case "universalGrid":
            code.push( "let text = \"\"; " );
            code.push( "switch ( info.universalGrid.type ) " );
            code.push( "{ " );
            code.push( "case \"UTM\": " );
            code.push( "    text = \"UTM %1%2 %3 %4\" ");
            code.push( "           .arg( info.universalGrid.zone ) " );
            code.push( "           .arg( info.universalGrid.band ) " );
            code.push( "           .arg( info.universalGrid.easting.toFixed( 0 ) ) " );
            code.push( "           .arg( info.universalGrid.northing.toFixed( 0 ) ); " );
            code.push( "    break;" );
            code.push( "case \"UPS\": " );
            code.push( "    text = \"UPS %1 %2 %3\" ");
            code.push( "           .arg( info.universalGrid.band ) " );
            code.push( "           .arg( info.universalGrid.easting.toFixed( 0 ) ) " );
            code.push( "           .arg( info.universalGrid.northing.toFixed( 0 ) ); " );
            code.push( "    break;" );
            code.push( "} " );
            code.push( "console.log( text ); ");
            break;

        case "mgrs":
            code.push( "let text = info.mgrs.text;" );
            code.push( "console.log( text ); ");
            break;
        }

        code.push( "console.log( JSON.stringify( info, undefined, 2 ) );" );
        return code.join( "\n" ) + "\n";
    }

}
