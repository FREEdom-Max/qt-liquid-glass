import QtQuick
Item {
 id:material
 required property var theme
 readonly property bool nativeBacked:theme.nativeRefraction===true
 readonly property bool desktopBacked:theme.desktopGlass===true&&theme.desktopTextureReady!==true
 property int nativeKey:0
 readonly property vector4d nativeRect:lens.surface
 function syncNative(){
  if(!nativeKey||typeof nativeGlass==='undefined'||!nativeGlass)return;
  var r=nativeRect;var alpha=opacity;var cx=0,cy=0,cw=theme.width,ch=theme.height;
  var node=parent;
  while(node&&node!==theme){
   alpha*=node.opacity;
   if(node.clip){var p=node.mapToItem(theme,0,0);var x1=Math.max(cx,p.x),y1=Math.max(cy,p.y);var x2=Math.min(cx+cw,p.x+node.width),y2=Math.min(cy+ch,p.y+node.height);cx=x1;cy=y1;cw=Math.max(0,x2-x1);ch=Math.max(0,y2-y1)}
   node=node.parent;
  }
  if(!nativeBacked||!visible||alpha<.01||r.z<1||r.w<1||cw<1||ch<1){nativeGlass.sync_surface(nativeKey,[]);return}
  nativeGlass.sync_surface(nativeKey,[r.x,r.y,r.z,r.w,corner,alpha,cx,cy,cw,ch,refraction,chroma,zoom,over,pushed]);
 }
 onNativeRectChanged:syncNative()
 onNativeBackedChanged:syncNative()
 onVisibleChanged:syncNative()
 onOpacityChanged:syncNative()
 onCornerChanged:syncNative()
 onRefractionChanged:syncNative()
 onChromaChanged:syncNative()
 onZoomChanged:syncNative()
 onOverChanged:syncNative()
 onPushedChanged:syncNative()
 Component.onCompleted:{if(nativeBacked&&typeof nativeGlass!=='undefined'){nativeKey=nativeGlass.register_surface();syncNative()}}
 Component.onDestruction:if(nativeKey&&typeof nativeGlass!=='undefined'&&nativeGlass)nativeGlass.remove_surface(nativeKey)
 property real corner:22
 property real refraction:19
 property real chroma:1.8
 property real blur:.35
 property real veil:theme.whiteInk?.06:.34
 property real over:0
 property real pushed:0
 property real zoom:1.025
 Rectangle{anchors.fill:parent;radius:material.corner;color:material.theme.whiteInk?"#df233947":"#e2dce8ed";border.color:"#5086a7b7";visible:!material.desktopBacked&&!material.theme.effectsEnabled}
 Rectangle{
  anchors.fill:parent;visible:material.desktopBacked;radius:material.corner
  color:material.theme.whiteInk?Qt.rgba(.035,.055,.075,Math.min(.65,material.veil*1.75)):Qt.rgba(.92,.96,1,material.veil*.7)
  border.width:1;border.color:material.theme.whiteInk?"#65ffffff":"#a0ffffff"
 }
 Rectangle{
  anchors.fill:parent;anchors.margins:1;visible:material.desktopBacked;radius:Math.max(0,material.corner-1)
  opacity:Math.min(1,material.veil*6)
  gradient:Gradient{
   GradientStop{position:0;color:Qt.rgba(1,1,1,.11+material.over*.05)}
   GradientStop{position:.34;color:"transparent"}
   GradientStop{position:1;color:Qt.rgba(0,0,0,.035+material.pushed*.035)}
  }
 }
 Lens{
  id:lens
  anchors.fill:parent;visible:!material.desktopBacked&&material.theme.effectsEnabled
  scene:material.theme;backgroundTexture:material.theme.backdropTexture
  corner:material.corner;refraction:material.refraction;chroma:material.chroma;blur:material.blur;veil:material.veil;over:material.over;pushed:material.pushed;zoom:material.zoom
 }
 // Dark-mode white text needs a grey veil that dims bright desktop content.
 Rectangle{
  anchors.fill:parent;radius:material.corner
  visible:material.theme.whiteInk
  color:"#3d404040"
 }
}
