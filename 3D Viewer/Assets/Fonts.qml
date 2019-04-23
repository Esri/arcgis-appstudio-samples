import QtQuick 2.9

import ArcGIS.AppFramework 1.0

Item {
    id: root

    property string avenirNextDemi: system
    property string avenirNextRegular: system

    property string system: Qt.font({ pixelSize: 16 }).family

    FileFolder {
        id: fontsFolder

        url: "Fonts"
    }

    Component {
        id: fontLoader

        FontLoader {
            property string fileName

            source: fontsFolder.fileUrl(fileName)

            onStatusChanged: {
                if (status === FontLoader.Ready) {
                    switch (name) {
                    case "Avenir Next W1G Demi":
                        avenirNextDemi = name;
                        break;

                    case "Avenir Next W1G Regular":
                        avenirNextRegular = name;
                        break;
                    }
                }

                if (status === FontLoader.Error)
                    console.error("The Font %1 can not be loaded!".arg(name));
            }
        }
    }

    function loadFonts() {
        var _fileNames = fontsFolder.fileNames();

        for (var i in _fileNames) {
            var _fileName = _fileNames[i];
            var loader = fontLoader.createObject
                    (root,
                     {
                         fileName: _fileName
                     });
        }
    }
}
