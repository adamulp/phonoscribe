import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ApplicationWindow {
    visible: true
    width: 920
    height: 400
    title: "English Diphthongs (Pathway Layout)"
    color: "#ffffff"

    // Reusable inline component for the Cards
    component DiphthongCard : Rectangle {
        id: cardRoot
        width: 270
        height: cardLayout.implicitHeight
        radius: 8
        border.width: 1
        clip: true

        // Properties injected when the card is created
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

            // Header Section
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

            // Body Section
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: rowsLayout.implicitHeight + 30
                color: cardRoot.bgColor

                ColumnLayout {
                    id: rowsLayout
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 12

                    // Loops through the injected 'rowData' to build the formulas
                    Repeater {
                        model: cardRoot.rowData
                        delegate: RowLayout {
                            Layout.fillWidth: true
                            spacing: 10

                            Text {
                                text: "<font face='monospace'>" + modelData.start + "</font> &rarr; <font face='monospace'>" + modelData.end + "</font>"
                                textFormat: Text.RichText
                                font.pixelSize: 14
                                Layout.preferredWidth: 70
                            }
                            Text {
                                text: "<b>=</b>"
                                textFormat: Text.RichText
                                font.pixelSize: 14
                            }
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
                    }
                }
            }
        }
    }

    // Main View
    ScrollView {
        anchors.fill: parent
        anchors.margins: 20
        contentWidth: availableWidth

        // Flow layout automatically wraps the cards on smaller screens
        Flow {
            width: parent.width
            spacing: 20

            // 1. Target: /ɪ/
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

            // 2. Target: /ʊ/
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

            // 3. Target: /ə/
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
