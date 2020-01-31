import QtQuick 2.12
import QtQuick.Controls 2.12

QtObject {
    //property var normal:
        //id: normal
    //}

    //property Label normal: Label { font.pointSize: 10 }
    //property Label heading1: Label { font.pointSize: 14; font.bold: true }
    //property Label heading2: Label { font.pointSize: 12; font.bold: true }
    //property Label heading3: Label { font.pointSize: 10; font.bold: true }

    property var normal: ( { pointSize: 10 } )
    property var heading1: ( { pointSize: 14, bold: true } )
    property var heading2: ( { pointSize: 12, bold: true } )
    property var heading3: ( { pointSize: 10, bold: true } )

}
