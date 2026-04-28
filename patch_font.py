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
out_dir = asset_path if os.path.isdir(asset_path) else os.path.dirname(asset_path)
if not out_dir:
    out_dir = "."

# env.save() 대신 우리가 수정한 파일만 골라서 저장합니다.
for fname, file in env.files.items():
    # 타겟 파일(sharedassets0.assets)이 포함된 경우만 처리
    if "sharedassets0.assets" not in fname:
        continue
        
    if not hasattr(file, "save"):
        continue
        
    clean_name = os.path.basename(fname)
    save_path = os.path.join(out_dir, clean_name)
    
    try:
        with open(save_path, "wb") as f:
            f.write(file.save())
        print(f"Successfully saved patched asset: {save_path}")

        # 조각 파일들이 있었다면, 새로 합쳐서 저장한 파일과 충돌하지 않게 지워줍니다.
        for i in range(100): # .split0 ~ .split99
            split_file = f"{save_path}.split{i}"
            if os.path.exists(split_file):
                os.remove(split_file)
                print(f"Removed old split file: {split_file}")
    except Exception as e:
        print(f"Error saving {clean_name}: {e}")

print("Font replacement completed successfully.")
