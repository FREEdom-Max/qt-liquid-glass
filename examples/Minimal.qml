import QtQuick
import QtQuick.Layouts
import "../qml"

GlassScene {
    id: scene
    width: 800; height: 640
    property int clicks: 0
    property int backgroundMode: 0
    property string demonstration: "四种公开控件 · 共享背景 · 清晰前景"
    backgroundColor: backgroundMode === 1 ? "#fafafa" : backgroundMode === 2 ? "#151923" : whiteInk ? "#243344" : "#c6e7ea"
    background: Rectangle {
        x: parent.width * .45; y: 50; width: 280; height: 480
        radius: 100; rotation: 25; color: scene.whiteInk ? "#49486c" : "#e6b3a1"
    }
    Item {
        anchors.centerIn: parent
        width: Math.min(430, parent.width - 48); height: 560
        Prism { anchors.fill: parent; theme: scene; corner: 28 }
        ColumnLayout {
            anchors.fill: parent; anchors.margins: 28; spacing: 18
            Text { text: "Qt Liquid Glass"; color: scene.ink; font.family: scene.fontFamily; font.pixelSize: 28; font.bold: true }
            GlassButton { objectName: "button"; theme: scene; text: "点击 " + scene.clicks; onClicked: scene.clicks++ }
            GlassSwitch { objectName: "switch"; theme: scene; text: checked ? "已开启" : "已关闭" }
            GlassSlider { objectName: "slider"; id: slider; theme: scene; Layout.fillWidth: true; from: 0; to: 100; value: 50; stepSize: 1 }
            Text { text: "数值 " + Math.round(slider.value); color: scene.ink; font.family: scene.fontFamily; font.pixelSize: scene.fontSize }
            GlassProgress { objectName: "progress"; theme: scene; Layout.fillWidth: true; value: slider.value / 100 }
            GlassSwitch { objectName: "themeSwitch"; theme: scene; text: "深色"; checked: scene.whiteInk; onToggled: scene.whiteInk = checked }
            GlassSwitch { objectName: "effectsSwitch"; theme: scene; text: "材质效果"; checked: scene.effectsEnabled; onToggled: scene.effectsEnabled = checked }
            Text { Layout.fillWidth: true; text: scene.demonstration; color: scene.ink; font.family: scene.fontFamily; font.pixelSize: 12; wrapMode: Text.Wrap }
        }
    }
}
