import QtQuick 2.7

/* This is used to store all the fonts */
Item {
    // References for all the fonts
    property alias fontFamily_Regular: fontFamily_Regular
    property alias fontFamily_Medium: fontFamily_Medium

    // Regular
    FontLoader {
        id: fontFamily_Regular
    }

    // Medium
    FontLoader {
        id: fontFamily_Medium
    }
}
