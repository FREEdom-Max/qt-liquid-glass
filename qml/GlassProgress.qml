import QtQuick
import QtQuick.Controls.Basic as C
C.ProgressBar {
 id:control
 required property var theme
 implicitHeight:12
 background:Prism{theme:control.theme;corner:6}
 contentItem:Item {
  Rectangle{width:parent.width*control.position;height:parent.height;radius:height/2;color:"#b3e58a40";Behavior on width{NumberAnimation{duration:100;easing.type:Easing.OutCubic}}}
 }
}
