import QtQuick 2.3
import QtQuick.Controls 1.2
import ArcGIS.AppFramework.Runtime 1.0

Column {
    id: column

   anchors{
        left: parent.left
        right:parent.right
    }
    spacing: 3

    Label {
        text: fieldAlias
        font.italic: true
        opacity: 0.8
        height: parent.height*0.4
        width: parent.width
        fontSizeMode: Text.HorizontalFit
        elide: Text.ElideRight
        wrapMode: Text.Wrap
        color: app.textColor
    }
    ComboBox {
        id: comboBox
        model: codedValueArray
        anchors{
            left: parent.left
            right:parent.right
        }

        enabled: !isSubTypeField

        onCurrentIndexChanged: {
            attributesArray[fieldName] = codedCodeArray[comboBox.currentIndex];
        }
    }

    Component.onCompleted: {
        if ( isSubTypeField ){
            comboBox.currentIndex = pickListIndex;
        }
        else {
            if ( hasPrototype ) {
               console.log(codedCodeArray.indexOf( defaultValue.toString() ), typeof ( codedCodeArray.indexOf( defaultValue.toString() )), codedValueArray.indexOf( codedValueArray[codedCodeArray.indexOf( defaultValue.toString() )]) )
                comboBox.currentIndex = codedValueArray.indexOf( codedValueArray[codedCodeArray.indexOf( defaultValue.toString() )]);
            }
            else {
            comboBox.currentIndex = defaultIndex;
            }
        }
        attributesArray[fieldName] = codedCodeArray[comboBox.currentIndex];
    }
}
