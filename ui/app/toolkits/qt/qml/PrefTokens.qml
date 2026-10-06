import QtQuick

// Design token object — instantiate as `PrefTokens { id: tok }` in each component.
// Qt::ColorScheme::Dark == 2; binding updates live when the user changes the setting.
QtObject {
    readonly property bool isDark: Qt.styleHints.colorScheme === 2

    // ── Colors ────────────────────────────────────────────────────────────────
    // Glass design: windows get a native glass/blur backdrop (see MacGlass), so the
    // surfaces here are translucent tints laid over it instead of opaque fills.
    readonly property color bg:         "transparent"
    readonly property color panel:      isDark ? Qt.rgba(1, 1, 1, 0.07) : Qt.rgba(1, 1, 1, 0.50)
    readonly property color panel2:     isDark ? Qt.rgba(1, 1, 1, 0.04) : Qt.rgba(1, 1, 1, 0.30)
    readonly property color edge:       isDark ? Qt.rgba(1, 1, 1, 0.20) : Qt.rgba(1, 1, 1, 0.80)
    readonly property color edge2:      isDark ? Qt.rgba(1, 1, 1, 0.10) : Qt.rgba(1, 1, 1, 0.45)
    readonly property color ink:        isDark ? "#F4F1E8" : "#1F221E"
    readonly property color ink2:       isDark ? "#D6D2C5" : "#3C403A"
    readonly property color mute:       isDark ? "#A3A599" : "#6A6C63"
    readonly property color sage:       isDark ? "#9DBA99" : "#5E7A5B"
    readonly property color sageDeep:   isDark ? "#BFD6BB" : "#3A4D36"
    readonly property color sageSoft:   isDark ? Qt.rgba(0.62, 0.73, 0.60, 0.24) : Qt.rgba(0.37, 0.48, 0.36, 0.20)
    readonly property color clay:       isDark ? "#E8AB86" : "#B96A3A"
    readonly property color claySoft:   isDark ? Qt.rgba(0.91, 0.67, 0.53, 0.22) : Qt.rgba(0.73, 0.42, 0.23, 0.18)
    readonly property color track:      isDark ? Qt.rgba(1, 1, 1, 0.14) : Qt.rgba(0, 0, 0, 0.10)
    readonly property color danger:     isDark ? "#E58B7B" : "#B04A3A"
    readonly property color dangerSoft: isDark ? Qt.rgba(0.90, 0.55, 0.48, 0.22) : Qt.rgba(0.69, 0.29, 0.23, 0.16)
    readonly property color warn:       isDark ? "#EDAA5C" : "#C47820"
    readonly property color rest:       isDark ? "#9AD6A5" : "#5E9A6A"
    readonly property color actionBg:   isDark ? Qt.rgba(1, 1, 1, 0.13) : Qt.rgba(1, 1, 1, 0.65)
    readonly property color actionEdge: isDark ? Qt.rgba(1, 1, 1, 0.34) : Qt.rgba(0, 0, 0, 0.18)
    // Floating card over a full-screen glass backdrop (break windows).
    readonly property color card:       isDark ? Qt.rgba(0.10, 0.11, 0.10, 0.55) : Qt.rgba(1, 1, 1, 0.62)
    // Text colour on filled accent buttons.
    readonly property color onAccent:   isDark ? "#1B1D1A" : "#FFFFFF"

    // ── Typography ────────────────────────────────────────────────────────────
    readonly property int labelPx:    14    // primary row label
    readonly property int hintPx:     12    // secondary / hint text
    readonly property int bodyPx:     13    // body / nav items / lede
    readonly property int captionPx:  11    // section headers, small badges
    readonly property int stepperPx:  19    // large time value in stepper
    readonly property int btnPx:      16    // +/− button glyphs
    readonly property int tickPx:     10    // slider tick labels

    readonly property string serifFamily: "Georgia"
    readonly property string monoFamily:  "Menlo"

    // ── Layout ────────────────────────────────────────────────────────────────
    readonly property int  labelHintGap: 3     // spacing between label and hint
    readonly property real hintLineH:    1.45  // hint / body text line height
    readonly property int  rowPad:       28    // vertical padding in toggle/choice rows
    readonly property int  rowPadLg:     36    // vertical padding in stepper/time rows
    readonly property int  actionRadius: 8     // actions are visibly distinct from status pills
}
