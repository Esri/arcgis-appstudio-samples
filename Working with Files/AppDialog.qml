import QtQuick 2.12
import QtQuick.Controls 2.12

Dialog {
    modal: true
    anchors.centerIn: Overlay.overlay

    property alias textBody: textComponent.text

    AppTextBody {
        id: textComponent
        width: parent.width
    }

}
