import QtQuick
Item {
    id: scene
    default property alias content: foreground.data
    property alias background: customBackground.data
    property bool backgroundReady: true
    property bool whiteInk: false
    property bool effectsEnabled: true
    property bool chromatic: true
    property color ink: whiteInk ? "#f4fafb" : "#183443"
    property color accent: "#e58a40"
    property color pressedInk: whiteInk ? Qt.lighter(accent, 1.5) : Qt.darker(accent, 2.2)
    property color backgroundColor: whiteInk ? "#243344" : "#c6e7ea"
    property real surfaceVeil: whiteInk ? 0.72 : 0.68
    property string fontFamily: "Microsoft YaHei UI"
    property int fontSize: 14
    readonly property bool materialReady: effectsEnabled && backgroundReady && width > 0 && height > 0
    property int geometryRevision: 0
    property real mouseX: width / 2
    property real mouseY: height / 2
    property string shaderError: ""
    readonly property var backdropTexture: texture
    onShaderErrorChanged: if (shaderError) effectsEnabled = false
    onWidthChanged: geometryRevision++
    onHeightChanged: geometryRevision++
    data: [Item {
        id: backdrop
        anchors.fill: parent
        Rectangle { anchors.fill: parent; color: scene.backgroundColor }
        Item { id: customBackground; anchors.fill: parent }
    },
    ShaderEffectSource {
        id: texture
        sourceItem: backdrop
        visible: false
        live: scene.materialReady
        textureSize: Qt.size(Math.max(1, Math.ceil(scene.width * Screen.devicePixelRatio)),
                             Math.max(1, Math.ceil(scene.height * Screen.devicePixelRatio)))
    },
    Item { id: foreground; anchors.fill: parent },
    HoverHandler {
        onPointChanged: {
            scene.mouseX = point.position.x
            scene.mouseY = point.position.y
        }
    }]
}
