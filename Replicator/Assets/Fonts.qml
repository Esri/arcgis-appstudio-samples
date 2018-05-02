import QtQuick 2.7

/* This is used to store all the fonts */
Item {
    // References for all the fonts
    property alias fontFamily_Regular: fontFamily_Regular
    property alias fontFamily_Medium: fontFamily_Medium

    // Regular
    FontLoader {
        id: fontFamily_Regular
        source: app.folder.fileUrl("Assets/Fonts/AvenirNext-Regular.ttf")
    }

    // Medium
    FontLoader {
        id: fontFamily_Medium
        source: app.folder.fileUrl("Assets/Fonts/AvenirNext-Medium.ttf")
    }
}
