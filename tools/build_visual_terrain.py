from pathlib import Path
import cv2
import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "assets" / "map" / "desert_world_v48_2c.png"
DST = ROOT / "assets" / "map" / "desert_world_rebuild.webp"

src = np.array(Image.open(SRC).convert("RGB"), dtype=np.float32) / 255.0
h, w = src.shape[:2]
yy, xx = np.mgrid[0:h, 0:w].astype(np.float32)

# Keep terrain relief/roads, remove the old large-scale color patches.
low = cv2.GaussianBlur(src, (0, 0), 95)
detail = np.clip(src - low, -0.15, 0.15)

gray = src.mean(axis=2)
large_relief = cv2.GaussianBlur(gray, (0, 0), 190)
large_relief -= large_relief.mean()

base = np.ones_like(src) * np.array([0.82, 0.60, 0.36], dtype=np.float32)
base += large_relief[:, :, None] * 0.07
base *= (0.985 + 0.025 * (1.0 - yy / float(h)))[:, :, None]

# The former Canyon/graveyard extensions contained obvious rectangular/scalloped seams.
# Rebuild their local terrain from clean central desert detail, with very wide blends.
right_src = detail[:, 720:1220, :]
right_full = cv2.resize(right_src, (w - 950, h), interpolation=cv2.INTER_CUBIC)
detail_right = detail.copy()
detail_right[:, 950:, :] = right_full
blend_x = np.clip((xx - 900.0) / 420.0, 0.0, 1.0)
blend_x = cv2.GaussianBlur(blend_x, (0, 0), 22)
detail_stage = detail * (1.0 - blend_x[:, :, None]) + detail_right * blend_x[:, :, None]

bottom_src = detail_stage[520:930, :, :]
bottom_full = cv2.resize(bottom_src, (w, h - 780), interpolation=cv2.INTER_CUBIC)
detail_bottom = detail_stage.copy()
detail_bottom[780:, :, :] = bottom_full
blend_y = np.clip((yy - 740.0) / 380.0, 0.0, 1.0)
blend_y = cv2.GaussianBlur(blend_y, (0, 0), 24)
detail_stage = detail_stage * (1.0 - blend_y[:, :, None]) + detail_bottom * blend_y[:, :, None]

out = np.clip(base + detail_stage * 0.90, 0.0, 1.0)

# Re-establish traversable roads in the rebuilt east/south terrain.
road_mask = np.zeros((h, w), dtype=np.uint8)
paths = [
    [(1050, 520), (1250, 510), (1480, 520), (1700, 535), (1970, 555)],
    [(1450, 520), (1540, 650), (1660, 760)],
    [(360, 760), (330, 900), (370, 1040)],
    [(760, 750), (740, 900), (760, 1040)],
    [(1210, 720), (1170, 870), (1220, 1010), (1400, 1080)],
    [(280, 1080), (450, 1030), (680, 1045), (900, 1100), (1120, 1180),
     (1360, 1270), (1580, 1380), (1710, 1450), (1500, 1490), (1180, 1450),
     (880, 1410), (610, 1380), (400, 1320), (270, 1210), (280, 1080)],
]
for pts in paths:
    poly = np.array(pts, dtype=np.int32).reshape((-1, 1, 2))
    cv2.polylines(road_mask, [poly], False, 255, 34, lineType=cv2.LINE_AA)

road = cv2.GaussianBlur(road_mask.astype(np.float32) / 255.0, (0, 0), 6)
road_tint = np.array([0.66, 0.50, 0.35], dtype=np.float32)
road_surface = out * 0.80 + road_tint * 0.20
alpha = road * 0.34
out = out * (1.0 - alpha[:, :, None]) + road_surface * alpha[:, :, None]

# Native world resolution: runtime scale stays 1.0.
u8 = (np.clip(out, 0.0, 1.0) * 255.0).astype(np.uint8)
native = cv2.resize(u8, (4096, 3072), interpolation=cv2.INTER_LANCZOS4)

# Mild native-resolution crispness without haloing.
soft = cv2.GaussianBlur(native, (0, 0), 0.9)
native = cv2.addWeighted(native, 1.14, soft, -0.14, 0)

Image.fromarray(native).save(DST, "WEBP", quality=96, method=6)
check = Image.open(DST)
assert check.size == (4096, 3072)
print(f"wrote {DST} — {DST.stat().st_size} bytes")
