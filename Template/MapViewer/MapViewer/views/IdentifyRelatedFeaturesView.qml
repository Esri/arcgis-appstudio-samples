import QtQuick 2.7
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.1
import QtGraphicalEffects 1.0

import "../controls" as Controls

Flickable
{
    width:panelPage.width
    height:panelPage.height
    contentWidth: panelPage.width
    contentHeight: relatedview.height + 150 * scaleFactor

    id: root1
    property var featureList: ListModel{}
    property var showFeatureClassName:({})

    property var servicestate: ({})
    clip:true

    ColumnLayout{
        id:relatedview

        width:panelPage.width
        spacing:0


        RowLayout{
            spacing:0
            Layout.preferredHeight:0.8 * app.headerHeight
            Controls.BaseText {

                text:qsTr("Items:")
                color: app.black_87

                elide: Text.ElideRight
                textFormat: Text.StyledText
                Material.accent: app.accentColor

                leftPadding: 16 * scaleFactor

            }
            Controls.BaseText {

                text:featureList.count
                color: app.black_87


                elide: Text.ElideRight
                textFormat: Text.StyledText
                Material.accent: app.accentColor
                Layout.leftMargin: 5 * scaleFactor


            }
        }

        ColumnLayout{
            Layout.preferredWidth:panelPage.width

            spacing:44 * scaleFactor



            Repeater{
                id:repeaterFeatureList

                model:featureList //get the list of featureClasses

                Item{
                    Layout.preferredWidth:parent.width
                    Layout.preferredHeight:showInView === true?features.count * 30 * scaleFactor:0
                    Layout.bottomMargin: showInView === true?app.units(10):0
                    ColumnLayout{
                        id:featurelistrows
                        spacing:0
                        width:parent.width
                        Rectangle{
                            Layout.preferredWidth:parent.width
                            Layout.preferredHeight:1
                            color:app.separatorColor


                        }

                        Rectangle{
                            Layout.fillWidth: true

                            Layout.preferredHeight: 0.8 * app.headerHeight
                            color:"#EDEDED"

                            RowLayout{
                                width:parent.width
                                height:parent.height

                                Rectangle{
                                    id:servicename
                                    Layout.preferredWidth: parent.width - expandIcon.width - featurescount.width - 20 * scaleFactor //- layerIcon.width - app.defaultMargin
                                    Layout.preferredHeight:0.8 * app.headerHeight
                                    color:"#EDEDED"


                                    Controls.BaseText {

                                        width:parent.width

                                        text:serviceLayerName
                                        color: app.black_87
                                        maximumLineCount: 1
                                        elide: Text.ElideRight
                                        textFormat: Text.StyledText
                                        Material.accent: app.accentColor
                                        anchors.verticalCenter: parent.verticalCenter


                                        leftPadding: app.units(16)
                                        rightPadding: leftPadding

                                    }
                                }


                                Rectangle {
                                    id: featurescount


                                    color:"transparent"

                                    border.color: Qt.darker(app.backgroundColor, 1.9)

                                    Layout.preferredWidth: 0.7 * expandIcon.Layout.preferredWidth
                                    Layout.preferredHeight: Layout.preferredWidth
                                    radius: Layout.preferredWidth
                                    visible:true
                                    Layout.rightMargin: app.units(10)

                                    Controls.BaseText {
                                        text: features.count
                                        anchors.centerIn: parent
                                    }
                                }


                                Controls.Icon {
                                    id: expandIcon
                                    Layout.preferredWidth: app.units(40)
                                    Layout.preferredHeight:app.units(40)
                                    Layout.rightMargin: app.units(10)

                                    maskColor: app.subTitleTextColor
                                    imageSource: "../images/arrowDown.png"
                                    rotation:showInView === true? 180:0
                                    visible:!(featureList.count === 1 && features.count === 1)

                                }

                            }


                            Rectangle{
                                width:parent.width
                                height:1
                                color:app.separatorColor
                                anchors.bottom: parent.bottom
                            }

                            MouseArea {

                                anchors.fill: parent
                                onClicked: {
                                    root1.toggle(serviceLayerName)
                                }
                            }

                        }

                        ListView {
                            id: identifyRelatedFeaturesViewlst1
                            Layout.fillWidth: true
                            Layout.preferredHeight:panelPage.height - 1.8 * app.headerHeight


                            model:features.get(0).fields
                            visible:featureList.count === 1 && features.count === 1
                            footer:Rectangle{
                                height:100 * scaleFactor
                                width:identifyRelatedFeaturesViewlst1.width
                                color:"transparent"
                            }


                            clip: true

                            delegate: ColumnLayout {
                                id: contentColumn

                                width: parent.width
                                spacing: 0

                                Item {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: app.units(6)
                                }

                                Controls.SubtitleText {
                                    id: lbl

                                    objectName: "label"


                                    text: typeof FieldName !== "undefined" ? (FieldName ? FieldName : "") : ""
                                    Layout.fillWidth: true

                                    Layout.preferredHeight: visible ? implicitHeight:0
                                    Layout.leftMargin: app.defaultMargin
                                    Layout.rightMargin: app.defaultMargin
                                    Layout.bottomMargin: 6 * scaleFactor

                                    wrapMode: Text.WrapAnywhere
                                }



                                Controls.BaseText {
                                    id: desc
                                    Layout.preferredWidth: parent.width - app.units((16))

                                    objectName: "description"


                                    text: typeof FieldValue !== "undefined" ? (FieldValue ? FieldValue : "") : ""


                                    Layout.preferredHeight: visible ? implicitHeight:0
                                    Layout.leftMargin: app.defaultMargin
                                    Layout.rightMargin: app.defaultMargin
                                    Layout.bottomMargin: 10 * scaleFactor
                                    elide: Text.ElideRight

                                    wrapMode: Text.WordWrap
                                    textFormat: Text.StyledText
                                    Material.accent: app.accentColor





                                }


                            }

                        }





                        ColumnLayout{

                            visible: showInView === true && (featureList.count > 1 || featureList.get(0).features.count > 1)
                            Layout.preferredHeight:showInView === true?implicitHeight:0

                           Item {
                                Layout.fillWidth: true
                                Layout.preferredHeight: app.units(6)

                            }
                            Repeater{
                                model:features

                                    Controls.BaseText {
                                        id:display
                                        Layout.preferredWidth: parent.width - 30 * scaleFactor

                                        text:displayFieldName
                                        color:primaryColor
                                        maximumLineCount: 1
                                        elide: Text.ElideRight
                                        verticalAlignment: Qt.AlignVCenter

                                        textFormat: Text.StyledText
                                        Material.accent: app.accentColor

                                        leftPadding: app.units(20)
                                        rightPadding: leftPadding
                                        bottomPadding: app.units(6)
                                        Layout.bottomMargin: app.units(6)
                                        MouseArea{
                                            anchors.fill: parent
                                            onClicked: {
                                                identifyRelatedFeaturesViewlst.model= fields
                                                panelPage.headerText = serviceLayerName + " - " + displayFieldName
                                                relateddetails.visible = true
                                                panelContent.visible = false
                                                panelPage.isHeaderVisible = false
                                                if(geometry)
                                                    mapView.identifyProperties.showInMap(geometry,false)



                                            }
                                        }

                                    }


                            }


                        }



                    }


                }



            }

            Rectangle{
                Layout.preferredWidth:parent.width
                Layout.preferredHeight:app.units(20)
                color:"transparent"



            }
        }
    }

    function toggle (serviceLayerName) {
        if(servicestate[serviceLayerName]){
            state = servicestate[serviceLayerName]
        }
        else
        {
            servicestate[serviceLayerName] = "NOTEXPANDED"
            state = "NOTEXPANDED"
        }

        state = state === "EXPANDED" ? "NOTEXPANDED" : "EXPANDED"
        if (state === "EXPANDED") {

            root1.expandSection(serviceLayerName, true)
        } else {

            root1.collapseSection(serviceLayerName, false)
        }
        servicestate[serviceLayerName] = state
    }

    function expandSection (serviceLayerName,expand) {

        for (var i=0; i<repeaterFeatureList.model.count; i++) {
            var item = repeaterFeatureList.model.get(i)
            if (item.serviceLayerName === serviceLayerName) {


                item["showInView"] = expand

                repeaterFeatureList.model.set(i,item)
            }
        }
    }

    function collapseSection (serviceLayerName,expand) {
        for (var i=0; i<repeaterFeatureList.model.count; i++) {
            var item = repeaterFeatureList.model.get(i)
            if (item.serviceLayerName === serviceLayerName) {

                item["showInView"] = expand

                repeaterFeatureList.model.set(i,item)
            }
        }
    }




}




