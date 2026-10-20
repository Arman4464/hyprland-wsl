import struct
from PIL import Image
import io

def generate_multi_res_ico(logo_png_path, out_ico_path):
    orig = Image.open(logo_png_path).convert("RGBA")
    
    # Square the canvas if not square
    max_dim = max(orig.size)
    square_img = Image.new("RGBA", (max_dim, max_dim), (0, 0, 0, 0))
    x_off = (max_dim - orig.width) // 2
    y_off = (max_dim - orig.height) // 2
    square_img.paste(orig, (x_off, y_off), orig)

    sizes = [16, 20, 24, 30, 32, 36, 40, 48, 64, 72, 96, 128, 256]
    # For Windows 11 taskbar icons, common sizes are: 16, 24, 32, 48, 64, 128, 256
    target_sizes = [16, 24, 32, 48, 64, 128, 256]

    images_data = []

    for sz in target_sizes:
        res = square_img.resize((sz, sz), Image.Resampling.LANCZOS)
        
        if sz <= 128:
            # 32-bit DIB
            w, h = sz, sz
            and_pitch = (w + 31) // 32 * 4
            and_mask_size = and_pitch * h
            xor_size = w * h * 4
            biSizeImage = xor_size + and_mask_size
            header = struct.pack("<IIIHHIIIIII",
                40, w, h * 2, 1, 32, 0, biSizeImage, 0, 0, 0, 0
            )
            pixels = bytearray(xor_size)
            and_mask = bytearray(and_mask_size)
            for y in range(h):
                src_y = h - 1 - y
                for x in range(w):
                    r, g, b, a = res.getpixel((x, src_y))
                    off = (y * w + x) * 4
                    pixels[off] = b
                    pixels[off+1] = g
                    pixels[off+2] = r
                    pixels[off+3] = a
                    if a < 128:
                        and_mask[y * and_pitch + (x // 8)] |= (1 << (7 - (x % 8)))
            raw = header + pixels + and_mask
            bpp = 32
        else:
            # 256x256 as high-quality PNG
            buf = io.BytesIO()
            res.save(buf, format="PNG", optimize=True)
            raw = buf.getvalue()
            bpp = 32

        images_data.append({
            'size': sz,
            'raw': raw,
            'bpp': bpp
        })

    # Assemble ICO file:
    header = struct.pack("<HHH", 0, 1, len(images_data))
    dir_entries = b""
    offset = 6 + len(images_data) * 16

    for item in images_data:
        sz = item['size']
        w = 0 if sz == 256 else sz
        h = 0 if sz == 256 else sz
        raw_len = len(item['raw'])
        dir_entries += struct.pack("<BBBBHHII",
            w, h, 0, 0, 1, item['bpp'], raw_len, offset
        )
        offset += raw_len

    full_ico = header + dir_entries + b"".join(item['raw'] for item in images_data)

    with open(out_ico_path, "wb") as f:
        f.write(full_ico)
    print(f"Generated {out_ico_path}: {len(full_ico)} bytes with {len(images_data)} images")
    return images_data

if __name__ == "__main__":
    generate_multi_res_ico(r"assets\hyprland_logo.png", r"assets\hyprland_win11.ico")
