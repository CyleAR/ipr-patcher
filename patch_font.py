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
# 폴더면 그 폴더에, 파일이면 그 파일이 속한 폴더에 저장
out_dir = asset_path if os.path.isdir(asset_path) else os.path.dirname(asset_path)
if not out_dir:
    out_dir = "."

# env.save(out_dir)는 분할된 파일(split0, split1...)들을 
# 각각의 원래 이름대로 다시 쪼개서 저장해 줍니다.
env.save(out_dir)

print("Font replacement completed successfully.")
