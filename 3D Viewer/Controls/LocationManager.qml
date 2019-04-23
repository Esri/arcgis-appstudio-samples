import QtQuick 2.9
import QtPositioning 5.8

PositionSource {
    id: root

    property var coordinate: position.coordinate

    updateInterval: 10000
}
