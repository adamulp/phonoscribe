import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ApplicationWindow {
    id: root
    visible: true
    width: 960
    height: 700
    title: "Interactive English Phonetics"
    color: "#ffffff"

    // --- GLOBAL INTERACTIVE STATE ---
    property string activeStartCode: ""
    property string activeEndCode: ""
    property color activeColor: "transparent"

    onActiveStartCodeChanged: arrowCanvas.requestPaint()
    onActiveEndCodeChanged: arrowCanvas.requestPaint()

    // Centralized coordinate map for the canvas to draw lines
    readonly property var vowelMap: {
        "i": {x: 0.02, y: 0.02}, "I": {x: 0.14, y: 0.16}, "e": {x: 0.18, y: 0.30}, "ae": {x: 0.35, y: 0.73},
        "uh": {x: 0.46, y: 0.44}, "er": {x: 0.44, y: 0.58}, "^": {x: 0.58, y: 0.68},
        "u": {x: 0.78, y: 0.02}, "oo": {x: 0.72, y: 0.16}, "ou": {x: 0.76, y: 0.58},
        "aa": {x: 0.58, y: 0.86}, "ah": {x: 0.58, y: 0.86}
    }

    // --- REUSABLE COMPONENTS ---

    // 1. Interactive Vowel Label
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

        // Highlight logic
        property bool isActive: root.activeStartCode === codeText || root.activeEndCode === codeText || 
                                (root.activeStartCode === "a" && (codeText === "ae" || codeText === "aa" || codeText === "ah")) ||
                                (root.activeStartCode === "o" && (codeText === "ou" || codeText === "ah"))
        
        // NEW: Dynamic Z-indexing!
        z: isActive ? 20 : 10 
        
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

    // 2. Interactive Diphthong Card
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
                    Text {
                        text: cardRoot.titleText
                        color: "white"
                        font.bold: true
                        font.pixelSize: 16
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    Text {
                        text: "Target: <b>" + cardRoot.targetText + "</b>"
                        color: "white"
                        opacity: 0.9
                        font.pixelSize: 13
                        textFormat: Text.RichText
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
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

                                Text {
                                    text: "<font face='monospace'>" + modelData.start + "</font> &rarr; <font face='monospace'>" + modelData.end + "</font>"
                                    textFormat: Text.RichText
                                    font.pixelSize: 14
                                    Layout.preferredWidth: 70
                                }
                                Text { text: "<b>=</b>"; textFormat: Text.RichText; font.pixelSize: 14 }
                                Text {
                                    text: "<font face='monospace'>" + modelData.code + "</font> " + modelData.ipa
                                    textFormat: Text.RichText
                                    font.pixelSize: 14
                                    Layout.fillWidth: true
                                }
                                Text {
                                    text: modelData.example
                                    textFormat: Text.RichText
                                    color: "#666666"
                                    font.pixelSize: 14
                                    Layout.alignment: Qt.AlignRight
                                }
                            }

                            // Interaction triggers
                            MouseArea {
                                id: hoverArea
                                anchors.fill: parent
                                hoverEnabled: true
                                onEntered: {
                                    // Map the conceptual starting letters to their closest physical vowel anchors
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

    // --- MAIN LAYOUT ---
    ScrollView {
        anchors.fill: parent
        anchors.margins: 20
        contentWidth: availableWidth

        ColumnLayout {
            width: parent.width
            spacing: 40

            // UPPER SECTION: Vowel Chart
            ColumnLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 15

                Text {
                    text: "English Vowel Space"
                    font.pixelSize: 22
                    font.bold: true
                    Layout.alignment: Qt.AlignHCenter
                }

                RowLayout {
                    spacing: 10

                    Column {
                        Layout.alignment: Qt.AlignTop
                        spacing: 0
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

                            // Dynamic Arrow Overlay
                            Canvas {
                                id: arrowCanvas
                                anchors.fill: parent
                                z: 15 // INCREASED: Now draws on top of the VowelLabels

                                onPaint: {
                                    var ctx = getContext("2d");
                                    ctx.clearRect(0, 0, width, height);

                                    if (root.activeStartCode !== "" && root.activeEndCode !== "") {
                                        var startNode = root.vowelMap[root.activeStartCode];
                                        var endNode = root.vowelMap[root.activeEndCode];

                                        if (startNode && endNode) {
                                            // Offset slightly so lines draw from the center of the label bounds
                                            var startX = (startNode.x * 300) + 15;
                                            var startY = (startNode.y * 210) + 10;
                                            var endX = (endNode.x * 300) + 15;
                                            var endY = (endNode.y * 210) + 10;

                                            ctx.beginPath();
                                            ctx.moveTo(startX, startY);
                                            ctx.lineTo(endX, endY);
                                            ctx.lineWidth = 3;
                                            ctx.strokeStyle = root.activeColor;
                                            ctx.stroke();

                                            // Draw Arrowhead
                                            var angle = Math.atan2(endY - startY, endX - startX);
                                            var headLen = 12;
                                            // Pull arrowhead back slightly so it doesn't hide behind the end label
                                            endX = endX - 15 * Math.cos(angle);
                                            endY = endY - 15 * Math.sin(angle);
                                            
                                            ctx.beginPath();
                                            ctx.moveTo(endX, endY);
                                            ctx.lineTo(endX - headLen * Math.cos(angle - Math.PI / 6), endY - headLen * Math.sin(angle - Math.PI / 6));
                                            ctx.lineTo(endX - headLen * Math.cos(angle + Math.PI / 6), endY - headLen * Math.sin(angle + Math.PI / 6));
                                            ctx.lineTo(endX, endY);
                                            ctx.fillStyle = root.activeColor;
                                            ctx.fill();
                                        }
                                    }
                                }
                            }

                            // Front Vowels (Notice: no 'z: 10' at the end anymore)
                            VowelLabel { codeText: "i";  ipaText: "/i/"; relX: root.vowelMap["i"].x; relY: root.vowelMap["i"].y }
                            VowelLabel { codeText: "I";  ipaText: "/ɪ/"; relX: root.vowelMap["I"].x; relY: root.vowelMap["I"].y }
                            VowelLabel { codeText: "e";  ipaText: "/e/"; relX: root.vowelMap["e"].x; relY: root.vowelMap["e"].y }
                            VowelLabel { codeText: "ae"; ipaText: "/æ/"; relX: root.vowelMap["ae"].x; relY: root.vowelMap["ae"].y }

                            // Central Vowels
                            VowelLabel { codeText: "uh"; ipaText: "/ə/"; relX: root.vowelMap["uh"].x; relY: root.vowelMap["uh"].y }
                            VowelLabel { codeText: "er"; ipaText: "/ɜː/"; relX: root.vowelMap["er"].x; relY: root.vowelMap["er"].y }
                            VowelLabel { codeText: "^";  ipaText: "/ʌ/"; relX: root.vowelMap["^"].x; relY: root.vowelMap["^"].y }

                            // Back Vowels
                            VowelLabel { codeText: "u";  ipaText: "/u/"; relX: root.vowelMap["u"].x; relY: root.vowelMap["u"].y }
                            VowelLabel { codeText: "oo"; ipaText: "/ʊ/"; relX: root.vowelMap["oo"].x; relY: root.vowelMap["oo"].y }
                            VowelLabel { codeText: "ou"; ipaText: "/ɔː/"; relX: root.vowelMap["ou"].x; relY: root.vowelMap["ou"].y }
                            VowelLabel { codeText: "aa"; ipaText: "/ɑː/"; extraText: " &bull; <font face='monospace'>ah</font> /ɒ/"; relX: root.vowelMap["aa"].x; relY: root.vowelMap["aa"].y }
                           
                        }
                    }
                }
            }

            // LOWER SECTION: Interactive Diphthong Cards
            Flow {
                Layout.fillWidth: true
                spacing: 20
                
                DiphthongCard {
                    titleText: "Closing to Front"
                    targetText: "/ɪ/"
                    themeColor: "#007bff"
                    bgColor: "#f8fbff"
                    rowData: [
                        { start: "e", end: "i", code: "eI", ipa: "/eɪ/", example: "b<b>ai</b>t" },
                        { start: "a", end: "i", code: "aI", ipa: "/aɪ/", example: "b<b>i</b>te" },
                        { start: "o", end: "i", code: "oy", ipa: "/ɔɪ/", example: "b<b>oy</b>" }
                    ]
                }
                DiphthongCard {
                    titleText: "Closing to Back"
                    targetText: "/ʊ/"
                    themeColor: "#f44336"
                    bgColor: "#fff8f8"
                    rowData: [
                        { start: "uh", end: "u", code: "oa", ipa: "/əʊ/", example: "b<b>oa</b>t" },
                        { start: "a", end: "u", code: "ow", ipa: "/aʊ/", example: "b<b>ou</b>t" }
                    ]
                }
                DiphthongCard {
                    titleText: "Centering"
                    targetText: "/ə/"
                    themeColor: "#4caf50"
                    bgColor: "#f6fdf6"
                    rowData: [
                        { start: "i", end: "uh", code: "ia", ipa: "/ɪə/", example: "h<b>ere</b>" },
                        { start: "e", end: "uh", code: "ea", ipa: "/eə/", example: "h<b>air</b>" },
                        { start: "u", end: "uh", code: "ua", ipa: "/ʊə/", example: "t<b>our</b>" }
                    ]
                }
            }
        }
    }
}
