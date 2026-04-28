import sys

import UnityPy


asset_path = sys.argv[1]
custom_font_path = sys.argv[2]
target_font_name = sys.argv[3] if len(sys.argv) > 3 else "SourceSansPro-Regular"

print(f"[{custom_font_path}] Loading font file...")
with open(custom_font_path, "rb") as f:
    new_font_data = f.read()

print(f"[{asset_path}] Opening asset file...")
env = UnityPy.load(asset_path)
font_replaced = False

for obj in env.objects:
    if obj.type.name != "Font":
        continue

    data = obj.read()
    font_name = getattr(data, "m_Name", None)
    if not font_name:
        print("Warning: skipping Font object without a readable name.")
        continue

    print(f"Discovered font: {font_name}")
    if font_name != target_font_name:
        continue

    print(f"Target font '{font_name}' found. Replacing font data.")
    data.m_FontData = new_font_data
    data.save()
    font_replaced = True
    break

if not font_replaced:
    print(f"Warning: target font '{target_font_name}' was not found.")
    sys.exit(1)

print("Saving modified asset file...")
with open(asset_path, "wb") as f:
    f.write(env.file.save())

print("Font replacement completed.")
