import sys
import os  # NEW: Import the OS module
from PySide6.QtCore import QObject, Slot
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine, qmlRegisterType

# 1. Define the Python Helper Class
class FileIO(QObject):
    def __init__(self, parent=None):
        super().__init__(parent)

    # The @Slot decorator is Python's equivalent to Q_INVOKABLE.
    # We specify the argument types (str, str) and the return type (bool).
    @Slot(str, str, result=bool)
    def write(self, file_name, data):
        try:
            # Using encoding='utf-8' is highly recommended for IPA symbols!
            with open(file_name, 'w', encoding='utf-8') as file:
                file.write(data)
            return True
        except Exception as e:
            print(f"Failed to write file {file_name}: {e}")
            return False

if __name__ == "__main__":
    # FIX: Enable XMLHttpRequest to read local files (like en_phonemes.json)
    os.environ["QML_XHR_ALLOW_FILE_READ"] = "1"
    app = QGuiApplication(sys.argv)

    # 2. Register the Python class to the QML engine
    # "MyApp.Utils" is the import module, 1.0 is the version, "FileIO" is the QML component name
    qmlRegisterType(FileIO, "MyApp.Utils", 1, 0, "FileIO")

    engine = QQmlApplicationEngine()
    
    # 3. Load your main QML file
    # Make sure "main.qml" is in the same directory as this Python script
    engine.load("main.qml")

    if not engine.rootObjects():
        sys.exit(-1)

    sys.exit(app.exec())
