import QtQuick 2.3
import QtQuick.Controls 1.3
import QtQuick.Controls.Styles 1.3

Column {
    id: column
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
        anchors{
            left: parent.left
            right:parent.right
        }

        //enabled: false

        model: codedValueArray

        onCurrentIndexChanged: {
            listView.onAttributeUpdate(objectName, codedCodeArray[comboBox.currentIndex])
        }

        Component.onCompleted: {
            //comboBox.model = codedValueArray;
            comboBox.currentIndex = pickListIndex;
            console.log("cbx", comboBox.model.count);
            console.log("cbx", codedValueArray);

            listView.onAttributeUpdate(objectName, codedCodeArray[comboBox.currentIndex])

        }
    }
}

