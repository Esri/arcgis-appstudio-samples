import QtQuick 2.3
import QtQuick.Controls 1.2

Rectangle {

                    //width: parent.width
                    width: Math.min(parent.width-20*app.scaleFactor, 400*app.scaleFactor)
                    height: 50*app.scaleFactor
                    anchors.topMargin: 20 * app.scaleFactor
                    anchors.bottomMargin: 20 * app.scaleFactor
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: "transparent"

                    Label {
                        id: fieldAliasLabel

                        font.italic: true
                        opacity: 0.8
                        //anchors.margins: 5*app.scaleFactor
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: parent.height*0.4
                        width: parent.width
                        anchors.bottomMargin: 5*app.scaleFactor
                        fontSizeMode: Text.HorizontalFit
                        //maximumLineCount: 2
                        elide: Text.ElideRight
                        wrapMode: Text.Wrap
                        color: app.textColor
                    }

                }

