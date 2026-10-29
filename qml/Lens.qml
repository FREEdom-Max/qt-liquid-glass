import QtQuick
ShaderEffect {
 id: lens
 required property var scene
 required property var backgroundTexture
 property real corner: 22
 property real refraction: 14
 property real chroma: 1.1
 property real blur: 0.4
 property real veil: 0.03
 property real over: 0
 property real pushed: 0
 property real zoom: 1.025
 property real magnification: zoom
 property var source: backgroundTexture
 property size viewport: Qt.size(scene.width,scene.height)
 property vector4d surface: {
  var revision=scene.geometryRevision;
  var xx=x; var yy=y; var ss=scale;
  var node=parent;
  while(node && node!==scene) {var px=node.x;var py=node.y;var ps=node.scale;node=node.parent;}
  var p=mapToItem(scene,0,0);
  var end=mapToItem(scene,width,height);
  return Qt.vector4d(p.x,p.y,end.x-p.x,end.y-p.y);
 }
 property real radius: corner
 property real bend: refraction
 property real dispersion: scene.chromatic ? chroma : 0
 property real roughness: blur
 property real tint: veil
 property real hover: over
 property real down: pushed
 property real dark: scene.whiteInk ? 1 : 0
 property point pointer: Qt.point(scene.mouseX/scene.width*2-1,scene.mouseY/scene.height*2-1)
 fragmentShader: "lens.frag.qsb"
 onStatusChanged: if(status===ShaderEffect.Error) scene.shaderError=log
 Behavior on over { NumberAnimation {duration:140} }
 Behavior on pushed { NumberAnimation {duration:100} }
}
