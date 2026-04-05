import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ApplicationWindow {
    id: root
    visible: true
    width: 1080
    height: 750
    title: "Interactive English Phonemes (Data-Driven)"
    color: "#ffffff"

    // --- DATA LOADING & PARSING ---
    property var phonemeData: null
    
    // Arrays to hold our processed diphthong groupings
    property var diphthongGroup1: []
    property var diphthongGroup2: []
    property var diphthongGroup3: []

    // Arrays for Symbols
    property var modifiersList: []
    property var delimitersList: []

    Component.onCompleted: {
        var xhr = new XMLHttpRequest();
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200 || xhr.status === 0) {
                    try {
                        phonemeData = JSON.parse(xhr.responseText);
                        processDiphthongs();
                        processSymbols();
                    } catch (e) {
                        console.error("Error parsing JSON: " + e);
                    }
                } else {
                    console.error("Failed to load JSON: " + xhr.status);
                }
            }
        };
        xhr.open("GET", "en_phonemes.json", true);
        xhr.send();
    }

    // --- HELPER FUNCTIONS ---
    
    // Searches JSON for monophthongs to populate VowelLabels
    function getV(code) {
        if (!phonemeData) return "";
        var arr = phonemeData.monophthongs.short_vowels.concat(phonemeData.monophthongs.long_vowels);
        for (var i = 0; i < arr.length; i++) {
            // .trim() is used because "^" had a trailing space in the JSON file
            if (arr[i].code.trim() === code.trim()) {
                return "/" + arr[i].ipa + "/";
            }
        }
        return "";
    }

    // Searches JSON for consonants to populate the Grid Cells
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

    // Prepares the Diphthong arrays for the 3 target cards based on the loaded JSON
    function processDiphthongs() {
        if (!phonemeData) return;
        var g1 = [], g2 = [], g3 = [];
        
        for (var i = 0; i < phonemeData.diphthongs.length; i++) {
            var d = phonemeData.diphthongs[i];
            var ipa = "/" + d.ipa + "/";
            var start = "", end = "";
            
            // Map the visual "anchor" logic based on the actual IPA glides from the JSON
            if (d.code === "eI") { start = "e"; end = "I"; g1.push({start:start, end:end, code:d.code, ipa:ipa, example:d.ex}); }
            else if (d.code === "aI") { start = "a"; end = "I"; g1.push({start:start, end:end, code:d.code, ipa:ipa, example:d.ex}); }
            else if (d.code === "oy") { start = "o"; end = "I"; g1.push({start:start, end:end, code:d.code, ipa:ipa, example:d.ex}); }
            
            else if (d.code === "oa") { start = "uh"; end = "u"; g2.push({start:start, end:end, code:d.code, ipa:ipa, example:d.ex}); }
            else if (d.code === "ow") { start = "a"; end = "u"; g2.push({start:start, end:end, code:d.code, ipa:ipa, example:d.ex}); }
            
            else if (d.code === "ia") { start = "I"; end = "uh"; g3.push({start:start, end:end, code:d.code, ipa:ipa, example:d.ex}); } 
            else if (d.code === "ea") { start = "e"; end = "uh"; g3.push({start:start, end:end, code:d.code, ipa:ipa, example:d.ex}); }
            else if (d.code === "ua") { start = "oo"; end = "uh"; g3.push({start:start, end:end, code:d.code, ipa:ipa, example:d.ex}); } 
        }
        
        diphthongGroup1 = g1;
        diphthongGroup2 = g2;
        diphthongGroup3 = g3;
    }

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

    // --- GLOBAL INTERACTIVE STATE (For Vowels) ---
    property string activeStartCode: ""
    property string activeEndCode: ""
    property color activeColor: "transparent"

    onActiveStartCodeChanged: arrowCanvas.requestPaint()
    onActiveEndCodeChanged: arrowCanvas.requestPaint()

    readonly property var vowelMap: {
        "i": {x: 0.02, y: 0.02}, "I": {x: 0.14, y: 0.16}, "e": {x: 0.18, y: 0.30}, "ae": {x: 0.35, y: 0.73},
        "uh": {x: 0.46, y: 0.44}, "er": {x: 0.44, y: 0.58}, "^": {x: 0.58, y: 0.68},
        "u": {x: 0.78, y: 0.02}, "oo": {x: 0.72, y: 0.16}, "ou": {x: 0.76, y: 0.58},
        "aa": {x: 0.58, y: 0.86}, "ah": {x: 0.58, y: 0.86}
    }

    // --- REUSABLE COMPONENTS ---

    component VowelLabel : Rectangle {
        id: labelRoot
        property string codeText: ""
        property string ipaText: ""
        property string extraText: "" 
        property real relX: 0.0
        property real relY: 0.0

        x: parent.width * relX
        y: parent.height * relY
        width: contentRow.implicitWidth + 8
        height: contentRow.implicitHeight + 6
        radius: 4

        property bool isActive: root.activeStartCode === codeText || root.activeEndCode === codeText || 
                                (root.activeStartCode === "a" && (codeText === "ae" || codeText === "aa" || codeText === "ah")) ||
                                (root.activeStartCode === "o" && (codeText === "ou" || codeText === "ah"))
        
        z: isActive ? 20 : 10 
        opacity: (root.activeStartCode !== "" && !isActive) ? 0.3 : 1.0
        
        Behavior on opacity { NumberAnimation { duration: 200 } }
        
        color: isActive ? root.activeColor : "white"
        border.color: isActive ? Qt.darker(root.activeColor, 1.2) : "#dddddd"
        border.width: isActive ? 2 : 1

        Row {
            id: contentRow
            anchors.centerIn: parent
            spacing: 4
            
            Text {
                text: "<font face='monospace'>" + labelRoot.codeText + "</font>"
                textFormat: Text.RichText
                font.pixelSize: 15
                color: labelRoot.isActive ? "white" : "black"
            }
            Text {
                text: labelRoot.ipaText
                font.pixelSize: 15
                color: labelRoot.isActive ? "white" : "black"
                font.bold: labelRoot.isActive
            }
            Text {
                visible: labelRoot.extraText !== ""
                text: labelRoot.extraText
                textFormat: Text.RichText
                font.pixelSize: 15
                color: labelRoot.isActive ? "white" : "black"
            }
        }
    }

    component DiphthongCard : Rectangle {
        id: cardRoot
        width: 270
        height: cardLayout.implicitHeight
        radius: 8
        border.width: 1
        clip: true

        property string titleText
        property string targetText
        property color themeColor
        property color bgColor
        property var rowData: []

        border.color: themeColor

        ColumnLayout {
            id: cardLayout
            anchors.fill: parent
            spacing: 0

            Rectangle {
                Layout.fillWidth: true
                height: 65
                color: cardRoot.themeColor

                Column {
                    anchors.centerIn: parent
                    spacing: 4
                    Text { text: cardRoot.titleText; color: "white"; font.bold: true; font.pixelSize: 16; anchors.horizontalCenter: parent.horizontalCenter }
                    Text { text: "Target: <b>" + cardRoot.targetText + "</b>"; color: "white"; opacity: 0.9; font.pixelSize: 13; textFormat: Text.RichText; anchors.horizontalCenter: parent.horizontalCenter }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: rowsLayout.implicitHeight + 30
                color: cardRoot.bgColor

                ColumnLayout {
                    id: rowsLayout
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 12

                    Repeater {
                        model: cardRoot.rowData
                        delegate: Rectangle {
                            Layout.fillWidth: true
                            height: rowContent.implicitHeight + 10
                            color: hoverArea.containsMouse ? Qt.lighter(cardRoot.themeColor, 1.8) : "transparent"
                            radius: 4

                            RowLayout {
                                id: rowContent
                                anchors.verticalCenter: parent.verticalCenter
                                width: parent.width
                                spacing: 10

                                Text { text: "<font face='monospace'>" + modelData.start + "</font> &rarr; <font face='monospace'>" + modelData.end + "</font>"; textFormat: Text.RichText; font.pixelSize: 14; Layout.preferredWidth: 70 }
                                Text { text: "<b>=</b>"; textFormat: Text.RichText; font.pixelSize: 14 }
                                Text { text: "<font face='monospace'>" + modelData.code + "</font> " + modelData.ipa; textFormat: Text.RichText; font.pixelSize: 14; Layout.fillWidth: true }
                                Text { text: modelData.example; color: "#666666"; font.pixelSize: 14; Layout.alignment: Qt.AlignRight }
                            }

                            MouseArea {
                                id: hoverArea
                                anchors.fill: parent
                                hoverEnabled: true
                                onEntered: {
                                    var startAnchor = modelData.start;
                                    if (startAnchor === "a") startAnchor = "ae"; 
                                    if (startAnchor === "o") startAnchor = "ou";
                                    
                                    root.activeStartCode = startAnchor;
                                    root.activeEndCode = modelData.end;
                                    root.activeColor = cardRoot.themeColor;
                                }
                                onExited: {
                                    root.activeStartCode = "";
                                    root.activeEndCode = "";
                                }
                            }
                        }
                    }
                }
            }
        }
    }

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


    // --- NAVIGATION HEADER ---
    header: TabBar {
        id: tabBar
        width: parent.width
        
        TabButton { text: "Vowels & Diphthongs"; font.pixelSize: 15 }
        TabButton { text: "Consonants"; font.pixelSize: 15 }
        TabButton { text: "Symbols"; font.pixelSize: 15 }
    }

    // --- MAIN CONTENT AREA ---
    StackLayout {
        anchors.fill: parent
        currentIndex: tabBar.currentIndex

        // TAB 1: Vowels Space View
        ScrollView {
            anchors.fill: parent
            anchors.margins: 20
            contentWidth: availableWidth
            clip: true

            ColumnLayout {
                width: parent.width
                spacing: 40

                ColumnLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 15

                    Text { text: "English Vowel Space"; font.pixelSize: 22; font.bold: true; Layout.alignment: Qt.AlignHCenter }

                    RowLayout {
                        spacing: 10

                        Column {
                            Layout.alignment: Qt.AlignTop
                            spacing: 0
                            Repeater {
                                model: ["Close", "Near-close", "Close-mid", "Mid", "Open-mid", "Near-open", "Open"]
                                Text { text: "<b>" + modelData + "</b>"; textFormat: Text.RichText; font.pixelSize: 11; horizontalAlignment: Text.AlignRight; verticalAlignment: Text.AlignVCenter; width: 80; height: 30 }
                            }
                        }

                        Column {
                            spacing: 0
                            Row {
                                width: 300
                                height: 25
                                Text { text: "<b>Front</b>"; textFormat: Text.RichText; font.pixelSize: 11; width: 60; horizontalAlignment: Text.AlignHCenter }
                                Text { text: "<b>Central</b>"; textFormat: Text.RichText; font.pixelSize: 11; width: 180; horizontalAlignment: Text.AlignHCenter }
                                Text { text: "<b>Back</b>"; textFormat: Text.RichText; font.pixelSize: 11; width: 60; horizontalAlignment: Text.AlignHCenter }
                            }

                            Rectangle {
                                width: 300
                                height: 210
                                color: "transparent"

                                Image {
                                    anchors.fill: parent
                                    source: "https://upload.wikimedia.org/wikipedia/commons/thumb/4/4f/Blank_vowel_trapezoid.svg/330px-Blank_vowel_trapezoid.svg.png"
                                    fillMode: Image.PreserveAspectFit
                                }

                                Canvas {
                                    id: arrowCanvas
                                    anchors.fill: parent
                                    z: 15

                                    onPaint: {
                                        var ctx = getContext("2d");
                                        ctx.clearRect(0, 0, width, height);

                                        if (root.activeStartCode !== "" && root.activeEndCode !== "") {
                                            var startNode = root.vowelMap[root.activeStartCode];
                                            var endNode = root.vowelMap[root.activeEndCode];

                                            if (startNode && endNode) {
                                                var startX = (startNode.x * 300) + 20; 
                                                var startY = (startNode.y * 210) + 12;
                                                var targetX = (endNode.x * 300) + 20;
                                                var targetY = (endNode.y * 210) + 12;

                                                var angle = Math.atan2(targetY - startY, targetX - startX);

                                                var pullBack = 28;
                                                var tipX = targetX - pullBack * Math.cos(angle);
                                                var tipY = targetY - pullBack * Math.sin(angle);

                                                var lineStopX = tipX - 6 * Math.cos(angle);
                                                var lineStopY = tipY - 6 * Math.sin(angle);

                                                ctx.beginPath();
                                                ctx.moveTo(startX, startY);
                                                ctx.lineTo(lineStopX, lineStopY);
                                                ctx.lineWidth = 3;
                                                ctx.strokeStyle = root.activeColor;
                                                ctx.stroke();

                                                var headLen = 18;
                                                var headAngle = Math.PI / 8;
                                                
                                                ctx.beginPath();
                                                ctx.moveTo(tipX, tipY);
                                                ctx.lineTo(tipX - headLen * Math.cos(angle - headAngle), tipY - headLen * Math.sin(angle - headAngle));
                                                ctx.lineTo(tipX - headLen * Math.cos(angle + headAngle), tipY - headLen * Math.sin(angle + headAngle));
                                                ctx.lineTo(tipX, tipY);
                                                ctx.fillStyle = root.activeColor;
                                                ctx.fill();
                                            }
                                        }
                                    }
                                }

                                // DATA-DRIVEN: Vowels now grab their IPA dynamically from the JSON!
                                VowelLabel { codeText: "i";  ipaText: root.getV("i"); relX: root.vowelMap["i"].x; relY: root.vowelMap["i"].y }
                                VowelLabel { codeText: "I";  ipaText: root.getV("I"); relX: root.vowelMap["I"].x; relY: root.vowelMap["I"].y }
                                VowelLabel { codeText: "e";  ipaText: root.getV("e"); relX: root.vowelMap["e"].x; relY: root.vowelMap["e"].y }
                                VowelLabel { codeText: "ae"; ipaText: root.getV("ae"); relX: root.vowelMap["ae"].x; relY: root.vowelMap["ae"].y }

                                VowelLabel { codeText: "uh"; ipaText: root.getV("uh"); relX: root.vowelMap["uh"].x; relY: root.vowelMap["uh"].y }
                                VowelLabel { codeText: "er"; ipaText: root.getV("er"); relX: root.vowelMap["er"].x; relY: root.vowelMap["er"].y }
                                VowelLabel { codeText: "^";  ipaText: root.getV("^"); relX: root.vowelMap["^"].x; relY: root.vowelMap["^"].y }

                                VowelLabel { codeText: "u";  ipaText: root.getV("u"); relX: root.vowelMap["u"].x; relY: root.vowelMap["u"].y }
                                VowelLabel { codeText: "oo"; ipaText: root.getV("oo"); relX: root.vowelMap["oo"].x; relY: root.vowelMap["oo"].y }
                                VowelLabel { codeText: "ou"; ipaText: root.getV("ou"); relX: root.vowelMap["ou"].x; relY: root.vowelMap["ou"].y }
                                VowelLabel { codeText: "aa"; ipaText: root.getV("aa"); extraText: " &bull; <font face='monospace'>ah</font> " + root.getV("ah"); relX: root.vowelMap["aa"].x; relY: root.vowelMap["aa"].y }
                            }
                        }
                    }
                }

                // DATA-DRIVEN: Cards are bound to the properties processed from JSON!
                Flow {
                    Layout.fillWidth: true
                    spacing: 20
                    
                    DiphthongCard {
                        titleText: "Closing to Front"
                        targetText: "/ɪ/"
                        themeColor: "#007bff"
                        bgColor: "#f8fbff"
                        rowData: root.diphthongGroup1
                    }
                    DiphthongCard {
                        titleText: "Closing to Back"
                        targetText: "/ʊ/"
                        themeColor: "#f44336"
                        bgColor: "#fff8f8"
                        rowData: root.diphthongGroup2
                    }
                    DiphthongCard {
                        titleText: "Centering"
                        targetText: "/ə/"
                        themeColor: "#4caf50"
                        bgColor: "#f6fdf6"
                        rowData: root.diphthongGroup3
                    }
                }
            }
        }

        // TAB 2: Consonants View
        ScrollView {
            anchors.fill: parent
            anchors.margins: 20
            contentWidth: availableWidth
            contentHeight: mainConsonantColumn.implicitHeight
            clip: true

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

                        // DATA-DRIVEN: Consonants grab their IPAs from the JSON!
                        
                        // --- ROW 4: Nasal ---
                        Cell { content: "<b>Nasal</b>"; isHeader: true; isRowHeader: true }
                        Cell { } Cell { content: root.getC("m") } 
                        Cell { isInvalid: true } Cell { isInvalid: true }  
                        Cell { } Cell { }                                  
                        Cell { } Cell { content: root.getC("n") } 
                        Cell { } Cell { }                                  
                        Cell { } Cell { }                                  
                        Cell { } Cell { content: root.getC("ng") }
                        Cell { isInvalid: true } Cell { isInvalid: true }  

                        // --- ROW 5: Plosive ---
                        Cell { content: "<b>Plosive</b>"; isHeader: true; isRowHeader: true }
                        Cell { content: root.getC("p") } Cell { content: root.getC("b") } 
                        Cell { } Cell { }                                                                    
                        Cell { } Cell { }                                                                    
                        Cell { content: root.getC("t") } Cell { content: root.getC("d") } 
                        Cell { } Cell { }                                                                    
                        Cell { } Cell { }                                                                    
                        Cell { content: root.getC("k") } Cell { content: root.getC("g") } 
                        Cell { } Cell { }                                                                    

                        // --- ROW 6: Affricate ---
                        Cell { content: "<b>Affricate</b>"; isHeader: true; isRowHeader: true }
                        Repeater { model: 8; Cell { } } 
                        Cell { content: root.getC("ch") } Cell { content: root.getC("jh") } 
                        Repeater { model: 6; Cell { } } 

                        // --- ROW 7: Fricative ---
                        Cell { content: "<b>Fricative</b>"; isHeader: true; isRowHeader: true }
                        Cell { } Cell { }                                                                      
                        Cell { content: root.getC("f") } Cell { content: root.getC("v") }   
                        Cell { content: root.getC("th") } Cell { content: root.getC("dh") } 
                        Cell { content: root.getC("s") } Cell { content: root.getC("z") }   
                        Cell { content: root.getC("sh") } Cell { content: root.getC("zh") } 
                        Cell { } Cell { }                                                                      
                        Cell { } Cell { }                                                                      
                        Cell { content: root.getC("h") } Cell { }                                     

                        // --- ROW 8: Approximant ---
                        Cell { content: "<b>Approximant</b>"; isHeader: true; isRowHeader: true }
                        Repeater { model: 6; Cell { } } 
                        Cell { } Cell { content: root.getC("r") } 
                        Cell { } Cell { }                                  
                        Cell { } Cell { content: root.getC("j") } 
                        Cell { } Cell { content: root.getC("w") } 
                        Cell { } Cell { }                                  

                        // --- ROW 9: Tap or Flap ---
                        Cell { content: "<b>Tap or Flap</b>"; isHeader: true; isRowHeader: true }
                        Repeater { model: 6; Cell { } } 
                        Cell { } Cell { content: root.getC("tt") } 
                        Repeater { model: 8; Cell { } } 

                        // --- ROW 10: Lateral Approximant ---
                        Cell { content: "<b>Lateral Approximant</b>"; isHeader: true; isRowHeader: true }
                        Cell { isInvalid: true } Cell { isInvalid: true }  
                        Cell { isInvalid: true } Cell { isInvalid: true }  
                        Cell { } Cell { }                                  
                        Cell { } Cell { content: root.getC("l") } 
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

        // TAB 3: Symbols View
        ScrollView {
            anchors.fill: parent
            anchors.margins: 20
            contentWidth: availableWidth
            clip: true

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
                    modelDataList: root.modifiersList
                }

                Text {
                    text: "Delimiters"
                    font.pixelSize: 18
                    font.bold: true
                    color: "#007bff"
                    Layout.topMargin: 20
                }
                
                SymbolTable {
                    modelDataList: root.delimitersList
                }
            }
        }
    }
}
