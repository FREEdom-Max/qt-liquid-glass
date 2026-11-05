import QtQuick
import "../qml"

GlassScene {
    id: scene
    width: 680; height: 520
    property alias lensVisible: material.visible
    property alias tint: material.veil
    property alias moving: moving
    property alias clipper: clipper
    property alias material: material
    background: Item {
        anchors.fill: parent
        Repeater {
            model: 400
            Rectangle {
                required property int index
                x: (index % 20) * 40; y: Math.floor(index / 20) * 40
                width: 40; height: 40
                color: Qt.rgba((index % 20) / 20, Math.floor(index / 20) / 20, .35, 1)
            }
        }
    }
    Item {
        id: clipper; objectName: "clipper"
        x: 70; y: 60; width: 440; height: 340; clip: false
        Item {
            id: moving; objectName: "moving"
            x: 35; y: 30; width: 240; height: 180
            Prism {
                id: material; objectName: "probe"
                theme: scene; x: 15; y: 20; width: 180; height: 120
                corner: 16; refraction: 0; chroma: 0; blur: 0; veil: 0; zoom: 1
            }
        }
    }
}
