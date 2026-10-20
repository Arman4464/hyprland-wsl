import struct
import zlib
import io
import shutil
import os
from PIL import Image

def pad_png(png_bytes, target_len):
    diff = target_len - len(png_bytes)
    if diff == 0:
        return png_bytes
    assert diff >= 12, f"Diff {diff} too small to insert tEXt chunk"
    iend_pos = png_bytes.rfind(b'IEND') - 4
    before = png_bytes[:iend_pos]
    after = png_bytes[iend_pos:]
    chunk_data = b'x' * (diff - 12)
    chunk_type = b'tEXt'
    crc = zlib.crc32(chunk_type + chunk_data) & 0xffffffff
    chunk = struct.pack('>I', len(chunk_data)) + chunk_type + chunk_data + struct.pack('>I', crc)
    padded = before + chunk + after
    assert len(padded) == target_len, f"Padded len {len(padded)} != {target_len}"
    return padded

def generate_embedded_ico(logo_png_path):
    orig = Image.open(logo_png_path).convert("RGBA")
    max_dim = max(orig.size)
    square = Image.new("RGBA", (max_dim, max_dim), (0, 0, 0, 0))
    square.paste(orig, ((max_dim - orig.width)//2, (max_dim - orig.height)//2), orig)

    slots = [
        (16, 1010, None),
        (24, 1102, None),
        (32, 1369, 213),
        (48, 1648, 222),
        (64, 1915, 230),
        (128, 2577, 142),
        (256, 3028, 24),
    ]

    imgs = []
    for sz, target_sz, max_c in slots:
        im = square.resize((sz, sz), Image.Resampling.LANCZOS)
        if max_c is None:
            buf = io.BytesIO()
            im.save(buf, format="PNG", optimize=True)
            raw = buf.getvalue()
        else:
            q = im.quantize(colors=max_c, method=Image.Quantize.FASTOCTREE)
            buf = io.BytesIO()
            q.save(buf, format="PNG", optimize=True)
            raw = buf.getvalue()
        padded = pad_png(raw, target_sz)
        imgs.append((sz, padded))

    header = struct.pack('<HHH', 0, 1, len(imgs))
    dir_entries = b''
    offset = 6 + len(imgs) * 16

    for sz, data in imgs:
        w = 0 if sz == 256 else sz
        h = 0 if sz == 256 else sz
        dir_entries += struct.pack('<BBBBHHII', w, h, 0, 0, 1, 32, len(data), offset)
        offset += len(data)

    full_ico = header + dir_entries + b''.join(d for _, d in imgs)
    assert len(full_ico) == 12767, f"full_ico length {len(full_ico)} != 12767"
    return full_ico

def build_pe_rsrc(exe_bytes, ico_path):
    with open(ico_path, "rb") as f:
        ico_bytes = f.read()

    # Parse ICO
    reserved, ico_type, num_images = struct.unpack("<HHH", ico_bytes[:6])
    images = []
    for i in range(num_images):
        w, h, colors, res, planes, bpp, size, offset = struct.unpack("<BBBBHHII", ico_bytes[6+i*16:6+(i+1)*16])
        img_data = ico_bytes[offset:offset+size]
        images.append({
            'id': i + 1,
            'width': w,
            'height': h,
            'colors': colors,
            'planes': planes,
            'bpp': bpp,
            'data': img_data
        })

    # Build RT_GROUP_ICON data (14 bytes per entry + 6 byte header)
    grp_header = struct.pack("<HHH", 0, 1, num_images)
    grp_entries = b""
    for img in images:
        grp_entries += struct.pack("<BBBBHHIH",
            img['width'], img['height'], img['colors'], 0,
            img['planes'], img['bpp'], len(img['data']), img['id']
        )
    grp_data = grp_header + grp_entries

    # PE Header parsing
    e_lfanew = struct.unpack("<I", exe_bytes[0x3c:0x40])[0]
    coff_offset = e_lfanew + 4
    num_sections, = struct.unpack("<H", exe_bytes[coff_offset+2:coff_offset+4])
    opt_hdr_size, = struct.unpack("<H", exe_bytes[coff_offset+16:coff_offset+18])
    opt_offset = coff_offset + 20

    section_alignment, = struct.unpack("<I", exe_bytes[opt_offset+32:opt_offset+36])
    file_alignment, = struct.unpack("<I", exe_bytes[opt_offset+36:opt_offset+40])
    size_of_image, = struct.unpack("<I", exe_bytes[opt_offset+56:opt_offset+60])
    size_of_headers, = struct.unpack("<I", exe_bytes[opt_offset+60:opt_offset+64])

    sec_headers_offset = opt_offset + opt_hdr_size

    # Find the last section
    last_sec_va = 0
    last_sec_vsize = 0
    last_sec_raw_offset = 0
    last_sec_raw_size = 0
    for i in range(num_sections):
        sec = exe_bytes[sec_headers_offset + i*40 : sec_headers_offset + (i+1)*40]
        vsize, va, rsize, roff = struct.unpack("<IIII", sec[8:24])
        if va >= last_sec_va:
            last_sec_va = va
            last_sec_vsize = vsize
            last_sec_raw_offset = roff
            last_sec_raw_size = rsize

    def align_up(x, a):
        return (x + a - 1) & ~(a - 1)

    new_sec_va = align_up(last_sec_va + last_sec_vsize, section_alignment)
    new_sec_raw_offset = align_up(last_sec_raw_offset + last_sec_raw_size, file_alignment)

    offset = 0
    root_dir_offset = 0
    root_size = 16 + 2 * 8 # 32 bytes
    offset += root_size

    rt_icon_dir_offset = offset
    rt_icon_dir_size = 16 + num_images * 8
    offset += rt_icon_dir_size

    rt_group_dir_offset = offset
    rt_group_dir_size = 16 + 1 * 8
    offset += rt_group_dir_size

    rt_icon_lang_offsets = []
    for _ in range(num_images):
        rt_icon_lang_offsets.append(offset)
        offset += 16 + 1 * 8

    rt_group_lang_offset = offset
    offset += 16 + 1 * 8

    rt_icon_data_entry_offsets = []
    for _ in range(num_images):
        rt_icon_data_entry_offsets.append(offset)
        offset += 16

    rt_group_data_entry_offset = offset
    offset += 16

    offset = align_up(offset, 8)
    rt_icon_raw_offsets = []
    for img in images:
        offset = align_up(offset, 4)
        rt_icon_raw_offsets.append(offset)
        offset += len(img['data'])

    offset = align_up(offset, 4)
    rt_group_raw_offset = offset
    offset += len(grp_data)

    total_rsrc_size = offset
    rsrc = bytearray(total_rsrc_size)

    def write_dir_header(buf, off, num_named, num_id):
        struct.pack_into("<IIHHHH", buf, off, 0, 0, 0, 0, num_named, num_id)

    def write_dir_entry(buf, off, id_or_name, sub_or_data, is_dir):
        flag = 0x80000000 if is_dir else 0
        struct.pack_into("<II", buf, off, id_or_name, sub_or_data | flag)

    # 1. Root Dir: 2 ID entries (3=RT_ICON, 14=RT_GROUP_ICON)
    write_dir_header(rsrc, root_dir_offset, 0, 2)
    write_dir_entry(rsrc, root_dir_offset + 16, 3, rt_icon_dir_offset, True)
    write_dir_entry(rsrc, root_dir_offset + 16 + 8, 14, rt_group_dir_offset, True)

    # 2. RT_ICON Dir
    write_dir_header(rsrc, rt_icon_dir_offset, 0, num_images)
    for i in range(num_images):
        write_dir_entry(rsrc, rt_icon_dir_offset + 16 + i * 8, images[i]['id'], rt_icon_lang_offsets[i], True)

    # 3. RT_GROUP_ICON Dir
    write_dir_header(rsrc, rt_group_dir_offset, 0, 1)
    write_dir_entry(rsrc, rt_group_dir_offset + 16, 1, rt_group_lang_offset, True)

    # 4. Lang dirs for RT_ICON: Lang ID = 0 (Neutral)
    for i in range(num_images):
        write_dir_header(rsrc, rt_icon_lang_offsets[i], 0, 1)
        write_dir_entry(rsrc, rt_icon_lang_offsets[i] + 16, 0, rt_icon_data_entry_offsets[i], False)

    # 5. Lang dir for RT_GROUP_ICON: Lang ID = 0
    write_dir_header(rsrc, rt_group_lang_offset, 0, 1)
    write_dir_entry(rsrc, rt_group_lang_offset + 16, 0, rt_group_data_entry_offset, False)

    # 6. Data Entries:
    for i in range(num_images):
        rva = new_sec_va + rt_icon_raw_offsets[i]
        sz = len(images[i]['data'])
        struct.pack_into("<IIII", rsrc, rt_icon_data_entry_offsets[i], rva, sz, 0, 0)

    rva = new_sec_va + rt_group_raw_offset
    sz = len(grp_data)
    struct.pack_into("<IIII", rsrc, rt_group_data_entry_offset, rva, sz, 0, 0)

    # 7. Copy Raw Data:
    for i in range(num_images):
        off = rt_icon_raw_offsets[i]
        rsrc[off : off + len(images[i]['data'])] = images[i]['data']

    rsrc[rt_group_raw_offset : rt_group_raw_offset + len(grp_data)] = grp_data

    raw_rsrc_size = align_up(total_rsrc_size, file_alignment)
    virt_rsrc_size = align_up(total_rsrc_size, section_alignment)
    rsrc += b'\x00' * (raw_rsrc_size - len(rsrc))

    if len(exe_bytes) < new_sec_raw_offset:
        exe_bytes += b'\x00' * (new_sec_raw_offset - len(exe_bytes))

    final_exe = bytearray(exe_bytes[:new_sec_raw_offset] + rsrc)

    sec_name = b".rsrc\x00\x00\x00"
    sec_header = struct.pack("<8sIIIIIIHHI",
        sec_name,
        total_rsrc_size,
        new_sec_va,
        raw_rsrc_size,
        new_sec_raw_offset,
        0, 0, 0, 0,
        0x40000040 # READ | INITIALIZED_DATA
    )

    new_sec_hdr_offset = sec_headers_offset + num_sections * 40
    assert new_sec_hdr_offset + 40 <= size_of_headers, "Not enough space for section header"
    final_exe[new_sec_hdr_offset : new_sec_hdr_offset + 40] = sec_header

    # Update COFF header: NumberOfSections += 1
    struct.pack_into("<H", final_exe, coff_offset + 2, num_sections + 1)

    # Update Optional Header:
    new_size_of_image = new_sec_va + virt_rsrc_size
    struct.pack_into("<I", final_exe, opt_offset + 56, new_size_of_image)

    # Data Directory index 2: Resource Directory
    rsrc_dir_entry_offset = opt_offset + 128
    struct.pack_into("<II", final_exe, rsrc_dir_entry_offset, new_sec_va, total_rsrc_size)

    # Clear Export Directory back to 0
    struct.pack_into("<II", final_exe, opt_offset + 112, 0, 0)

    return final_exe

def build_viewer(bak_path, logo_png, ico_path, output_paths):
    with open(bak_path, "rb") as f:
        exe_bytes = f.read()

    # 1. Generate crisp embedded ICO buffer (12767 bytes)
    embedded_ico = generate_embedded_ico(logo_png)

    # 2. Append PE .rsrc section
    patched_exe = build_pe_rsrc(exe_bytes, ico_path)

    # 3. Inject crisp embedded ICO buffer into both locations
    patched_exe[0xaa110 : 0xaa110 + 12767] = embedded_ico
    patched_exe[0xb0a29 : 0xb0a29 + 12767] = embedded_ico

    # 4. Patch opcode at 0x32b24: 7e 26 (jle +0x26) -> 7c 26 (jl +0x26)
    # This prevents SM_CXSMICON=16 from jumping to 16x16 icon, selecting crisp 24x24 instead!
    assert patched_exe[0x32b24 : 0x32b26] == b'\x7e\x26', f"Unexpected bytes at 0x32b24: {patched_exe[0x32b24:0x32b26].hex()}"
    patched_exe[0x32b24] = 0x7c

    # 5. Patch opcodes at 0x32bec: mov %eax, [rsp+28]; mov %eax, [rsp+20] -> mov %edx, [rsp+28]; mov %edx, [rsp+20]
    # Passes native chosen subicon size (%edx = 24) to CreateIconFromResourceEx instead of 16
    assert patched_exe[0x32bec : 0x32bf4] == b'\x89\x44\x24\x28\x89\x44\x24\x20'
    patched_exe[0x32bec : 0x32bf4] = b'\x89\x54\x24\x28\x89\x54\x24\x20'

    # 6. Patch opcodes at 0x32ac3: mov %eax, [rsp+28]; mov %eax, [rsp+20] -> mov %edx, [rsp+28]; mov %edx, [rsp+20]
    # Passes native chosen subicon size (%edx = 32) to CreateIconFromResourceEx for hIcon
    assert patched_exe[0x32ac3 : 0x32acb] == b'\x89\x44\x24\x28\x89\x44\x24\x20'
    patched_exe[0x32ac3 : 0x32acb] = b'\x89\x54\x24\x28\x89\x54\x24\x20'

    # Write outputs
    for out_p in output_paths:
        with open(out_p, "wb") as f_out:
            f_out.write(patched_exe)
        print(f"Wrote {len(patched_exe)} bytes to {out_p}")

if __name__ == "__main__":
    bak = r"D:\RangoWorkspace\bin\hyprland-viewer.exe.bak"
    logo = r"assets\hyprland_logo.png"
    ico = r"assets\hyprland_win11.ico"
    dests = [
        r"D:\RangoWorkspace\bin\hyprland-viewer.exe",
        r"D:\RangoWorkspace\hyprland-wsl\bin\hyprland-viewer.exe",
        r"C:\Users\rango\.local\bin\hyprland-viewer.exe"
    ]
    build_viewer(bak, logo, ico, dests)
    print("All viewers successfully updated with crisp icons and patched sizing logic!")
