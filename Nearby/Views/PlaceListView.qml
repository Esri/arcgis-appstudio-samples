import QtQuick 2.9
import QtQuick.Controls 2.5
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.1
import ArcGIS.AppFramework.Notifications 1.0

import "../Widgets"

Drawer {
    id: placeInfoView

    property alias resultListView: resultListView

    ListView {
        id: resultListView
        x: statusBarControl.safeAreaMargins
        anchors.fill: parent
        orientation: appManager.isSmall? ListView.Horizontal: ListView.Vertical
        model: resultListModel
        clip: true
        spacing: 4
        preferredHighlightBegin: 8 * app.scaleFactor
        preferredHighlightEnd: 8 * app.scaleFactor
        highlightRangeMode: ListView.StrictlyEnforceRange
        highlightMoveDuration: 10
        highlightResizeDuration: 10
        highlightResizeVelocity: 2000
        highlightMoveVelocity: 2000
        highlightFollowsCurrentItem: appManager.isLarge? false: true
        focus: true
        snapMode: appManager.isLarge? ListView.NoSnap: ListView.SnapOneItem

        delegate: PlaceCard {
            title: name

            width: Math.min(app.width - 48 * app.scaleFactor, 316 * app.scaleFactor)
            height: appManager.isSmall? parent.height: 172 * app.scaleFactor
            anchors.topMargin: appManager.isSmall? 8 * app.scaleFactor: 0
            placeDistance: distanceText
            category: type
            placeAddress: address
            website: url
            phoneNumber: phone
            isClickable: appManager.isLarge
            isHighlighted: index === resultListView.currentIndex

            onCardClicked: {
                resultListView.currentIndex = index;
                showSelectedPlaceInfo(index);
            }

            onDirectionsClicked: {
                HapticFeedback.send("Select");
                placeInfoView.close();
                routeView.point = point;
                routeView.name = name;
                routeView.getRoute();
                placeInfoView.close();
                isInRouteMode = true;
                routeView.show();
            }

            onWebsiteClicked: {
                HapticFeedback.send("Select");
                browserView.url = url;
                placeInfoView.close();
                browserView.show();
            }

            onCallClicked: {
                HapticFeedback.send("Select")
                Qt.openUrlExternally("tel:%1".arg(phone));
            }
        }

        onFlickEnded: {
            loadSelectedPlace(currentIndex);
        }
    }

    onAboutToHide: {
        if(resultListModel.get(currentIndex))
        restoreCategoryGraphic(resultListModel.get(currentIndex).point,
                               resultListModel.get(currentIndex).type,
                               currentIndex);
    }

    Component.onCompleted: {
        resultListView.currentIndex = -1;
    }
}
