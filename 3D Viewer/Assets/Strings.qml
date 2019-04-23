import QtQuick 2.9

Item {
    id: root

    readonly property string app_title: qsTr("3D Viewer")
    readonly property string start_button: qsTr("GET STARTED")
    readonly property string web_scenes: qsTr("Web Scenes")
    readonly property string bookmarks: qsTr("Bookmarks")
    readonly property string empty_state_no_bookmarks: qsTr("Looks like there is no bookmark.")
    readonly property string dialog_no_location_permission_title: qsTr("Location access disabled")
    readonly property string dialog_no_location_permission_description: qsTr("Please enable Location access permission for 3D Viewer in the device Settings.")
    readonly property string okay: qsTr("OKAY")
    readonly property string app_settings: qsTr("App Settings")
    readonly property string clipboard_copy: qsTr("Copied to the clipboard.")
    readonly property string error: qsTr("Error")
    readonly property string dialog_invalid_url_description: qsTr("Unable to connect Portal right now. Please check the url or try again later.")
    readonly property string empty_state_no_result: qsTr("No result found.")
    readonly property string dialog_not_web_scene_item_description: qsTr("This item is not a web scene.")
}
