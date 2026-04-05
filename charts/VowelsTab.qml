import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ScrollView {
    id: vowelsRoot
    anchors.fill: parent
    anchors.margins: 20
    contentWidth: availableWidth
    clip: true

    // --- INJECTED DATA ---
    property var phonemeData: null

    // Arrays to hold our processed diphthong groupings
    property var diphthongGroup1: []
    property var diphthongGroup2: []
    property var diphthongGroup3: []

    // Re-process the groups whenever the main app passes us the JSON
    onPhonemeDataChanged: processDiphthongs()

    // --- INTERACTIVE STATE ---
    property string activeStartCode: ""
    property string activeEndCode: ""
    property color activeColor: "transparent"

    onActiveStartCodeChanged: arrowCanvas.requestPaint()
    onActiveEndCodeChanged: arrowCanvas.requestPaint()

    // --- HELPER LOGIC ---
    readonly property var vowelMap: {
        "i": {x: 0.02, y: 0.02}, "I": {x: 0.14, y: 0.16}, "e": {x: 0.18, y: 0.30}, "ae": {x: 0.35, y: 0.73},
        "uh": {x: 0.46, y: 0.44}, "er": {x: 0.44, y: 0.58}, "^": {x: 0.58, y: 0.68},
        "u": {x: 0.78, y: 0.02}, "oo": {x: 0.72, y: 0.16}, "ou": {x: 0.76, y: 0.58},
        "aa": {x: 0.58, y: 0.86}, "ah": {x: 0.58, y: 0.86}
    }

    function getV(code) {
        if (!phonemeData) return "";
        var arr = phonemeData.monophthongs.short_vowels.concat(phonemeData.monophthongs.long_vowels);
        for (var i = 0; i < arr.length; i++) {
            if (arr[i].code.trim() === code.trim()) {
                return "/" + arr[i].ipa + "/";
            }
        }
        return "";
    }

    function processDiphthongs() {
        if (!phonemeData) return;
        var g1 = [], g2 = [], g3 = [];
        
        for (var i = 0; i < phonemeData.diphthongs.length; i++) {
            var d = phonemeData.diphthongs[i];
            var ipa = "/" + d.ipa + "/";
            var start = "", end = "";
            
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

        property bool isActive: vowelsRoot.activeStartCode === codeText || vowelsRoot.activeEndCode === codeText || 
                                (vowelsRoot.activeStartCode === "a" && (codeText === "ae" || codeText === "aa" || codeText === "ah")) ||
                                (vowelsRoot.activeStartCode === "o" && (codeText === "ou" || codeText === "ah"))
        
        z: isActive ? 20 : 10 
        opacity: (vowelsRoot.activeStartCode !== "" && !isActive) ? 0.3 : 1.0
        
        Behavior on opacity { NumberAnimation { duration: 200 } }
        
        color: isActive ? vowelsRoot.activeColor : "white"
        border.color: isActive ? Qt.darker(vowelsRoot.activeColor, 1.2) : "#dddddd"
        border.width: isActive ? 2 : 1

        Row {
            id: contentRow
            anchors.centerIn: parent
            spacing: 4
            
            Text { text: "<font face='monospace'>" + labelRoot.codeText + "</font>"; textFormat: Text.RichText; font.pixelSize: 15; color: labelRoot.isActive ? "white" : "black" }
            Text { text: labelRoot.ipaText; font.pixelSize: 15; color: labelRoot.isActive ? "white" : "black"; font.bold: labelRoot.isActive }
            Text { visible: labelRoot.extraText !== ""; text: labelRoot.extraText; textFormat: Text.RichText; font.pixelSize: 15; color: labelRoot.isActive ? "white" : "black" }
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
                                    
                                    vowelsRoot.activeStartCode = startAnchor;
                                    vowelsRoot.activeEndCode = modelData.end;
                                    vowelsRoot.activeColor = cardRoot.themeColor;
                                }
                                onExited: {
                                    vowelsRoot.activeStartCode = "";
                                    vowelsRoot.activeEndCode = "";
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // --- TAB LAYOUT ---
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

                                if (vowelsRoot.activeStartCode !== "" && vowelsRoot.activeEndCode !== "") {
                                    var startNode = vowelsRoot.vowelMap[vowelsRoot.activeStartCode];
                                    var endNode = vowelsRoot.vowelMap[vowelsRoot.activeEndCode];

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
                                        ctx.strokeStyle = vowelsRoot.activeColor;
                                        ctx.stroke();

                                        var headLen = 18;
                                        var headAngle = Math.PI / 8;
                                        
                                        ctx.beginPath();
                                        ctx.moveTo(tipX, tipY);
                                        ctx.lineTo(tipX - headLen * Math.cos(angle - headAngle), tipY - headLen * Math.sin(angle - headAngle));
                                        ctx.lineTo(tipX - headLen * Math.cos(angle + headAngle), tipY - headLen * Math.sin(angle + headAngle));
                                        ctx.lineTo(tipX, tipY);
                                        ctx.fillStyle = vowelsRoot.activeColor;
                                        ctx.fill();
                                    }
                                }
                            }
                        }

                        VowelLabel { codeText: "i";  ipaText: vowelsRoot.getV("i"); relX: vowelsRoot.vowelMap["i"].x; relY: vowelsRoot.vowelMap["i"].y }
                        VowelLabel { codeText: "I";  ipaText: vowelsRoot.getV("I"); relX: vowelsRoot.vowelMap["I"].x; relY: vowelsRoot.vowelMap["I"].y }
                        VowelLabel { codeText: "e";  ipaText: vowelsRoot.getV("e"); relX: vowelsRoot.vowelMap["e"].x; relY: vowelsRoot.vowelMap["e"].y }
                        VowelLabel { codeText: "ae"; ipaText: vowelsRoot.getV("ae"); relX: vowelsRoot.vowelMap["ae"].x; relY: vowelsRoot.vowelMap["ae"].y }

                        VowelLabel { codeText: "uh"; ipaText: vowelsRoot.getV("uh"); relX: vowelsRoot.vowelMap["uh"].x; relY: vowelsRoot.vowelMap["uh"].y }
                        VowelLabel { codeText: "er"; ipaText: vowelsRoot.getV("er"); relX: vowelsRoot.vowelMap["er"].x; relY: vowelsRoot.vowelMap["er"].y }
                        VowelLabel { codeText: "^";  ipaText: vowelsRoot.getV("^"); relX: vowelsRoot.vowelMap["^"].x; relY: vowelsRoot.vowelMap["^"].y }

                        VowelLabel { codeText: "u";  ipaText: vowelsRoot.getV("u"); relX: vowelsRoot.vowelMap["u"].x; relY: vowelsRoot.vowelMap["u"].y }
                        VowelLabel { codeText: "oo"; ipaText: vowelsRoot.getV("oo"); relX: vowelsRoot.vowelMap["oo"].x; relY: vowelsRoot.vowelMap["oo"].y }
                        VowelLabel { codeText: "ou"; ipaText: vowelsRoot.getV("ou"); relX: vowelsRoot.vowelMap["ou"].x; relY: vowelsRoot.vowelMap["ou"].y }
                        VowelLabel { codeText: "aa"; ipaText: vowelsRoot.getV("aa"); extraText: " &bull; <font face='monospace'>ah</font> " + vowelsRoot.getV("ah"); relX: vowelsRoot.vowelMap["aa"].x; relY: vowelsRoot.vowelMap["aa"].y }
                    }
                }
            }
        }

        Flow {
            Layout.fillWidth: true
            spacing: 20
            
            DiphthongCard {
                titleText: "Closing to Front"
                targetText: "/ɪ/"
                themeColor: "#007bff"
                bgColor: "#f8fbff"
                rowData: vowelsRoot.diphthongGroup1
            }
            DiphthongCard {
                titleText: "Closing to Back"
                targetText: "/ʊ/"
                themeColor: "#f44336"
                bgColor: "#fff8f8"
                rowData: vowelsRoot.diphthongGroup2
            }
            DiphthongCard {
                titleText: "Centering"
                targetText: "/ə/"
                themeColor: "#4caf50"
                bgColor: "#f6fdf6"
                rowData: vowelsRoot.diphthongGroup3
            }
        }
    }
}
