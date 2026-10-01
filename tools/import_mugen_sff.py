"""Decode selected original MUGEN SFF v1 sprites into Godot-readable PNGs.
This is format conversion, preserving original indices, axes and AIR durations.
Usage: python tools/import_mugen_sff.py source.sff source.air output_directory
Requires Pillow. Never executes character scripts or binaries.
"""
import io,json,re,struct,sys
from pathlib import Path
from PIL import Image

def read_sff(path):
    data=Path(path).read_bytes()
    if data[:12]!=b'ElecbyteSpr\0' or data[15]!=1:
        raise ValueError('Only MUGEN SFF v1 is supported')
    offset=struct.unpack_from('<I',data,24)[0]
    records=[];sprites={};palette=None;visited=set()
    count=struct.unpack_from('<I',data,20)[0]
    while offset and len(records)<count:
        if offset in visited or offset+32>len(data):raise ValueError('Invalid subfile chain')
        visited.add(offset)
        following,length,x,y,group,index,linked,shared=struct.unpack_from('<IIhhHHHB',data,offset)
        body=data[offset+32:offset+32+length]
        if length:
            if len(body)!=length:raise ValueError('Truncated PCX')
            if len(body)>=769 and body[-769]==12:
                palette=body[-768:]
            elif shared and palette is not None:
                body+=bytes([12])+palette
            image=body
        else:
            if linked>=len(records):raise ValueError('Invalid linked sprite')
            image=records[linked]['image']
        record={'image':image,'axis':[x,y],'group':group,'index':index}
        records.append(record)
        sprites[(group,index)]=record
        offset=following
    return sprites

def decode_pcx(body):
    # Some Fighter Factory files carry valid RLE runs across scanline boundaries.
    # Decode the contiguous indexed raster, retaining the original palette.
    if body[0]!=10 or body[2]!=1 or body[3]!=8 or body[65]!=1:
        raise ValueError('Expected indexed 8-bit PCX')
    xmin,ymin,xmax,ymax=struct.unpack_from('<HHHH',body,4)
    width,height=xmax-xmin+1,ymax-ymin+1
    stride=struct.unpack_from('<H',body,66)[0]
    expected=stride*height
    if not (0<width<=4096 and 0<height<=4096 and stride>=width):
        raise ValueError('Invalid dimensions')
    raw=bytearray();offset=128
    while len(raw)<expected and offset<len(body)-769:
        value=body[offset];offset+=1
        if value>=192:
            count=value&63
            raw.extend(bytes([body[offset]])*count);offset+=1
        else:raw.append(value)
    if len(raw)!=expected or body[-769]!=12:raise ValueError('Invalid PCX raster or palette')
    image=Image.frombytes('P',(width,height),bytes(raw),'raw','P',stride,1)
    image.putpalette(body[-768:])
    return image

def actions(path):
    result={};current=None
    for line in Path(path).read_text(errors='replace').splitlines():
        line=line.split(';')[0].strip()
        header=re.match(r'\[Begin Action\s+(\d+)\]',line,re.I)
        if header:current=int(header[1]);result[current]=[]
        elif current is not None and re.match(r'^-?\d+\s*,',line):
            fields=[v.strip() for v in line.split(',')]
            if len(fields)>=5:
                result[current].append({'sprite':[int(fields[0]),int(fields[1])],'offset':[int(fields[2]),int(fields[3])],'ticks':max(1,int(fields[4])),'flip':fields[5] if len(fields)>5 else ''})
    return result

def convert(sff,air,destination):
    sprites=read_sff(sff);anims=actions(air);root=Path(destination);root.mkdir(parents=True,exist_ok=True)
    manifest={};written=set()
    for name,action in [('idle',0),('walk',20),('run',100),('crouch',11)]:
        frames=[]
        for frame in anims.get(action,[]):
            key=tuple(frame['sprite']);record=sprites[key];filename=f'{key[0]}-{key[1]}.png'
            if key not in written:
                # SFF v1 defines palette index zero as transparent. PNG preserves that semantic.
                image=decode_pcx(record['image'])
                image.save(root/filename,transparency=0)
                written.add(key)
            frames.append({'file':filename,'axis':record['axis'],**frame})
        manifest[name]=frames
    (root/'animations.json').write_text(json.dumps(manifest,indent=2))
    print('Decoded',len(written),'original sprites and',len(manifest),'AIR actions')

if __name__=='__main__':convert(*sys.argv[1:4])
