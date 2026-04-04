#!/usr/bin/env python3
"""Phonoscribe – a PySide6 app for phonetic transcription using IPA substitution."""

import json
import os
import sys

from PySide6.QtCore import Qt
from PySide6.QtGui import (
    QAction,
    QFont,
    QKeySequence,
    QTextCursor,
    QWheelEvent,
)
from PySide6.QtWidgets import (
    QApplication,
    QFileDialog,
    QLabel,
    QMainWindow,
    QMessageBox,
    QPlainTextEdit,
    QTabWidget,
    QToolBar,
    QWidget,
)

DEFAULT_PHONEMES_FILE = os.path.join(os.path.dirname(__file__), "en_phonemes.json")
DEFAULT_FONT_SIZE = 14
MIN_FONT_SIZE = 6
MAX_FONT_SIZE = 72
ZOOM_STEP = 2


def load_phoneme_map(path: str) -> dict[str, str]:
    """Load a phoneme JSON file and return a flat {code: ipa} mapping."""
    with open(path, encoding="utf-8") as fh:
        data = json.load(fh)

    mapping: dict[str, str] = {}

    def add_entry(code: str, ipa: str) -> None:
        if code and ipa:
            mapping[code] = ipa

    def add_list(items: list) -> None:
        for item in items:
            if isinstance(item, dict):
                add_entry(item.get("code", ""), item.get("ipa", ""))

    def add_dict_values(d: dict) -> None:
        for key, val in d.items():
            if isinstance(val, dict):
                add_entry(key, val.get("ipa", ""))
            elif isinstance(val, list):
                add_list(val)

    for section_key, section in data.items():
        if isinstance(section, dict):
            # Check if it's a flat dict of {code: {ipa:...}} (delimiters/modifiers)
            # or a nested dict of {subcategory: [...]} (consonants/monophthongs)
            first_val = next(iter(section.values()), None) if section else None
            if isinstance(first_val, dict) and "ipa" in first_val:
                add_dict_values(section)
            elif isinstance(first_val, (dict, list)):
                for sub in section.values():
                    if isinstance(sub, list):
                        add_list(sub)
                    elif isinstance(sub, dict):
                        add_dict_values(sub)
        elif isinstance(section, list):
            add_list(section)

    return mapping


class TranscriptionEditor(QPlainTextEdit):
    """Text editor with IPA substitution and Ctrl+Wheel / Ctrl±zoom."""

    def __init__(self, phoneme_map: dict[str, str], parent: QWidget | None = None):
        super().__init__(parent)
        self._phoneme_map = phoneme_map
        self._sorted_codes: list[str] = sorted(
            phoneme_map.keys(), key=len, reverse=True
        )
        self._font_size = DEFAULT_FONT_SIZE
        self._apply_font_size()
        self.setLineWrapMode(QPlainTextEdit.LineWrapMode.WidgetWidth)

    # ------------------------------------------------------------------
    # Public helpers
    # ------------------------------------------------------------------

    def set_phoneme_map(self, phoneme_map: dict[str, str]) -> None:
        self._phoneme_map = phoneme_map
        self._sorted_codes = sorted(phoneme_map.keys(), key=len, reverse=True)

    def zoom_in(self) -> None:
        self._font_size = min(self._font_size + ZOOM_STEP, MAX_FONT_SIZE)
        self._apply_font_size()

    def zoom_out(self) -> None:
        self._font_size = max(self._font_size - ZOOM_STEP, MIN_FONT_SIZE)
        self._apply_font_size()

    # ------------------------------------------------------------------
    # Private helpers
    # ------------------------------------------------------------------

    def _apply_font_size(self) -> None:
        font = self.font()
        font.setPointSize(self._font_size)
        self.setFont(font)

    def _try_substitute(self) -> None:
        """Check if the characters just before the cursor match a phoneme code
        and, if so, replace them with the IPA equivalent."""
        cursor = self.textCursor()
        pos = cursor.position()
        text = self.toPlainText()

        for code in self._sorted_codes:
            code_len = len(code)
            start = pos - code_len
            if start < 0:
                continue
            if text[start:pos] == code:
                # Replace the code with its IPA equivalent
                cursor.setPosition(start)
                cursor.setPosition(pos, QTextCursor.MoveMode.KeepAnchor)
                cursor.insertText(self._phoneme_map[code])
                break

    # ------------------------------------------------------------------
    # Event overrides
    # ------------------------------------------------------------------

    def keyPressEvent(self, event) -> None:
        # Zoom shortcuts: Ctrl++ / Ctrl+- / Ctrl+KP_Plus / Ctrl+KP_Minus
        if event.modifiers() == Qt.KeyboardModifier.ControlModifier:
            key = event.key()
            if key in (Qt.Key.Key_Plus, Qt.Key.Key_Equal,
                       Qt.Key.Key_BracketRight):
                self.zoom_in()
                return
            if key == Qt.Key.Key_Minus:
                self.zoom_out()
                return

        super().keyPressEvent(event)

        # After inserting a printable character, attempt IPA substitution
        if event.text() and not event.modifiers() & ~Qt.KeyboardModifier.ShiftModifier:
            self._try_substitute()

    def wheelEvent(self, event: QWheelEvent) -> None:
        if event.modifiers() == Qt.KeyboardModifier.ControlModifier:
            if event.angleDelta().y() > 0:
                self.zoom_in()
            else:
                self.zoom_out()
            event.accept()
        else:
            super().wheelEvent(event)


