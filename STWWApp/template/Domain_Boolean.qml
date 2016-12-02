import QtQuick 2.0

Rectangle{
    width: Math.min(parent.width-20*app.scaleFactor, 400*app.scaleFactor)
    height: 50*app.scaleFactor
    anchors.topMargin: 20 * app.scaleFactor
    anchors.bottomMargin: 20 * app.scaleFactor
    anchors.horizontalCenter: parent.horizontalCenter
    color: "#C86A4A"
    Text{
        text: fieldName + ", " + fieldValue + ", " + fieldType;
    }
}
