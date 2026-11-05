import QtQuick

Item {
    id: material
    required property var theme
    property real corner: 22
    property real refraction: 19
    property real chroma: 1.8
    property real blur: 0.35
    property real veil: theme.surfaceVeil
    property real over: 0
    property real pushed: 0
    property real zoom: 1.025
    readonly property vector4d surface: lens.surface
    readonly property bool active: theme.materialReady && width > 0 && height > 0
    Rectangle {
        anchors.fill: parent
        radius: material.corner
        color: material.theme.whiteInk ? "#233947" : "#dce8ed"
        border.color: material.theme.whiteInk ? "#6086a7b7" : "#aaffffff"
        visible: !material.active
    }
    Lens {
        id: lens
        anchors.fill: parent
        visible: material.active
        scene: material.theme
        backgroundTexture: material.theme.backdropTexture
        corner: material.corner
        refraction: material.refraction
        chroma: material.chroma
        blur: material.blur
        veil: material.veil
        over: material.over
        pushed: material.pushed
        zoom: material.zoom
    }
}
