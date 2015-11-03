import QtQuick 2.5
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.1
import QtQuick.Controls.Styles 1.3

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import ArcGIS.AppFramework.Runtime 1.0
import ArcGIS.AppFramework.Runtime.Controls 1.0

Item {
    id: _root

    Component.onCompleted: {
        // Check for required params (feature layer and query field)
        if (!featLayer || !queryField) {
            console.log("ERROR: featLayer and queryField properties are required for the FeatureFinder component")
        }

        // Check if field is string - needed for where property of queries
        var fields = fLayer.fields
        var fieldsLength = fields.length
        for (var i=0; i < fieldsLength; i++) {
            if (fields[i].name === queryField) {
                if (fields[i].fieldType === Enums.FieldTypeString) {
                    fieldIsString = true
                }
                break
            }
        }
    }

    // Configurable variables
    property ArcGISFeatureLayer featLayer
    property string queryField
    property color featureSelectionColor: "cyan"
    property color searchBoxColor: "white"
    property color searchBoxBorderColor: "gray"
    property string fontFamilyName: ""
    property color searchBoxTextColor: "#585858"
    property double fontSize: 16*scaleFactor
    property color searchBoxPlaceholderTextColor: "#A3A199"
    property string searchBoxPlaceHolderText: queryField
    property color busyIndicatorColor: "blue"
    property double dropDownListMaxHeight: 175*scaleFactor

    // Signal
    signal select(Geometry featGeometry)

    // Other variables
    property var valuesList: ([])
    property int valuesListLength
    property bool valueSelected: false
    property double originalSearchBoxHeight: _root.height
    property bool fieldIsString: false
    property int currentIndex: 1
    // Scale factor
    property double scaleFactor : AppFramework.displayScaleFactor



    // -- Search rectangle expands to show filtered list of values
    Rectangle {
        id: rectSearch
        width: parent.width
        height: parent.height

        color: searchBoxColor
        border.color: searchBoxBorderColor
        border.width: 1*scaleFactor

        Rectangle {
            id: rectBorder
            width: parent.width
            height: 1*scaleFactor
            color: searchBoxBorderColor
            anchors {
                top: txtSearch.bottom
            }
            visible: false
        }

        TextField {
            id: txtSearch
            style: TextFieldStyle {
                placeholderTextColor: searchBoxPlaceholderTextColor
                background: Rectangle {
                    height: parent.height
                    width: parent.width - rectClearText.width
                    color: searchBoxColor
                }
            }
            height: originalSearchBoxHeight - 4*scaleFactor
            width: parent.width - rectClearText.width
            font.family: fontFamilyName
            font.pointSize: fontSize
            textColor: searchBoxTextColor
            activeFocusOnPress: true
            placeholderText: searchBoxPlaceHolderText
            anchors {
                left: parent.left
                top: parent.top
                margins: 2*scaleFactor
            }
            Keys.onReturnPressed: {
                if (fieldIsString) {
                    // Convert all values to lower case for comparison
                    var valuesListLowerCase = []
                    for (var i = 0; i < valuesListLength; i++) {
                        valuesListLowerCase.push(valuesList[i].toLowerCase())
                    }

                    if (valuesListLowerCase.indexOf(text.toLowerCase()) > -1) {
                        // Zoom to, and select the feature
                        findFeature(txtSearch.text)
                    }

                }else {
                    if (valuesList.indexOf(text) > -1) {
                        // Zoom to, and select the feature
                        findFeature(txtSearch.text)
                    }
                }

            }

            onFocusChanged: {
                if (focus) {
                    placeholderText = ""
                }else {
                    placeholderText = searchBoxPlaceHolderText
                }
            }

            onTextChanged: {
                var whereList = []
                var where = ""
                if (cursorPosition > 2 && !valueSelected) {
                    if (fieldIsString) {
                        where = queryField + " LIKE '" + text + "%'"
                    }else {
                        where = queryField + " LIKE " + text + "%"
                    }
                    queryFinder.where = where
                    queryTaskFinder.execute(queryFinder)

                }else {
                    valuesList = []
                    repeaterValuesList.model = valuesList
                    updateRectHeight()
                }
            }
        }


        // -- Clear text from search box and show only placeholder text
        Rectangle {
            id: rectClearText
            height: Math.min(originalSearchBoxHeight - 4*scaleFactor, 35*scaleFactor)
            width: height
            color: searchBoxColor
            anchors {
                verticalCenter: txtSearch.verticalCenter
                right: parent.right
                rightMargin: 4*scaleFactor
            }

            Image {
                id: imgClearText
                source: "images/clear_text.png"
                anchors.fill: parent
                visible: txtSearch.text !== "" || txtSearch.focus === true
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (imgClearText.visible) {
                        txtSearch.text = ""
                        txtSearch.focus = false
                    }
                }
            }
        }


        // -- Scrollable filtered list of values that match the user's input
        Flickable {
            id: flickableValuesList
            width: parent.width
            height: parent.height - originalSearchBoxHeight - (5*scaleFactor)
            contentHeight: (repeaterValuesList.count*20*scaleFactor) + (repeaterValuesList.count*5*scaleFactor)
            clip: true
            anchors {
                top: txtSearch.bottom
                topMargin: 2*scaleFactor
                left: parent.left
                leftMargin: 8*scaleFactor
            }

            Column {
                spacing: 5*scaleFactor

                Repeater {
                    id: repeaterValuesList
                    model: valuesList

                    Rectangle {
                        width: flickableValuesList.width - (8*scaleFactor)
                        height: 20*scaleFactor
                        color: "transparent"

                        Text {
                            id: txtValue
                            text: modelData
                            font.pointSize: fontSize
                            font.family: fontFamilyName
                            color: searchBoxTextColor
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                // Zoom to, and select the feature
                                findFeature(modelData)
                            }
                        }
                    }
                }
            }
        }


        // -- Query for filtering values based on text entered to search box
        Query {
            id: queryFinder
            returnGeometry: false
            outFields: queryField

        }


        QueryTask {
            id: queryTaskFinder
            url: featLayer.url

            onQueryTaskStatusChanged: {
                if (queryTaskStatus === Enums.QueryTaskStatusCompleted) {
                    valuesList = []

                    valuesList.push(" ")

                    for (var count = 0; count < queryResult.graphics.length; count++) {
                        if (queryResult.graphics[count].attributes[queryFinder.outFields.toString()]) {
                            valuesList.push(queryResult.graphics[count].attributes[queryFinder.outFields.toString()])
                        }
                    }

                    // Sort list
                    valuesList.sort()

                    // Turn off busy indicator
                    valuesList.splice(0, 1)
                    rectSwatches.visible = false
                    timer.running = false

                    // Update model
                    repeaterValuesList.model = valuesList
                    // Update height of search rectangle
                    updateRectHeight()
                    valuesListLength = valuesList.length

                    // Re-set current index for busy indicator
                    currentIndex = 1

                }else if (queryTaskStatus === Enums.QueryTaskStatusErrored) {
                    console.log("Query failed")
                    // Turn off busy indicator
                    valuesList.splice(0, 1)
                    rectSwatches.visible = false
                    timer.running = false
                    // Update model
                    repeaterValuesList.model = valuesList
                    // Update height of search rectangle
                    updateRectHeight()
                    valuesListLength = valuesList.length
                    // Re-set current index for busy indicator
                    currentIndex = 1
                }else {
                    // Insert empty in list for busy indicator
                    valuesList.splice(0, 0, " ")
                    flickableValuesList.contentY = 0
                    repeaterValuesList.model = valuesList
                    updateRectHeight()
                    // Turn on busy indicator
                    rectSwatches.visible = true
                    timer.running = true
                }
            }
        }


        // -- Query for finding the feature that matches the input value
        Query {
            id: queryFeature
            returnGeometry: true
            outSpatialReference: map.spatialReference
            maxFeatures: 1
        }


        QueryTask {
            id: queryTaskFeature
            url: featLayer.url

            onQueryTaskStatusChanged: {
                if (queryTaskStatus === Enums.QueryTaskStatusCompleted) {
                    // Get geometry type of data
                    var geomType = queryResult.graphics[0].geometry.geometryType

                    // If geometry type is not point, get envelope, then get center to convert geom to point
                    if (geomType !== Enums.GeometryTypePoint) {
                        select(queryResult.graphics[0].geometry.queryEnvelope().center)
                    }else {
                        select(queryResult.graphics[0].geometry)
                    }

                    // Select feature
                    featLayer.selectionColor = featureSelectionColor
                    featLayer.selectFeatures(queryFeature, Enums.SelectionMethodNew)

                }else if (queryTaskStatus === Enums.QueryTaskStatusErrored) {
                    console.log("Query failed")
                }
            }
        }
    }


    // -- Update height of drop-down list of values
    function updateRectHeight() {
        if (valuesList.length > 0) {
            if (valuesList.length > 1) {
                rectSearch.height = Math.min(dropDownListMaxHeight, txtSearch.height + (28*scaleFactor*valuesList.length))
            }else {
                // Little extra padding is needed when only one item in drop-down list
                rectSearch.height = Math.min(dropDownListMaxHeight, txtSearch.height + (30*scaleFactor*valuesList.length))
            }
            rectBorder.visible = true

        } else {
            rectSearch.height = originalSearchBoxHeight
            rectBorder.visible = false
        }
    }


    // -- Find feature based on user's input value
    function findFeature(selectedValue) {
        // Update value selected bool to true to make drop-down list of values disappear
        valueSelected = true

        // Update text field to show selected value
        txtSearch.text = selectedValue

        // Clear valuesList to make drop-down list disappear
        valuesList = []

        // Query selected feature
        var where = ""
        if (fieldIsString) {
            where = queryField + " = '" + txtSearch.text + "'"
        }else {
            where = queryField + " = " + txtSearch.text
        }

        // Update where clause and filter values in the search box
        queryFeature.where = where
        queryTaskFeature.execute(queryFeature)

        // Call updateRectHeight function to return the drop down rectangle to its original size
        updateRectHeight()

        // Refresh Repeater model
        repeaterValuesList.model = valuesList

        // Re-set value selected bool - this enables the drop-down list of values to appear
        // when the user continues typing in the text field
        valueSelected = false
    }




    // -- Busy Indicator --
    Rectangle {
        id: rectSwatches
        width: parent.width
        height: 10*scaleFactor
        color: "transparent"
        visible: false
        anchors {
            bottom: parent.bottom
            bottomMargin: -20*scaleFactor
        }
        Row {
            spacing: 5*scaleFactor
            anchors {
                left: parent.left
                leftMargin: 10*scaleFactor
            }

            Repeater {
                model: [1,2,3]
                id: listSwatches
                Rectangle {
                    color: busyIndicatorColor
                    opacity: currentIndex >= index + 1 ? 1 : 0.3
                    width: 9*scaleFactor
                    height: 9*scaleFactor
                    radius: 5*scaleFactor
                }
            }
        }
    }

    Timer {
        id:timer
        interval: 425
        running: false
        repeat: true

        onTriggered:{
            currentIndex = currentIndex + 1
            if (currentIndex > 3) {
                currentIndex = 0
            }
        }
    }

}

