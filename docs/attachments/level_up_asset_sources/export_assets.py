from pathlib import Path
from PIL import Image, ImageDraw, ImageFont
import json
ROOT=Path(__file__).resolve().parents[3]
OUT=ROOT/'stage/level_up/assets'
SOURCES=ROOT/'docs/attachments/level_up_asset_sources'
ims={name:Image.open(SOURCES/(name+'.png')).convert('RGBA') for name in ['skin','clean_skin','components','background']}
for im in ims.values():
 assert im.size==(1672,941)
manifest={'reference_size':[1672,941],'display_scale':1,'background':'background.png','assets':{},'layout':{'column_x':[64,592,1120],'card_y':[320,480,640],'talent_y':[480,588,696],'confirm_y':804,'active_tray_y':232},'notes':['Draw at exported size: no runtime scaling or NinePatchRect stretching.','Source elements were generated at reference scale, then cropped and normalized offline to the exact exported sizes. No runtime scaling is needed.','All words, numbers, portraits and gameplay icons are separate runtime content.']}

def export(name,source,box,size,margins=None,inner=None):
 im=ims[source].crop(box)
 # Remove only nearly invisible alpha noise before finding the visible crop.
 alpha=im.getchannel('A').point(lambda a:0 if a<8 else a)
 im.putalpha(alpha)
 bbox=alpha.point(lambda a:255 if a>=32 else 0).getbbox()
 assert bbox, name
 # Retain a small transparent antialias/glow allowance inside the source cell.
 bbox=(max(0,bbox[0]-2),max(0,bbox[1]-2),min(im.width,bbox[2]+2),min(im.height,bbox[3]+2))
 im=im.crop(bbox)
 source_size=im.size
 method='native crop and transparent padding'
 if margins:
  im=im.resize(size,Image.Resampling.LANCZOS);method='offline normalization to final pixel size (Lanczos)'
 elif im.width>size[0] or im.height>size[1]:
  ratio=min(size[0]/im.width,size[1]/im.height)
  im=im.resize((round(im.width*ratio),round(im.height*ratio)),Image.Resampling.LANCZOS)
  method='uniform offline resample to final size'
 if im.size!=size:
  canvas=Image.new('RGBA',size)
  canvas.paste(im,((size[0]-im.width)//2,(size[1]-im.height)//2)); im=canvas
 im.save(OUT/(name+'.png'))
 manifest['assets'][name]={'file':name+'.png','size':list(size),'source':source+'.png','source_region':list(box),'trimmed_source_size':list(source_size),'processing':method}
 if inner:manifest['assets'][name]['content_rect']=inner
 return im

ims['background'].convert('RGB').save(OUT/'background.png')
manifest['assets']['background']={'file':'background.png','size':[1672,941],'processing':'native size; no resampling'}
# Blank reusable cards, all states with identical exported bounds.
export('offer_normal','clean_skin',(588,318,1088,476),(512,152),(16,56,16,16),[20,14,472,120])
export('offer_focused','clean_skin',(49,318,583,476),(512,152),(16,56,16,16),[20,14,472,120])
export('offer_selected','clean_skin',(1093,316,1625,476),(512,152),(16,56,16,16),[20,14,472,120])
export('talent_normal','clean_skin',(54,480,580,583),(512,100),(16,16,16,16),[18,12,476,76])
export('talent_selected','clean_skin',(53,586,582,691),(512,100),(16,16,16,16),[18,12,476,76])
# The tray remains completely blank; skill slots are separate sprites.
export('active_tray','clean_skin',(62,225,581,319),(512,88),(16,16,16,16),[20,16,472,56])
export('button_enabled','skin',(166,794,489,867),(320,64),(40,16,40,16),[40,12,240,40])
export('button_normal','skin',(1183,794,1511,867),(320,64),(40,16,40,16),[40,12,240,40])
export('button_disabled','skin',(674,794,1000,867),(320,64),(40,16,40,16),[40,12,240,40])
export('button_compact','skin',(1386,888,1630,941),(240,48),(24,12,24,12),[24,8,192,32])
export('button_back','components',(51,240,213,325),(104,40),(12,10,12,10),[12,7,80,26])
export('portrait_frame','skin',(78,70,215,216),(136,148),None,[16,14,104,120])
export('skill_frame','skin',(215,100,272,158),(56,56),(7,7,7,7),[7,7,42,42])
export('talent_socket','skin',(270,101,298,130),(24,24),(5,5,5,5),[5,5,14,14])
export('offer_icon_frame','components',(519,386,654,533),(88,88),(10,10,10,10),[10,10,68,68])
export('talent_icon_frame','skin',(215,100,272,158),(52,52),(7,7,7,7),[7,7,38,38])
export('skill_slot_empty','components',(415,610,511,710),(56,56),(10,10,10,10),[10,10,36,36])
export('talent_socket_empty','components',(761,630,819,685),(24,24),(6,6,6,6),[6,6,12,12])
export('check_selected','components',(872,630,940,690),(24,24))
export('check_muted','components',(944,630,1009,690),(24,24))
# Additional transparent frame overlay for chosen skills is the same quiet rim;
# card selection supplies the bright state rather than more competing gold.
(OUT/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
# Native-size asset contact sheet: only text labels are drawn, artwork stays 1:1.
font=ImageFont.truetype('/System/Library/Fonts/Supplemental/Arial.ttf',16)
contact=Image.new('RGB',(1672,941),(35,29,25));d=ImageDraw.Draw(contact)
placements=[('offer_normal',24,48),('offer_focused',580,48),('offer_selected',1136,48),('talent_normal',24,248),('talent_selected',580,248),('active_tray',1136,248),('button_normal',24,416),('button_enabled',410,416),('button_disabled',796,416),('button_back',1184,416),('button_compact',24,548),('portrait_frame',346,548),('skill_frame',560,548),('skill_slot_empty',704,548),('offer_icon_frame',896,548),('talent_icon_frame',1104,548),('talent_socket',24,790),('talent_socket_empty',264,790),('check_selected',560,790),('check_muted',800,790)]
for n,x,y in placements:
 im=Image.open(OUT/(n+'.png')).convert('RGBA');contact.paste(im,(x,y),im)
 d.text((x,y-36),n,font=font,fill=(234,215,178));d.text((x,y-18),f'{im.width}×{im.height}',font=font,fill=(175,158,131))
d.text((24,884),'Native-size exports • transparent PNGs • no baked text or gameplay icons',font=font,fill=(234,215,178))
contact.save(ROOT/'docs/attachments/level_up_assets_contact_sheet.png')
# Representative native-scale composition, independent of game implementation.
preview=ims['background'].copy()
for col,x in enumerate([64,592,1120]):
 def place(n,xx,yy):
  im=Image.open(OUT/(n+'.png')).convert('RGBA');preview.alpha_composite(im,(xx,yy))
 place('portrait_frame',x+12,72)
 for row in range(2):
  for j in range(4):
   xx=x+164+j*84; yy=100+row*64
   place('skill_frame',xx,yy)
   place('talent_socket',xx+58,yy+2);place('talent_socket',xx+58,yy+29)
 place('active_tray',x,232)
 for j in range(5):
  xx=x+22+j*96
  place('skill_slot_empty',xx,250)
  place('talent_socket',xx+58,251);place('talent_socket',xx+58,279)
 place('offer_focused' if col==0 else 'offer_normal',x,324)
 if col==0:
  for i,y in enumerate([484,592,700]):
   place('talent_selected' if i==1 else 'talent_normal',x,y)
   place('talent_icon_frame',x+20,y+24)
  place('check_selected',x+466,630)
 else:
  place('offer_normal',x,484);place('offer_normal',x,644)
 place('button_enabled' if col==0 else 'button_disabled',x+96,808)
place('button_compact',1384,892)
preview.convert('RGB').save(ROOT/'docs/attachments/level_up_assets_native_preview.png')
# Deterministic export verification.
for name,record in manifest['assets'].items():
 im=Image.open(OUT/record['file'])
 assert list(im.size)==record['size'],name
 if name!='background':
  assert im.mode=='RGBA' and im.getchannel('A').getextrema()[0]==0,name
for n in ['portrait_frame','skill_frame','talent_socket','offer_icon_frame','talent_icon_frame']:
 im=Image.open(OUT/(n+'.png'));assert im.getpixel((im.width//2,im.height//2))[3]<16,(n,'center not transparent')
print(f'Exported and checked {len(manifest["assets"])} native-size PNG assets.')
print('All exports are final-size textures; no runtime resizing required.')
