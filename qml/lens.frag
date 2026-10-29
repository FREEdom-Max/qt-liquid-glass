#version 440
layout(location=0) in vec2 qt_TexCoord0;
layout(location=0) out vec4 fragColor;
layout(std140,binding=0) uniform buf {
 mat4 qt_Matrix; float qt_Opacity;
 vec2 viewport; vec4 surface;
 float radius; float bend; float dispersion; float roughness;
 float tint; float hover; float down; float dark;
 vec2 pointer; float magnification;
};
layout(binding=1) uniform sampler2D source;
float sdf(vec2 p,vec2 h,float r){vec2 q=abs(p)-h+r;return length(max(q,0.))+min(max(q.x,q.y),0.)-r;}
vec3 readAt(vec2 p){return texture(source,clamp(p/viewport,vec2(.001),vec2(.999))).rgb;}
vec3 blurred(vec2 p){
 vec2 b=vec2(roughness,0.);
 return readAt(p)*.4+(readAt(p+b)+readAt(p-b)+readAt(p+b.yx)+readAt(p-b.yx))*.15;
}
void main(){
 vec2 size=surface.zw, h=size*.5, local=(qt_TexCoord0-.5)*size;
 float r=min(radius,min(h.x,h.y)); float d=sdf(local,h,r);
 vec2 n=normalize(vec2(sdf(local+vec2(.5,0),h,r)-sdf(local-vec2(.5,0),h,r),sdf(local+vec2(0,.5),h,r)-sdf(local-vec2(0,.5),h,r))+vec2(.00001));
 float bevel=max(3.,min(r*.85,20.));
 float t=clamp(-d/bevel,0.,1.);
 float slope=pow(1.-t,1.5);
 vec2 p=surface.xy+qt_TexCoord0*size;
 vec2 offset=-n*bend*slope*(1.+hover*.12-down*.15)-local*(1.-1./max(1.,magnification))*min(bend/10.,1.);
 vec2 uv=p+offset;
 vec2 split=n*dispersion*pow(1.-t,2.);
 vec3 c=vec3(blurred(uv+split).r,blurred(uv).g,blurred(uv-split).b);
 c=mix(c,(dark>.5?vec3(.04):vec3(.86,.91,.94)),tint);
 vec2 light=normalize(vec2(-.65,-.8)+pointer*.28);
 float facing=dot(n,light);
 float rim=exp(-abs(d+1.1)*1.5);
 float spec=pow(max(0.,facing),5.)*.6+pow(max(0.,-facing),7.)*.28;
 c+=vec3(rim*(.09+spec+hover*.08));
 c-=vec3(exp(-abs(d+2.8)*1.1)*max(0.,-facing)*.08);
 float alpha=1.-smoothstep(-.8,.3,d);
 fragColor=vec4(c*alpha,alpha)*qt_Opacity;
}
