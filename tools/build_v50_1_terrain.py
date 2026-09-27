from pathlib import Path
from PIL import Image, ImageEnhance, ImageFilter, ImageOps

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "assets" / "map" / "desert_world_v48_2c.png"
DST = ROOT / "assets" / "map" / "desert_world_v50_1.webp"

im = Image.open(SRC).convert("RGB")

# Native world resolution: no runtime x2/x4 interpolation.
im = im.resize((4096, 3072), Image.Resampling.LANCZOS)

# Recover small terrain detail without creating hard halos.
im = im.filter(ImageFilter.UnsharpMask(radius=1.15, percent=128, threshold=3))
im = ImageEnhance.Contrast(im).enhance(1.055)
im = ImageEnhance.Color(im).enhance(0.93)
im = ImageEnhance.Brightness(im).enhance(0.985)

# Subtle deterministic sand microtexture. Kept extremely light so roads remain readable.
noise = Image.effect_noise(im.size, 7.5).convert("L")
noise = ImageOps.colorize(noise, black="#8e623a", white="#e9bd78")
im = Image.blend(im, noise, 0.035)
im = im.filter(ImageFilter.UnsharpMask(radius=0.72, percent=112, threshold=2))

DST.parent.mkdir(parents=True, exist_ok=True)
im.save(DST, "WEBP", quality=95, method=6)
print(f"wrote {DST} {DST.stat().st_size} bytes")
