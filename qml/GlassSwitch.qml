import QtQuick
import QtQuick.Controls.Basic as C
C.Switch {
 id:control
 required property var theme
 implicitHeight:44
 spacing:12
 font.family:"Microsoft YaHei UI";font.pixelSize:14;font.weight:Font.Bold
 indicator:Prism {
  theme:control.theme;implicitWidth:66;implicitHeight:38;x:control.leftPadding;y:(control.height-height)/2;corner:19
  Rectangle{anchors.fill:parent;radius:19;color:control.checked?"#77e58a40":"transparent";Behavior on color{ColorAnimation{duration:240;easing.type:Easing.InOutCubic}}}
  Prism{theme:control.theme;width:30;height:30;y:4;x:control.checked?32:4;corner:15;Behavior on x{NumberAnimation{duration:240;easing.type:Easing.InOutCubic}}}
 }
 contentItem:Text{text:control.text;font:control.font;color:control.theme.ink;leftPadding:control.indicator.width+control.spacing;verticalAlignment:Text.AlignVCenter}
}
