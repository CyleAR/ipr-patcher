import sys
import os
import UnityPy

# 인자 설정
asset_path = sys.argv[1]
custom_font_path = sys.argv[2]
target_font_name = sys.argv[3] if len(sys.argv) > 3 else "SourceSansPro-Regular"

print(f"[{custom_font_path}] Loading font file...")
with open(custom_font_path, "rb") as f:
    new_font_data = f.read()

# 2. 에셋 로드 (파일 또는 폴더)
print(f"[{asset_path}] Opening assets...")
env = UnityPy.load(asset_path)
font_replaced = False

# 3. 폰트 교체 작업
for obj in env.objects:
    if obj.type.name != "Font":
        continue

    data = obj.read()
    font_name = getattr(data, "m_Name", None)
    if not font_name or font_name != target_font_name:
        continue

    print(f"Target font '{font_name}' found. Replacing font data.")
    data.m_FontData = new_font_data
    data.save()
    font_replaced = True
    break

if not font_replaced:
    print(f"Warning: target font '{target_font_name}' was not found.")
    sys.exit(1)

# 4. 저장 작업
print("Saving modified assets...")
out_dir = os.path.dirname(asset_path) or "."

for fname, file in env.files.items():
    # 우리가 수정하려고 했던 sharedassets0.assets와 관련된 것만 저장합니다.
    if "sharedassets0.assets" not in fname:
        continue
        
    save_path = os.path.join(out_dir, "sharedassets0.assets")
    
    with open(save_path, "wb") as f:
        f.write(file.save())
    print(f"Successfully saved patched asset: {save_path}")

    # 기존 조각 파일들(.split0, .split1...) 삭제
    for i in range(100):
        split_file = f"{save_path}.split{i}"
        if os.path.exists(split_file):
            os.remove(split_file)
            print(f"Removed old split file: {split_file}")
    break 

print("Font replacement completed successfully.")
