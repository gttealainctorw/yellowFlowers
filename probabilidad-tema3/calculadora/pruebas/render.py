import sys, glob
from PIL import Image, ImageDraw, ImageFont
W,H=318,212; S=2
FD="/usr/share/fonts/truetype/dejavu/"
def font(style,size):
    import os
    name={"r":"DejaVuSans.ttf","b":"DejaVuSans-Bold.ttf","i":"DejaVuSans-Oblique.ttf"}.get(style,"DejaVuSans.ttf")
    if not os.path.exists(FD+name): name="DejaVuSans.ttf"
    px={7:7,9:9,10:10,11:11,12:12}.get(size,10)
    return ImageFont.truetype(FD+name, px*S)
for path in sorted(glob.glob("shot_*.txt")):
    img=Image.new("RGB",(W*S,H*S),"white")
    color=(0,0,0); clip=None
    for line in open(path,encoding="utf-8"):
        line=line.rstrip("\n"); parts=line.split("|")
        op=parts[0]
        layer=Image.new("RGBA",(W*S,H*S),(0,0,0,0)); d=ImageDraw.Draw(layer)
        if op=="C": color=tuple(int(v) for v in parts[1:4]); continue
        if op=="K":
            clip=None if parts[1]=="reset" else tuple(int(v) for v in parts[1:5]); continue
        if op=="F":
            x,y,w,h=map(int,parts[1:5]); d.rectangle([x*S,y*S,(x+w)*S-1,(y+h)*S-1],fill=color)
        elif op=="R":
            x,y,w,h=map(int,parts[1:5]); d.rectangle([x*S,y*S,(x+w)*S-1,(y+h)*S-1],outline=color,width=S)
        elif op=="S":
            x,y=int(parts[1]),int(parts[2]); st=parts[4]; sz=int(parts[5]); txt="|".join(parts[6:])
            d.text((x*S,y*S),txt,font=font(st,sz),fill=color)
        if clip:
            x,y,w,h=clip; mask=Image.new("L",(W*S,H*S),0); ImageDraw.Draw(mask).rectangle([x*S,y*S,(x+w)*S-1,(y+h)*S-1],fill=255)
            a=layer.split()[3]; from PIL import ImageChops; layer.putalpha(ImageChops.multiply(a,mask))
        img.paste(layer,(0,0),layer)
    ImageDraw.Draw(img).rectangle([0,0,W*S-1,H*S-1],outline=(120,120,120))
    img.save(path.replace(".txt",".png"))
# contact sheet
fs=sorted(glob.glob("shot_*.png"))
ims=[Image.open(f) for f in fs]
cols=3; rows=(len(ims)+cols-1)//cols
sheet=Image.new("RGB",(cols*(W*S+20),rows*(H*S+20)),(60,60,60))
for i,im in enumerate(ims): sheet.paste(im,((i%cols)*(W*S+20)+10,(i//cols)*(H*S+20)+10))
for k in range(0,rows,3):
    part=sheet.crop((0,k*(H*S+20),sheet.width,min(sheet.height,(k+3)*(H*S+20))))
    part.save("sheet_%d.png"%(k//3))
print(len(fs))
