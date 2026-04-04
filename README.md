# phonoscribe
An app for making phonetic transcriptions

## Features

- **IPA substitution**: type phoneme codes (e.g. `ae`, `th`, `sh`) and they are instantly replaced with the corresponding IPA characters (æ, θ, ʃ, …)
- **Zoomable editor**: `Ctrl+Wheel`, `Ctrl++` / `Ctrl+-` to zoom the text size
- **Multiple tabs**: open several files at once; tab labels show the file name
- **Save / Open** with emoji toolbar buttons (💾 `Ctrl+S`, 📂 `Ctrl+O`, Save As `Ctrl+Shift+S`)
- **Swappable phoneme sets**: load any JSON phoneme file via the 🔤 Phonemes… button

## Requirements

```
pip install -r requirements.txt
```

## Running

```
python phonoscribe.py
```

## Phoneme file format

See `en_phonemes.json` for the default English IPA mapping.  Any JSON file that
follows the same structure can be loaded at runtime to switch phoneme sets.
