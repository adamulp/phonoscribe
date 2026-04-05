import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ScrollView {
    id: symbolsRoot
    anchors.fill: parent
    anchors.margins: 20
    contentWidth: availableWidth
    clip: true
    
    // FIX 1: Explicitly allow the ScrollView to accept focus
    focus: true 

    // FIX: An invisible dummy item that exists purely to successfully steal focus.
    // (ScrollView naturally resists taking focus itself).
    Item {
        id: focusDummy
        focus: true
    }

    // FIX: TapHandler intercepts clicks without blocking scrolling or text selection,
    // successfully stealing focus away from the TextField when you click outside of it.
    TapHandler {
        onTapped: focusDummy.forceActiveFocus()
    }

    // --- INJECTED DATA ---
    property var phonemeData: null

    property var modifiersList: []
    property var delimitersList: []

    onPhonemeDataChanged: processSymbols()

    function processSymbols() {
        if (!phonemeData) return;
        
        var mList = [];
        // UPDATED: Now iterates over the modifiers array instead of an object
        for (var i = 0; i < phonemeData.modifiers.length; i++) {
            var mItem = phonemeData.modifiers[i];
            mList.push({ type: "modifiers", oldCode: mItem.code, code: mItem.code, ipa: mItem.ipa, name: mItem.name, desc: mItem.desc });
        }
        modifiersList = mList;

        var dList = [];
        // UPDATED: Now iterates over the delimiters array
        for (var j = 0; j < phonemeData.delimiters.length; j++) {
            var dItem = phonemeData.delimiters[j];
            dList.push({ type: "delimiters", oldCode: dItem.code, code: dItem.code, ipa: dItem.ipa, name: dItem.name, desc: dItem.desc });
        }
        delimitersList = dList;
    }

    // --- DATA MUTATION ---
    function updateSymbolCode(type, index, oldCode, newCode) {
        // Prevent accidental blanks or identical saves
        if (oldCode === newCode || newCode.trim() === "") return; 
        
        // 1. UPDATED: Directly mutate the property at the JSON index! Much cleaner.
        phonemeData[type][index].code = newCode;
        
        // 2. Modify the array in-place to retain exact visual order
        if (type === "modifiers") {
            modifiersList[index].code = newCode;
            modifiersList[index].oldCode = newCode;
        } else if (type === "delimiters") {
            delimitersList[index].code = newCode;
            delimitersList[index].oldCode = newCode;
        }

        // 3. Log the update
        var newJsonString = JSON.stringify(phonemeData, null, 2);
        console.log("Data updated internally! New JSON:\n", newJsonString);
        console.log("NOTE: To write this to 'en_phonemes.json' on disk, pass 'newJsonString' to a C++ FileIO class.");
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
                Text { text: "<b>IPA</b>"; textFormat: Text.RichText; font.pixelSize: 15; Layout.preferredWidth: 60 }
                Text { text: "<b>Code</b>"; textFormat: Text.RichText; font.pixelSize: 15; Layout.preferredWidth: 120 }
                Text { text: "<b>Name</b>"; textFormat: Text.RichText; font.pixelSize: 15; Layout.preferredWidth: 180 }
                Text { text: "<b>Description</b>"; textFormat: Text.RichText; font.pixelSize: 15; Layout.fillWidth: true }
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: "#dee2e6"; Layout.bottomMargin: 5 }

            Repeater {
                model: symTable.modelDataList
                delegate: RowLayout {
                    Layout.fillWidth: true
                    Layout.bottomMargin: 8
                    
                    Text { text: modelData.ipa; font.pixelSize: 16; Layout.preferredWidth: 60 }
                    
                    // --- UPDATED TEXTFIELD ---
                    TextField { 
                        text: modelData.code 
                        font.family: "monospace"
                        font.pixelSize: 15
                        
                        // FIX 1: Explicitly set the text color to override Dark Mode defaults
                        color: "#333333" 
                        selectByMouse: true
                        Layout.preferredWidth: 100
                        
                        background: Rectangle {
                            color: parent.activeFocus ? "#ffffff" : "transparent"
                            border.color: parent.activeFocus ? "#007bff" : "transparent"
                            border.width: 1
                            radius: 4
                        }
                        
                        // FIX 2: Automatically select the entire code when clicking/tabbing into the field
                        onActiveFocusChanged: {
                            if (activeFocus) {
                                // Qt.callLater ensures the mouse click event doesn't immediately deselect the text
                                Qt.callLater(selectAll)
                            }
                        }

                        // Hit escape to cancel edits
                        Keys.onEscapePressed: {
                            text = modelData.oldCode; 
                            focus = false; 
                        }

                        // Hit enter to drop focus
                        onAccepted: {
                            focus = false;
                        }
                        
                        onEditingFinished: {
                            // The Repeater gives us 'index' natively, allowing us to update the exact row
                            symbolsRoot.updateSymbolCode(modelData.type, index, modelData.oldCode, text);
                            // FIX 2: We explicitly DO NOT set `focus = false;` here anymore.
                            // If the user presses Tab, they naturally lose focus on this field (triggering this block)
                            // while seamlessly retaining focus on the newly targeted field!
                            
                            // Keep QML state consistent locally
                            modelData.oldCode = text;
                            modelData.code = text;
                        }
                    }
                    
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
