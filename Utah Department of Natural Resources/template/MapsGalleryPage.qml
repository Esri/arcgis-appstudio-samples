import QtQuick 2.2
import QtQuick.Controls 1.1

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import ArcGIS.AppFramework.Runtime 1.0

Rectangle {
    id: gallery

    property Portal portal

    signal exitClicked()
    signal mapSelected(PortalItemInfo itemInfo);

    color: app.info.propertyValue("galleryBackgroundColor", "#0079c1")

    Component.onCompleted: {
        mapsListView.refresh();
    }

    Image {
        anchors.fill: parent
        source: app.folder.fileUrl(app.info.propertyValue("galleryBackground", "assets/galleryBackground.png"))
        fillMode: Image.PreserveAspectCrop
    }

    Rectangle {
        anchors.fill: parent
        color: app.info.propertyValue("galleryForegroundColor", "#80000000")
    }

    Flickable {
        anchors.fill: parent

        interactive: false // TODO finish flick handling

        flickableDirection: Flickable.HorizontalFlick

        rebound: Transition {
        }

        onFlickEnded: {
        }

        Item {
            anchors.fill: parent

            ImageButton {
                id: exitButton

                width: 50 * AppFramework.displayScaleFactor
                height: width

                anchors {
                    left: parent.left
                    top: parent.top
                    margins: 5
                }

                //source: "images/left2.png"
                hoverColor: app.hoverColor
                pressedColor: app.pressedColor

                onClicked: {
                    exitClicked();
                }
            }

            Text {
                id: titleText

                anchors {
                    left: exitButton.right
                    right: parent.right
                    rightMargin: exitButton.width + exitButton.anchors.margins
                    top: exitButton.top
                    bottom: exitButton.bottom
                }

                text: app.info.title
                font {
                    pointSize: 50
                }
                fontSizeMode: Text.Fit
                color: "#f7f8f8"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }

            Item {
                anchors {
                    left: parent.left
                    right: parent.right
                    top: titleText.bottom
                    bottom: parent.bottom
                    margins: 10
                }

                clip: true

                MapsListView {
                    id: mapsListView

                    anchors.fill: parent

                    portal: gallery.portal
                    searchQuery: app.info.propertyValue("galleryMapsQuery", "");


                    delegate: app.compactLayout ? compactDelgate : fullSizeDelegate

                    //            highlightFollowsCurrentItem: true
                    //            highlight: MapsListHighlight {

                    //            }

                    onSearchCompleted: {
                        //                        if (model.length === 1) {
                        //                            mapsListView.currentIndex = 0;
                        //                            gallery.mapSelected(mapsListView.currentTour);
                        //                        }
                    }
                }

                Component {
                    id: fullSizeDelegate

                    MapsListDelegate {
                        onClicked: {
                            gallery.mapSelected(mapsListView.currentTour);
                        }

                        onDoubleClicked: {
                            //                    gallery.mapSelected(mapsListView.currentTour);
                        }
                    }
                }

                Component {
                    id: compactDelgate

                    MapsListCompactDelegate {
                        onClicked: {
                            gallery.mapSelected(mapsListView.currentTour);
                        }

                        onDoubleClicked: {
                            //                    gallery.mapSelected(mapsListView.currentTour);
                        }
                    }
                }
            }
        }
    }

    NoNetwork {
    }
}
