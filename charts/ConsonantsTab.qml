import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ScrollView {
    id: consonantsRoot
    anchors.fill: parent
    anchors.margins: 20
    contentWidth: availableWidth
    contentHeight: mainConsonantColumn.implicitHeight
    clip: true

    // --- INJECTED DATA ---
    property var phonemeData: null

    function getC(code) {
        if (!phonemeData) return "";
        for (var category in phonemeData.consonants) {
            var arr = phonemeData.consonants[category];
            for (var i = 0; i < arr.length; i++) {
                if (arr[i].code === code) {
                    return "<code>" + code + "</code><br>/" + arr[i].ipa + "/";
                }
            }
        }
        return "";
    }

    // --- REUSABLE COMPONENTS ---
    component Cell : Rectangle {
        id: cellRoot
        property string content: ""
        property bool isHeader: false
        property bool isRowHeader: false
        property bool isInvalid: false
        
        color: isHeader ? "#eaecf0" : (isInvalid ? "#cccccc" : "#ffffff")
        
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.minimumHeight: isHeader ? 30 : 55
        Layout.minimumWidth: isRowHeader ? 140 : 45

        Text {
            anchors.fill: parent
            anchors.margins: 4
            leftPadding: cellRoot.isRowHeader ? 5 : 0
            text: cellRoot.content.replace(/<code>/g, "<font face='monospace'>").replace(/<\/code>/g, "</font>")
            textFormat: Text.RichText
            font.pixelSize: 14
            horizontalAlignment: cellRoot.isRowHeader ? Text.AlignLeft : Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            wrapMode: Text.WordWrap
        }
    }

    // --- TAB LAYOUT ---
    ColumnLayout {
        id: mainConsonantColumn
        width: parent.width
        spacing: 15

        Text {
            text: "English Consonants (Voiced / Unvoiced)"
            font.pixelSize: 22
            font.bold: true
            Layout.alignment: Qt.AlignLeft
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: grid.implicitHeight
            color: "#a2a9b1"

            GridLayout {
                id: grid
                anchors.fill: parent
                anchors.margins: 1
                rowSpacing: 1
                columnSpacing: 1
                columns: 17

                // Headers
                Cell { content: "<span style='font-size:12px'>Place of articulation &rarr;</span>"; isHeader: true; isRowHeader: true }
                Cell { content: "<b>Labial</b>"; isHeader: true; Layout.columnSpan: 4 }
                Cell { content: "<b>Coronal</b>"; isHeader: true; Layout.columnSpan: 6 }
                Cell { content: "<b>Dorsal</b>"; isHeader: true; Layout.columnSpan: 4 }
                Cell { content: "<b>Laryngeal</b>"; isHeader: true; Layout.columnSpan: 2 }

                Cell { content: "<span style='font-size:12px'>Manner of articulation &darr;</span>"; isHeader: true; isRowHeader: true }
                Cell { content: "Bilabial"; isHeader: true; Layout.columnSpan: 2 }
                Cell { content: "Labio-dental"; isHeader: true; Layout.columnSpan: 2 }
                Cell { content: "Dental"; isHeader: true; Layout.columnSpan: 2 }
                Cell { content: "Alveolar"; isHeader: true; Layout.columnSpan: 2 }
                Cell { content: "Post-alveolar"; isHeader: true; Layout.columnSpan: 2 }
                Cell { content: "Palatal"; isHeader: true; Layout.columnSpan: 2 }
                Cell { content: "Velar"; isHeader: true; Layout.columnSpan: 2 }
                Cell { content: "Glottal"; isHeader: true; Layout.columnSpan: 2 }

                Cell { isHeader: true; isRowHeader: true }
                Repeater {
                    model: ["VL", "VD", "VL", "VD", "VL", "VD", "VL", "VD", "VL", "VD", "VL", "VD", "VL", "VD", "VL", "VD"]
                    Cell { content: "<span style='font-size:11px; color:#666666'>" + modelData + "</span>"; isHeader: true }
                }

                // --- ROW 4: Nasal ---
                Cell { content: "<b>Nasal</b>"; isHeader: true; isRowHeader: true }
                Cell { } Cell { content: consonantsRoot.getC("m") } 
                Cell { isInvalid: true } Cell { isInvalid: true }  
                Cell { } Cell { }                                  
                Cell { } Cell { content: consonantsRoot.getC("n") } 
                Cell { } Cell { }                                  
                Cell { } Cell { }                                  
                Cell { } Cell { content: consonantsRoot.getC("ng") }
                Cell { isInvalid: true } Cell { isInvalid: true }  

                // --- ROW 5: Plosive ---
                Cell { content: "<b>Plosive</b>"; isHeader: true; isRowHeader: true }
                Cell { content: consonantsRoot.getC("p") } Cell { content: consonantsRoot.getC("b") } 
                Cell { } Cell { }                                                                    
                Cell { } Cell { }                                                                    
                Cell { content: consonantsRoot.getC("t") } Cell { content: consonantsRoot.getC("d") } 
                Cell { } Cell { }                                                                    
                Cell { } Cell { }                                                                    
                Cell { content: consonantsRoot.getC("k") } Cell { content: consonantsRoot.getC("g") } 
                Cell { } Cell { }                                                                    

                // --- ROW 6: Affricate ---
                Cell { content: "<b>Affricate</b>"; isHeader: true; isRowHeader: true }
                Repeater { model: 8; Cell { } } 
                Cell { content: consonantsRoot.getC("ch") } Cell { content: consonantsRoot.getC("jh") } 
                Repeater { model: 6; Cell { } } 

                // --- ROW 7: Fricative ---
                Cell { content: "<b>Fricative</b>"; isHeader: true; isRowHeader: true }
                Cell { } Cell { }                                                                      
                Cell { content: consonantsRoot.getC("f") } Cell { content: consonantsRoot.getC("v") }   
                Cell { content: consonantsRoot.getC("th") } Cell { content: consonantsRoot.getC("dh") } 
                Cell { content: consonantsRoot.getC("s") } Cell { content: consonantsRoot.getC("z") }   
                Cell { content: consonantsRoot.getC("sh") } Cell { content: consonantsRoot.getC("zh") } 
                Cell { } Cell { }                                                                      
                Cell { } Cell { }                                                                      
                Cell { content: consonantsRoot.getC("h") } Cell { }                                     

                // --- ROW 8: Approximant ---
                Cell { content: "<b>Approximant</b>"; isHeader: true; isRowHeader: true }
                Repeater { model: 6; Cell { } } 
                Cell { } Cell { content: consonantsRoot.getC("r") } 
                Cell { } Cell { }                                  
                Cell { } Cell { content: consonantsRoot.getC("j") } 
                Cell { } Cell { content: consonantsRoot.getC("w") } 
                Cell { } Cell { }                                  

                // --- ROW 9: Tap or Flap ---
                Cell { content: "<b>Tap or Flap</b>"; isHeader: true; isRowHeader: true }
                Repeater { model: 6; Cell { } } 
                Cell { } Cell { content: consonantsRoot.getC("tt") } 
                Repeater { model: 8; Cell { } } 

                // --- ROW 10: Lateral Approximant ---
                Cell { content: "<b>Lateral Approximant</b>"; isHeader: true; isRowHeader: true }
                Cell { isInvalid: true } Cell { isInvalid: true }  
                Cell { isInvalid: true } Cell { isInvalid: true }  
                Cell { } Cell { }                                  
                Cell { } Cell { content: consonantsRoot.getC("l") } 
                Cell { } Cell { }                                  
                Cell { } Cell { }                                  
                Cell { } Cell { }                                  
                Cell { isInvalid: true } Cell { isInvalid: true }  
            }
        }

        Text {
            text: "<i>* <b>VL</b> = Voiceless &nbsp;&nbsp;|&nbsp;&nbsp; <b>VD</b> = Voiced<br>* Note: <code>w</code> is a labio-velar approximant, meaning it is co-articulated at both the velum and the lips.</i>".replace(/<code>/g, "<font face='monospace'>").replace(/<\/code>/g, "</font>")
            textFormat: Text.RichText
            font.pixelSize: 12
            color: "#555555"
            Layout.topMargin: 5
        }
    }
}
