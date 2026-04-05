import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ScrollView {
    id: symbolsRoot
    anchors.fill: parent
    anchors.margins: 20
    contentWidth: availableWidth
    clip: true

    // --- INJECTED DATA ---
    property var phonemeData: null

    property var modifiersList: []
    property var delimitersList: []

    // Re-process the lists whenever the main app passes us the JSON
    onPhonemeDataChanged: processSymbols()

    function processSymbols() {
        if (!phonemeData) return;
        
        var mList = [];
        for (var mKey in phonemeData.modifiers) {
            var mItem = phonemeData.modifiers[mKey];
            mList.push({ code: mKey, ipa: mItem.ipa, name: mItem.name, desc: mItem.desc });
        }
        modifiersList = mList;

        var dList = [];
        for (var dKey in phonemeData.delimiters) {
            var dItem = phonemeData.delimiters[dKey];
            dList.push({ code: dKey, ipa: dItem.ipa, name: dItem.name, desc: dItem.desc });
        }
        delimitersList = dList;
    }

    // --- REUSABLE COMPONENTS ---
    component SymbolTable : Rectangle {
        id: symTable
        Layout.fillWidth: true
        implicitHeight: symLayout.implicitHeight + 20
        color: "#f8f9fa"
        border.color: "#dee2e6"
        border.width: 1
        radius: 8

        property var modelDataList: []

        ColumnLayout {
            id: symLayout
            anchors.fill: parent
            anchors.margins: 15
            spacing: 8

            // Headers
            RowLayout {
                Layout.fillWidth: true
                Text { text: "<b>Code</b>"; textFormat: Text.RichText; font.pixelSize: 15; Layout.preferredWidth: 80 }
                Text { text: "<b>IPA</b>"; textFormat: Text.RichText; font.pixelSize: 15; Layout.preferredWidth: 60 }
                Text { text: "<b>Name</b>"; textFormat: Text.RichText; font.pixelSize: 15; Layout.preferredWidth: 180 }
                Text { text: "<b>Description</b>"; textFormat: Text.RichText; font.pixelSize: 15; Layout.fillWidth: true }
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: "#dee2e6"; Layout.bottomMargin: 5 }

            Repeater {
                model: symTable.modelDataList
                delegate: RowLayout {
                    Layout.fillWidth: true
                    Layout.bottomMargin: 8
                    
                    Text { text: "<font face='monospace'>" + modelData.code + "</font>"; textFormat: Text.RichText; font.pixelSize: 16; Layout.preferredWidth: 80 }
                    Text { text: modelData.ipa; font.pixelSize: 16; Layout.preferredWidth: 60 }
                    Text { text: modelData.name; font.pixelSize: 15; font.bold: true; color: "#333333"; Layout.preferredWidth: 180 }
                    Text { text: modelData.desc; font.pixelSize: 15; color: "#666666"; wrapMode: Text.WordWrap; Layout.fillWidth: true }
                }
            }
        }
    }

    // --- TAB LAYOUT ---
    ColumnLayout {
        width: parent.width
        spacing: 25

        Text {
            text: "Modifiers & Delimiters"
            font.pixelSize: 22
            font.bold: true
            Layout.alignment: Qt.AlignLeft
        }

        Text {
            text: "Modifiers"
            font.pixelSize: 18
            font.bold: true
            color: "#4caf50"
            Layout.topMargin: 10
        }
        
        SymbolTable {
            modelDataList: symbolsRoot.modifiersList
        }

        Text {
            text: "Delimiters"
            font.pixelSize: 18
            font.bold: true
            color: "#007bff"
            Layout.topMargin: 20
        }
        
        SymbolTable {
            modelDataList: symbolsRoot.delimitersList
        }
    }
}
