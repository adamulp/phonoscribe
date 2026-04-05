import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ApplicationWindow {
    visible: true
    width: 480
    height: 380
    title: "English Vowels"
    color: "#ffffff"

    // Reusable inline component for the Vowel Labels
    component VowelLabel : Rectangle {
        id: labelRoot
        property string codeText: ""
        property string ipaText: ""
        property string extraText: "" // Used for the combined aa/ah label
        property real relX: 0.0
        property real relY: 0.0

        // Convert the HTML percentages to relative positioning
        x: parent.width * relX
        y: parent.height * relY

        width: contentRow.implicitWidth + 6
        height: contentRow.implicitHeight + 4
        color: "white"
        radius: 3

        Row {
            id: contentRow
            anchors.centerIn: parent
            spacing: 4
            
            Text {
                text: "<font face='monospace'>" + labelRoot.codeText + "</font>"
                textFormat: Text.RichText
                font.pixelSize: 15
            }
            Text {
                text: labelRoot.ipaText
                font.pixelSize: 15
            }
            // Only shows up if we pass extra data (for the bottom right corner)
            Text {
                visible: labelRoot.extraText !== ""
                text: labelRoot.extraText
                textFormat: Text.RichText
                font.pixelSize: 15
            }
        }
    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 15

        Text {
            text: "English Vowels"
            font.pixelSize: 18
            font.bold: true
            Layout.alignment: Qt.AlignHCenter
        }

        RowLayout {
            spacing: 10

            // Left Column: Vertical Y-axis Labels
            Column {
                Layout.alignment: Qt.AlignTop
                spacing: 0
                
                // Generates the 7 vertical rows, each 30px high to match the 210px chart
                Repeater {
                    model: ["Close", "Near-close", "Close-mid", "Mid", "Open-mid", "Near-open", "Open"]
                    Text {
                        text: "<b>" + modelData + "</b>"
                        textFormat: Text.RichText
                        font.pixelSize: 11
                        horizontalAlignment: Text.AlignRight
                        verticalAlignment: Text.AlignVCenter
                        width: 80
                        height: 30
                    }
                }
            }

            // Right Column: Top X-axis Labels + Vowel Trapezoid
            Column {
                spacing: 0

                // Top X-axis Labels
                Row {
                    width: 300
                    height: 25
                    Text { text: "<b>Front</b>"; textFormat: Text.RichText; font.pixelSize: 11; width: 60; horizontalAlignment: Text.AlignHCenter }
                    Text { text: "<b>Central</b>"; textFormat: Text.RichText; font.pixelSize: 11; width: 180; horizontalAlignment: Text.AlignHCenter }
                    Text { text: "<b>Back</b>"; textFormat: Text.RichText; font.pixelSize: 11; width: 60; horizontalAlignment: Text.AlignHCenter }
                }

                // The Chart Area
                Rectangle {
                    width: 300
                    height: 210
                    color: "transparent"

                    Image {
                        anchors.fill: parent
                        source: "https://upload.wikimedia.org/wikipedia/commons/thumb/4/4f/Blank_vowel_trapezoid.svg/330px-Blank_vowel_trapezoid.svg.png"
                        fillMode: Image.PreserveAspectFit
                    }

                    // --- Front Vowels ---
                    VowelLabel { codeText: "i";  ipaText: "/i/"; relX: 0.02; relY: 0.02 }
                    VowelLabel { codeText: "I";  ipaText: "/ɪ/"; relX: 0.14; relY: 0.16 }
                    VowelLabel { codeText: "e";  ipaText: "/e/"; relX: 0.18; relY: 0.30 }
                    VowelLabel { codeText: "ae"; ipaText: "/æ/"; relX: 0.35; relY: 0.73 }

                    // --- Central Vowels ---
                    VowelLabel { codeText: "uh"; ipaText: "/ə/"; relX: 0.46; relY: 0.44 }
                    VowelLabel { codeText: "er"; ipaText: "/ɜː/"; relX: 0.44; relY: 0.58 }
                    VowelLabel { codeText: "^";  ipaText: "/ʌ/"; relX: 0.58; relY: 0.68 }

                    // --- Back Vowels ---
                    VowelLabel { codeText: "u";  ipaText: "/u/"; relX: 0.78; relY: 0.02 }
                    VowelLabel { codeText: "oo"; ipaText: "/ʊ/"; relX: 0.72; relY: 0.16 }
                    VowelLabel { codeText: "ou"; ipaText: "/ɔː/"; relX: 0.76; relY: 0.58 }
                    
                    // The combined aa/ah label
                    VowelLabel { 
                        codeText: "aa"; 
                        ipaText: "/ɑː/"; 
                        extraText: " &bull; <font face='monospace'>ah</font> /ɒ/"; 
                        relX: 0.58; 
                        relY: 0.86 
                    }
                }
            }
        }
    }
}
