import sys
import os
import UnityPy

# 인자 설정
asset_path = sys.argv[1]
custom_font_path = sys.argv[2]
target_font_name = sys.argv[3] if len(sys.argv) > 3 else "SourceSansPro-Regular"

# 1. 커스텀 폰트 로드
print(f"[{custom_font_path}] Loading font file...")
with open(custom_font_path, "rb") as f:
    new_font_data = f.read()

# 2. 에셋 파일 로드
print(f"[{asset_path}] Opening asset file...")
env = UnityPy.load(asset_path)
font_replaced = False

# 3. 폰트 교체 작업
for obj in env.objects:
    if obj.type.name != "Font":
        continue

    data = obj.read()
    font_name = getattr(data, "m_Name", None)
    if not font_name:
        continue

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

# 4. 저장 작업 (핵심 수정 부분)
print("Saving modified asset file...")
out_dir = os.path.dirname(asset_path)
if not out_dir:
    out_dir = "."

# env.save(out_dir)는 파일 안에 든 모든 데이터(sharedassets0.assets 등)를 
# 지정된 폴더에 원래 파일명대로 안전하게 저장합니다.
env.save(out_dir)

print("Font replacement completed.")
