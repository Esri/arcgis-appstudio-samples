import QtQuick 2.9
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2

Menu {
    id: optionMenu

    width: 208 * constants.scaleFactor
    Material.elevation: 8
    padding: 0

    onOpened: {
        this.forceActiveFocus();
    }

    onClosed: {
        app.forceActiveFocus();
    }
}
