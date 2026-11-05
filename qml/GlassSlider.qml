import QtQuick
import QtQuick.Controls.Basic as C
C.Slider {
 id:control
 required property var theme
 focusPolicy:Qt.StrongFocus
 font.family:theme.fontFamily;font.pixelSize:theme.fontSize
 orientation:Qt.Horizontal
 opacity:enabled?1:.45
 implicitHeight:38
 background:Rectangle{x:control.leftPadding;y:control.topPadding+(control.availableHeight-height)/2;width:control.availableWidth;height:5;radius:3;color:control.theme.whiteInk?"#55ffffff":"#44304e65"
  Rectangle{width:parent.width*control.visualPosition;height:parent.height;radius:3;color:control.theme.accent}
 }
 handle:Prism{
  theme:control.theme
  property real deform:control.pressed?1:0
  Behavior on deform{NumberAnimation{duration:control.pressed?100:180;easing.type:Easing.OutCubic}}
  width:40+4*deform;height:30-2*deform;corner:height/2
  x:control.leftPadding+control.visualPosition*(control.availableWidth-width);y:control.topPadding+(control.availableHeight-height)/2
  over:control.hovered?1:0;pushed:control.pressed?1:0
  Rectangle{anchors.fill:parent;anchors.margins:-3;radius:height/2;color:"transparent";border.width:2;border.color:control.theme.accent;visible:control.visualFocus}
 }
}
