import QtQuick
import QtQuick.Controls.Basic as C
C.ProgressBar {
 id:control
 required property var theme
 font.family:theme.fontFamily;font.pixelSize:theme.fontSize
 opacity:enabled?1:.45
 implicitHeight:12
 background:Prism{theme:control.theme;corner:6}
 contentItem:Item {
  Rectangle{width:parent.width*control.position;height:parent.height;radius:height/2;color:Qt.rgba(control.theme.accent.r,control.theme.accent.g,control.theme.accent.b,.7);Behavior on width{NumberAnimation{duration:100;easing.type:Easing.OutCubic}}}
 }
}
