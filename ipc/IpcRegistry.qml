import QtQuick

QtObject {
    property LockIpc lock: LockIpc {}
    property ScreenshotIpc screenshot: ScreenshotIpc {}
    property RecorderIpc recorder: RecorderIpc {}
    property ClipboardIpc clipboard: ClipboardIpc {}
    property SettingsIpc settings: SettingsIpc {}
    property PickerIpc picker: PickerIpc {}
    property WallpaperIpc wallpaper: WallpaperIpc {}
}
