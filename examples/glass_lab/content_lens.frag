#version 440
layout(location=0) in vec2 qt_TexCoord0;
layout(location=0) out vec4 fragColor;
layout(std140,binding=0) uniform buf {
 mat4 qt_Matrix; float qt_Opacity;
 vec2 contentSize; vec4 lensRect; vec4 selectedColor;
 float padding; float zoom;
};
layout(binding=1) uniform sampler2D source;
vec4 glyph(vec2 p){
 if(p.x<0.||p.y<0.||p.x>contentSize.x||p.y>contentSize.y)return vec4(0.);
 return texture(source,p/contentSize);
}
void main(){
 vec2 p=qt_TexCoord0*(contentSize+2.*padding)-padding;
 vec2 center=lensRect.xy+lensRect.zw*.5;
 vec2 halfSize=lensRect.zw*.5;
 float radius=halfSize.y;
 vec2 q=abs(p-center)-halfSize+radius;
 float d=length(max(q,0.))+min(max(q.x,q.y),0.)-radius;
 float mask=1.-smoothstep(-.6,.6,d);
 vec4 normal=glyph(p);
 vec4 enlarged=glyph(center+(p-center)/zoom);
 vec4 colored=vec4(selectedColor.rgb*enlarged.a,enlarged.a);
 fragColor=mix(normal,colored,mask)*qt_Opacity;
}