class MainWindow(QMainWindow):
    """Main application window."""

    def __init__(self) -> None:
        super().__init__()
        self.setWindowTitle("Phonoscribe")
        self.resize(900, 600)

        self._phoneme_map = load_phoneme_map(DEFAULT_PHONEMES_FILE)
        self._phonemes_file = DEFAULT_PHONEMES_FILE

        self._tab_widget = QTabWidget(self)
        self._tab_widget.setTabsClosable(True)
        self._tab_widget.tabCloseRequested.connect(self._close_tab)
        self.setCentralWidget(self._tab_widget)

        self._build_toolbar()
        self._build_menu()

        # Open with one blank tab
        self._new_tab()

    # ------------------------------------------------------------------
    # UI construction
    # ------------------------------------------------------------------

    def _build_toolbar(self) -> None:
        tb = QToolBar("Main", self)
        tb.setMovable(False)
        self.addToolBar(tb)

        # New tab
        act_new = QAction("➕ New", self)
        act_new.setToolTip("New tab (Ctrl+T)")
        act_new.setShortcut(QKeySequence("Ctrl+T"))
        act_new.triggered.connect(self._new_tab)
        tb.addAction(act_new)

        # Open file
        act_open = QAction("📂 Open", self)
        act_open.setToolTip("Open file (Ctrl+O)")
        act_open.setShortcut(QKeySequence.StandardKey.Open)
        act_open.triggered.connect(self._open_file)
        tb.addAction(act_open)

        # Save file
        act_save = QAction("💾 Save", self)
        act_save.setToolTip("Save file (Ctrl+S)")
        act_save.setShortcut(QKeySequence.StandardKey.Save)
        act_save.triggered.connect(self._save_file)
        tb.addAction(act_save)

        # Save As
        act_save_as = QAction("💾 Save As…", self)
        act_save_as.setToolTip("Save file as (Ctrl+Shift+S)")
        act_save_as.setShortcut(QKeySequence.StandardKey.SaveAs)
        act_save_as.triggered.connect(self._save_file_as)
        tb.addAction(act_save_as)

        tb.addSeparator()

        # Zoom in / out
        act_zoom_in = QAction("🔍+", self)
        act_zoom_in.setToolTip("Zoom in (Ctrl++)")
        act_zoom_in.setShortcut(QKeySequence(Qt.Modifier.CTRL | Qt.Key.Key_Plus))
        act_zoom_in.triggered.connect(self._zoom_in)
        tb.addAction(act_zoom_in)

        act_zoom_out = QAction("🔍-", self)
        act_zoom_out.setToolTip("Zoom out (Ctrl+-)")
        act_zoom_out.setShortcut(QKeySequence(Qt.Modifier.CTRL | Qt.Key.Key_Minus))
        act_zoom_out.triggered.connect(self._zoom_out)
        tb.addAction(act_zoom_out)

        tb.addSeparator()

        # Load phoneme set
        act_phonemes = QAction("🔤 Phonemes…", self)
        act_phonemes.setToolTip("Load phoneme substitution file")
        act_phonemes.triggered.connect(self._load_phonemes)
        tb.addAction(act_phonemes)

        self._phoneme_label = QLabel(
            f"  {os.path.basename(self._phonemes_file)}  ", self
        )
        tb.addWidget(self._phoneme_label)

    def _build_menu(self) -> None:
        menubar = self.menuBar()

        file_menu = menubar.addMenu("&File")

        act_new = QAction("&New Tab", self)
        act_new.setShortcut(QKeySequence("Ctrl+T"))
        act_new.triggered.connect(self._new_tab)
        file_menu.addAction(act_new)

        act_open = QAction("&Open…", self)
        act_open.setShortcut(QKeySequence.StandardKey.Open)
        act_open.triggered.connect(self._open_file)
        file_menu.addAction(act_open)

        file_menu.addSeparator()

        act_save = QAction("&Save", self)
        act_save.setShortcut(QKeySequence.StandardKey.Save)
        act_save.triggered.connect(self._save_file)
        file_menu.addAction(act_save)

        act_save_as = QAction("Save &As…", self)
        act_save_as.setShortcut(QKeySequence.StandardKey.SaveAs)
        act_save_as.triggered.connect(self._save_file_as)
        file_menu.addAction(act_save_as)

        file_menu.addSeparator()

        act_close = QAction("&Close Tab", self)
        act_close.setShortcut(QKeySequence("Ctrl+W"))
        act_close.triggered.connect(lambda: self._close_tab(self._tab_widget.currentIndex()))
        file_menu.addAction(act_close)

        view_menu = menubar.addMenu("&View")

        act_zoom_in = QAction("Zoom &In", self)
        act_zoom_in.setShortcut(QKeySequence(Qt.Modifier.CTRL | Qt.Key.Key_Plus))
        act_zoom_in.triggered.connect(self._zoom_in)
        view_menu.addAction(act_zoom_in)

        act_zoom_out = QAction("Zoom &Out", self)
        act_zoom_out.setShortcut(QKeySequence(Qt.Modifier.CTRL | Qt.Key.Key_Minus))
        act_zoom_out.triggered.connect(self._zoom_out)
        view_menu.addAction(act_zoom_out)

        phonemes_menu = menubar.addMenu("&Phonemes")

        act_load_ph = QAction("&Load phoneme file…", self)
        act_load_ph.triggered.connect(self._load_phonemes)
        phonemes_menu.addAction(act_load_ph)

    # ------------------------------------------------------------------
    # Tab management
    # ------------------------------------------------------------------

    def _new_tab(self, filepath: str | None = None) -> "TranscriptionEditor":
        editor = TranscriptionEditor(self._phoneme_map, self)
        editor.setProperty("filepath", filepath)
        label = os.path.basename(filepath) if filepath else "Untitled"
        idx = self._tab_widget.addTab(editor, label)
        self._tab_widget.setCurrentIndex(idx)
        return editor

    def _current_editor(self) -> "TranscriptionEditor | None":
        return self._tab_widget.currentWidget()  # type: ignore[return-value]

    def _close_tab(self, index: int) -> None:
        editor: TranscriptionEditor = self._tab_widget.widget(index)  # type: ignore[assignment]
        if editor and editor.document().isModified():
            reply = QMessageBox.question(
                self,
                "Unsaved changes",
                "This tab has unsaved changes. Close anyway?",
                QMessageBox.StandardButton.Yes | QMessageBox.StandardButton.No,
            )
            if reply != QMessageBox.StandardButton.Yes:
                return
        self._tab_widget.removeTab(index)
        if self._tab_widget.count() == 0:
            self._new_tab()

    # ------------------------------------------------------------------
    # File operations
    # ------------------------------------------------------------------

    def _open_file(self) -> None:
        path, _ = QFileDialog.getOpenFileName(
            self, "Open file", "", "Text files (*.txt *.ipa);;All files (*)"
        )
        if not path:
            return
        try:
            with open(path, encoding="utf-8") as fh:
                content = fh.read()
        except OSError as exc:
            QMessageBox.critical(self, "Error", f"Could not open file:\n{exc}")
            return
        editor = self._new_tab(path)
        editor.setPlainText(content)
        editor.document().setModified(False)

    def _save_file(self) -> None:
        editor = self._current_editor()
        if editor is None:
            return
        path: str | None = editor.property("filepath")
        if not path:
            self._save_file_as()
            return
        self._write_file(editor, path)

    def _save_file_as(self) -> None:
        editor = self._current_editor()
        if editor is None:
            return
        path, _ = QFileDialog.getSaveFileName(
            self, "Save file as", "", "Text files (*.txt *.ipa);;All files (*)"
        )
        if not path:
            return
        self._write_file(editor, path)

    def _write_file(self, editor: "TranscriptionEditor", path: str) -> None:
        try:
            with open(path, "w", encoding="utf-8") as fh:
                fh.write(editor.toPlainText())
        except OSError as exc:
            QMessageBox.critical(self, "Error", f"Could not save file:\n{exc}")
            return
        editor.setProperty("filepath", path)
        editor.document().setModified(False)
        idx = self._tab_widget.indexOf(editor)
        self._tab_widget.setTabText(idx, os.path.basename(path))

    # ------------------------------------------------------------------
    # Zoom
    # ------------------------------------------------------------------

    def _zoom_in(self) -> None:
        editor = self._current_editor()
        if editor:
            editor.zoom_in()

    def _zoom_out(self) -> None:
        editor = self._current_editor()
        if editor:
            editor.zoom_out()

    # ------------------------------------------------------------------
    # Phoneme file
    # ------------------------------------------------------------------

    def _load_phonemes(self) -> None:
        path, _ = QFileDialog.getOpenFileName(
            self, "Load phoneme file", "", "JSON files (*.json);;All files (*)"
        )
        if not path:
            return
        try:
            new_map = load_phoneme_map(path)
        except (OSError, json.JSONDecodeError, KeyError) as exc:
            QMessageBox.critical(self, "Error", f"Could not load phoneme file:\n{exc}")
            return
        self._phoneme_map = new_map
        self._phonemes_file = path
        self._phoneme_label.setText(f"  {os.path.basename(path)}  ")
        # Update all open editors
        for i in range(self._tab_widget.count()):
            editor: TranscriptionEditor = self._tab_widget.widget(i)  # type: ignore[assignment]
            editor.set_phoneme_map(new_map)


def main() -> None:
    app = QApplication(sys.argv)
    app.setApplicationName("Phonoscribe")
    window = MainWindow()
    window.show()
    sys.exit(app.exec())


if __name__ == "__main__":
    main()
