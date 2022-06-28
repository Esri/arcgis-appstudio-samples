import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.1


Page {
    id: rootPage

    width: app.width

    Material.theme: Material.Dark
    Material.background: rootPage.getAppProperty(app.backgroundColor, "#F7F8F8")
    Material.primary: rootPage.getAppProperty(app.primaryColor, "#166DB2")
    Material.accent: rootPage.getAppProperty(app.accentColor, "#FF9800")
    Material.foreground: rootPage.getAppProperty(app.foregroundColor, "#22000000")

    property int pageWidth:app.width
    property Item pageContentItem: null
    property Item headerContentItem: null
    property Item footerContentItem: null

    signal next()
    signal previous()

    function getAppProperty (appProperty, fallback) {
        if (!fallback) fallback = ""
        try {
            return appProperty ? appProperty : fallback
        } catch (err) {
            return fallback
        }
    }

    header: HeaderBar{
        width: parent.width
        headerContent: headerContentItem
    }

    contentItem: pageContentItem

    footer: FooterBar {
        width: parent.width
        footerContent: footerContentItem
    }
}
