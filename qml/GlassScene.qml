import QtQuick
Item {
    id: scene
    default property alias content: foreground.data
    property alias background: backdrop.data
    property bool whiteInk: false
    property bool effectsEnabled: true
    property bool chromatic: true
    property color ink: whiteInk ? "#f4fafb" : "#183443"
    property color accent: "#e58a40"
    property string fontFamily: "Microsoft YaHei UI"
    property int fontSize: 14
    readonly property bool desktopGlass: false
    readonly property bool desktopTextureReady: false
    readonly property bool nativeRefraction: false
    property int geometryRevision: 0
    property real mouseX: width / 2
    property real mouseY: height / 2
    property string shaderError: ""
    readonly property var backdropTexture: texture
    onShaderErrorChanged: if (shaderError) effectsEnabled = false
    onWidthChanged: geometryRevision++
    onHeightChanged: geometryRevision++
    Item {
        id: backdrop
        anchors.fill: parent
        Rectangle { anchors.fill: parent; color: scene.whiteInk ? "#243344" : "#c6e7ea" }
    }
    ShaderEffectSource {
        id: texture
        sourceItem: backdrop
        visible: false
        live: scene.effectsEnabled && scene.width > 0 && scene.height > 0
    }
    Item { id: foreground; anchors.fill: parent }
    HoverHandler {
        onPointChanged: {
            scene.mouseX = point.position.x
            scene.mouseY = point.position.y
        }
    }
}
