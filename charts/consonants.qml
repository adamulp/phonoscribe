import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ApplicationWindow {
    visible: true
    width: 1050
    height: 620
    title: "English Consonants (Voiced / Unvoiced)"
    color: "#ffffff"

    // Reusable Cell Component
    component Cell : Rectangle {
        id: cellRoot
        property string content: ""
        property bool isHeader: false
        property bool isRowHeader: false
        property bool isInvalid: false
        
        // Match HTML table styling colors
        color: isHeader ? "#eaecf0" : (isInvalid ? "#cccccc" : "#ffffff")
        
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.minimumHeight: isHeader ? 30 : 55
        Layout.minimumWidth: isRowHeader ? 140 : 45

        Text {
            anchors.fill: parent
            anchors.margins: 4
            leftPadding: cellRoot.isRowHeader ? 5 : 0
            
            // Auto-replace HTML <code> tags with QML compatible monospace font tags
            text: cellRoot.content.replace(/<code>/g, "<font face='monospace'>").replace(/<\/code>/g, "</font>")
            textFormat: Text.RichText
            font.pixelSize: 14
            horizontalAlignment: cellRoot.isRowHeader ? Text.AlignLeft : Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            wrapMode: Text.WordWrap
        }
    }

    ScrollView {
        anchors.fill: parent
        anchors.margins: 20
        contentWidth: availableWidth
        contentHeight: mainColumn.implicitHeight

        ColumnLayout {
            id: mainColumn
            width: parent.width
            spacing: 15

            Text {
                text: "English Consonants"
                font.pixelSize: 18
                font.bold: true
                Layout.alignment: Qt.AlignLeft
            }

            // Table Wrapper (Acts as the collapsed border)
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: grid.implicitHeight
                color: "#a2a9b1" // Border color

                GridLayout {
                    id: grid
                    anchors.fill: parent
                    anchors.margins: 1 // Outer border
                    rowSpacing: 1      // Inner horizontal borders
                    columnSpacing: 1   // Inner vertical borders
                    columns: 17        // Expanded for U/V split

                    // --- ROW 1: Super Headers (Places of Articulation) ---
                    Cell { content: "<span style='font-size:12px'>Place of articulation &rarr;</span>"; isHeader: true; isRowHeader: true }
                    Cell { content: "<b>Labial</b>"; isHeader: true; Layout.columnSpan: 4 }
                    Cell { content: "<b>Coronal</b>"; isHeader: true; Layout.columnSpan: 6 }
                    Cell { content: "<b>Dorsal</b>"; isHeader: true; Layout.columnSpan: 4 }
                    Cell { content: "<b>Laryngeal</b>"; isHeader: true; Layout.columnSpan: 2 }

                    // --- ROW 2: Sub Headers (Specific Places) ---
                    Cell { content: "<span style='font-size:12px'>Manner of articulation &darr;</span>"; isHeader: true; isRowHeader: true }
                    Cell { content: "Bilabial"; isHeader: true; Layout.columnSpan: 2 }
                    Cell { content: "Labio-dental"; isHeader: true; Layout.columnSpan: 2 }
                    Cell { content: "Dental"; isHeader: true; Layout.columnSpan: 2 }
                    Cell { content: "Alveolar"; isHeader: true; Layout.columnSpan: 2 }
                    Cell { content: "Post-alveolar"; isHeader: true; Layout.columnSpan: 2 }
                    Cell { content: "Palatal"; isHeader: true; Layout.columnSpan: 2 }
                    Cell { content: "Velar"; isHeader: true; Layout.columnSpan: 2 }
                    Cell { content: "Glottal"; isHeader: true; Layout.columnSpan: 2 }

                    // --- ROW 3: Voicing Headers (VL / VD) ---
                    Cell { isHeader: true; isRowHeader: true }
                    Repeater {
                        // Dynamically stamp out the VL/VD sub-columns
                        model: ["VL", "VD", "VL", "VD", "VL", "VD", "VL", "VD", "VL", "VD", "VL", "VD", "VL", "VD", "VL", "VD"]
                        Cell { 
                            content: "<span style='font-size:11px; color:#666666'>" + modelData + "</span>"
                            isHeader: true 
                        }
                    }

                    // --- ROW 4: Nasal ---
                    Cell { content: "<b>Nasal</b>"; isHeader: true; isRowHeader: true }
                    Cell { } Cell { content: "<code>m</code><br>/m/" } // Bilabial
                    Cell { isInvalid: true } Cell { isInvalid: true }  // Labio-dental
                    Cell { } Cell { }                                  // Dental
                    Cell { } Cell { content: "<code>n</code><br>/n/" } // Alveolar
                    Cell { } Cell { }                                  // Post-alveolar
                    Cell { } Cell { }                                  // Palatal
                    Cell { } Cell { content: "<code>ng</code><br>/ŋ/" }// Velar
                    Cell { isInvalid: true } Cell { isInvalid: true }  // Glottal

                    // --- ROW 5: Plosive ---
                    Cell { content: "<b>Plosive</b>"; isHeader: true; isRowHeader: true }
                    Cell { content: "<code>p</code><br>/p/" } Cell { content: "<code>b</code><br>/b/" } // Bilabial
                    Cell { } Cell { }                                                                    // Labio-dental
                    Cell { } Cell { }                                                                    // Dental
                    Cell { content: "<code>t</code><br>/t/" } Cell { content: "<code>d</code><br>/d/" } // Alveolar
                    Cell { } Cell { }                                                                    // Post-alveolar
                    Cell { } Cell { }                                                                    // Palatal
                    Cell { content: "<code>k</code><br>/k/" } Cell { content: "<code>g</code><br>/g/" } // Velar
                    Cell { } Cell { }                                                                    // Glottal

                    // --- ROW 6: Affricate ---
                    Cell { content: "<b>Affricate</b>"; isHeader: true; isRowHeader: true }
                    Repeater { model: 8; Cell { } } // Skip to Post-alveolar
                    Cell { content: "<code>ch</code><br>/tʃ/" } Cell { content: "<code>jh</code><br>/dʒ/" } // Post-alveolar
                    Repeater { model: 6; Cell { } } // Skip the rest

                    // --- ROW 7: Fricative ---
                    Cell { content: "<b>Fricative</b>"; isHeader: true; isRowHeader: true }
                    Cell { } Cell { }                                                                      // Bilabial
                    Cell { content: "<code>f</code><br>/f/" } Cell { content: "<code>v</code><br>/v/" }   // Labio-dental
                    Cell { content: "<code>th</code><br>/θ/" } Cell { content: "<code>dh</code><br>/ð/" } // Dental
                    Cell { content: "<code>s</code><br>/s/" } Cell { content: "<code>z</code><br>/z/" }   // Alveolar
                    Cell { content: "<code>sh</code><br>/ʃ/" } Cell { content: "<code>zh</code><br>/ʒ/" } // Post-alveolar
                    Cell { } Cell { }                                                                      // Palatal
                    Cell { } Cell { }                                                                      // Velar
                    Cell { content: "<code>h</code><br>/h/" } Cell { }                                     // Glottal

                    // --- ROW 8: Approximant ---
                    Cell { content: "<b>Approximant</b>"; isHeader: true; isRowHeader: true }
                    Repeater { model: 6; Cell { } } // Skip to Alveolar
                    Cell { } Cell { content: "<code>r</code><br>/r/" } // Alveolar
                    Cell { } Cell { }                                  // Post-alveolar
                    Cell { } Cell { content: "<code>j</code><br>/j/" } // Palatal
                    Cell { } Cell { content: "<code>w</code><br>/w/ *" } // Velar
                    Cell { } Cell { }                                  // Glottal

                    // --- ROW 9: Tap or Flap ---
                    Cell { content: "<b>Tap or Flap</b>"; isHeader: true; isRowHeader: true }
                    Repeater { model: 6; Cell { } } // Skip to Alveolar
                    Cell { } Cell { content: "<code>tt</code><br>/ɾ/" } // Alveolar
                    Repeater { model: 8; Cell { } } // Skip the rest

                    // --- ROW 10: Lateral Approximant ---
                    Cell { content: "<b>Lateral Approximant</b>"; isHeader: true; isRowHeader: true }
                    Cell { isInvalid: true } Cell { isInvalid: true }  // Bilabial
                    Cell { isInvalid: true } Cell { isInvalid: true }  // Labio-dental
                    Cell { } Cell { }                                  // Dental
                    Cell { } Cell { content: "<code>l</code><br>/l/" } // Alveolar
                    Cell { } Cell { }                                  // Post-alveolar
                    Cell { } Cell { }                                  // Palatal
                    Cell { } Cell { }                                  // Velar
                    Cell { isInvalid: true } Cell { isInvalid: true }  // Glottal
                }
            }

            // Footnotes
            Text {
                text: "<i>* <b>VL</b> = Voiceless &nbsp;&nbsp;|&nbsp;&nbsp; <b>VD</b> = Voiced<br>* Note: <code>w</code> is a labio-velar approximant, meaning it is co-articulated at both the velum and the lips.</i>".replace(/<code>/g, "<font face='monospace'>").replace(/<\/code>/g, "</font>")
                textFormat: Text.RichText
                font.pixelSize: 12
                color: "#555555"
                Layout.topMargin: 5
            }
        }
    }
}
