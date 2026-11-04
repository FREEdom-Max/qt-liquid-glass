import QtQuick
import QtQuick.Layouts
import "../qml"
GlassScene {
    id: scene
    width: 800; height: 580
    property int clicks: 0
    background: Rectangle {
        x: parent.width * .45; y: 50; width: 280; height: 400
        radius: 100; rotation: 25; color: scene.whiteInk ? "#49486c" : "#e6b3a1"
    }
    ColumnLayout {
        anchors.centerIn: parent; spacing: 24; width: 360
        Text { text: "Qt Liquid Glass"; color: scene.ink; font.pixelSize: 28 }
        GlassButton { objectName: "button"; theme: scene; text: "点击 " + scene.clicks; onClicked: scene.clicks++ }
        GlassSwitch { objectName: "switch"; theme: scene; text: checked ? "已开启" : "已关闭" }
        GlassSlider { objectName: "slider"; id: slider; theme: scene; Layout.fillWidth: true; from: 0; to: 100; value: 50; stepSize: 1 }
        Text { text: "数值 " + Math.round(slider.value); color: scene.ink }
        GlassProgress { objectName: "progress"; theme: scene; Layout.fillWidth: true; value: slider.value / 100 }
        GlassSwitch { theme: scene; text: "深色"; onToggled: scene.whiteInk = checked }
        GlassSwitch { theme: scene; text: "材质效果"; checked: true; onToggled: scene.effectsEnabled = checked }
    }
}
