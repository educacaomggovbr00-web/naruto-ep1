"""Index the generated sprite sheet; preserve PNG bytes and alpha unchanged."""
import hashlib,json
from pathlib import Path
from PIL import Image
import numpy as np
ROOT=Path(__file__).resolve().parents[1]/'assets'/'characters'
def main():
    source=ROOT/'citizens-generated.png'
    image=Image.open(source).convert('RGBA'); data=np.array(image)
    width,height=image.size
    def edges(projection,extent):
        active=projection>12; spans=[]; start=None
        for i,value in enumerate(active):
            if value and start is None: start=i
            if start is not None and (not value or i==len(active)-1):
                if i-start>3: spans.append((start,i))
                start=None
        assert len(spans)==4,spans
        return [0]+[(spans[i][1]+spans[i+1][0])//2 for i in range(3)]+[extent]
    # Generated sheets can have unequal padding despite a requested grid.
    # Infer gutters from the original alpha; never cut a boot at a nominal cell.
    x_edges=edges((data[:,:,3]>100).sum(axis=0),width)
    y_edges=edges((data[:,:,3]>100).sum(axis=1),height)
    actors={}
    for row,(name,world_height) in enumerate([('Comerciante',78),('Moradora',76),('Mensageiro',76),('Criança',62)]):
        frames=[]; heights=[]
        for col in range(4):
            x,y=x_edges[col],y_edges[row]
            cw,ch=x_edges[col+1]-x,y_edges[row+1]-y
            alpha=data[y:y+ch,x:x+cw,3]>100
            yy,xx=np.where(alpha)
            assert len(xx)>1000
            bottom=int(yy.max());top=int(yy.min());h=bottom-top+1
            torso=alpha[max(top,bottom-int(h*.46)):bottom-int(h*.25)]
            center=int(round(float(np.median(np.where(torso)[1]))))
            frames.append({'rect':[x,y,cw,ch],'origin':[center,bottom+1]})
            heights.append(h)
            if col==0:
                head_x=int(xx.min()+0.25*(xx.max()-xx.min()))
                portrait=[x+head_x,y+top,int((xx.max()-xx.min())*.70),int(h*.38)]
        actors[name]={'frames':frames,'scale':world_height/max(heights),'portrait':portrait,'height':world_height}
    assert np.min(data[:,:,3])==0 and np.max(data[:,:,3])==255
    output={'texture':'citizens-generated.png','sha256':hashlib.sha256(source.read_bytes()).hexdigest(),'actors':actors,'generated':True,'layout':'four rows, four right-facing walk poses per row; left is mirrored'}
    (ROOT/'citizens.json').write_text(json.dumps(output,ensure_ascii=False,indent=2)+'\n')
    print(f'PASS: indexed 16 original generated poses in {width}x{height} transparent atlas; PNG bytes unchanged')
if __name__=='__main__':main()
