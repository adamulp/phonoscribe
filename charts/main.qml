import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ApplicationWindow {
    id: appWindow
    visible: true
    width: 1080
    height: 750
    title: "Interactive English Phonemes (Modular)"
    color: "#ffffff"

    // --- GLOBAL DATA ---
    property var phonemeData: null

    Component.onCompleted: {
        var xhr = new XMLHttpRequest();
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200 || xhr.status === 0) {
                    try {
                        phonemeData = JSON.parse(xhr.responseText);
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

        // Each custom component acts as a tab. 
        // We pass the parsed JSON directly into them.
        VowelsTab {
            phonemeData: appWindow.phonemeData
        }
        
        ConsonantsTab {
            phonemeData: appWindow.phonemeData
        }
        
        SymbolsTab {
            phonemeData: appWindow.phonemeData
        }
    }
}
