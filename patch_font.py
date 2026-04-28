import UnityPy
import sys
import os

# 깃액션에서 실행할 때 매개변수로 경로를 전달받습니다.
asset_path = sys.argv[1]  # 예: base_dir/assets/bin/Data/sharedassets0.assets
custom_font_path = sys.argv[2]  # 예: pretendardJP-SemiBold.otf

print(f"[{custom_font_path}] 폰트를 로드합니다...")
with open(custom_font_path, "rb") as f:
    new_font_data = f.read()

print(f"[{asset_path}] 애셋 파일을 엽니다...")
env = UnityPy.load(asset_path)
font_replaced = False

# 애셋 내부를 순회하며 타겟 폰트 찾기
for obj in env.objects:
    if obj.type.name == "Font":
        data = obj.read()
        if data.name == "SourceSansPro-Regular":
            print(f"타겟 폰트 '{data.name}' 발견! 데이터를 덮어씌웁니다.")
            data.m_FontData = new_font_data
            data.save() # 수정 사항을 객체에 저장
            font_replaced = True

if not font_replaced:
    print("경고: 'SourceSansPro-Regular' 폰트를 찾지 못했습니다.")

# 변경된 애셋 파일 전체를 하나로 묶어서 다시 저장
print("수정된 애셋 파일을 저장합니다...")
with open(asset_path, "wb") as f:
    f.write(env.file.save())

print("폰트 교체 작업이 완료되었습니다!")