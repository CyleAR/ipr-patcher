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

print(f"[{asset_path}] Opening asset file...")
env = UnityPy.load(asset_path)
font_replaced = False

# 디버깅: 내부 파일 구성 확인
print(f"DEBUG: Internal files in environment: {list(env.files.keys())}")

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

print("Saving modified asset file...")
out_dir = os.path.dirname(asset_path) or "."
print(f"DEBUG: Target out_dir is '{out_dir}'")

# 방법 1: env.save() 시도 (강제로 keyword 인자 사용)
try:
    env.save(out_path = out_dir)
    print("Saved using env.save(out_path=out_dir)")
except Exception as e:
    print(f"env.save failed: {e}. Trying manual save...")
    # 방법 2: 수동 저장 (env.save가 실패할 경우의 대비책)
    for fname, file in env.files.items():
        # 파일명이 경로를 포함하고 있을 수 있으므로 basename만 취함
        clean_name = os.path.basename(fname)
        save_path = os.path.join(out_dir, clean_name)
        with open(save_path, "wb") as f:
            f.write(file.save())
        print(f"Manually saved: {save_path}")

print("Font replacement completed.")
