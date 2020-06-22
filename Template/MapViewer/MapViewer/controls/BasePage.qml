import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1

Page {

    id: root

    signal next()
    signal previous()

    Material.theme: Material.Dark
    Material.background: root.getAppProperty(app.backgroundColor, "#F7F8F8")
    Material.primary: root.getAppProperty(app.primaryColor, "#166DB2")
    Material.accent: root.getAppProperty(app.accentColor, "#FF9800")
    Material.foreground: root.getAppProperty(app.foregroundColor, "#22000000")

    function getAppProperty (appProperty, fallback) {
        if (!fallback) fallback = ""
        try {
            return appProperty ? appProperty : fallback
        } catch (err) {
            return fallback
        }
    }
}
