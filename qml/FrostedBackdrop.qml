import QtQuick
import QtQuick.Effects

// One shared GPU frost pass, before the existing Lens samples the background.
Item {
 id:root
 required property Item source
 property real strength:16
 property bool active:true
 property real deviceRatio:Screen.devicePixelRatio
 readonly property var texture:strength>0?output:source
 MultiEffect {
  id:frost;anchors.fill:parent;visible:false
  source:root.source
  blurEnabled:true;blurMax:64;blurMultiplier:2
  blur:Math.max(0,Math.min(48,root.strength))/48
  autoPaddingEnabled:false
 }
 ShaderEffectSource {
  id:output;sourceItem:frost;hideSource:true;visible:false
  live:root.active&&root.strength>0
  textureSize:Qt.size(Math.max(1,Math.round(root.width*root.deviceRatio)),Math.max(1,Math.round(root.height*root.deviceRatio)))
 }
}
