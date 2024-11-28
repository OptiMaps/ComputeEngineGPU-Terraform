#!/bin/bash

# comm 명령어의 결과를 배열에 저장
zones=()
while read -r zone; do
  zones+=("$zone")
done < <(comm -12 <(gcloud compute machine-types list --filter="name=n1-standard-8" | grep asia | awk '{print $2}' | sort | uniq) <(gcloud compute accelerator-types list --filter="name=nvidia-tesla-t4" | grep asia | awk '{print $2}' | sort | uniq))

# 배열 출력 (디버깅용)
echo "사용 가능한 존 목록:"
for zone in "${zones[@]}"; do
  echo "$zone"
done

# 각 존(zone)에 대해 반복 작업 수행
for zone in "${zones[@]}"; do
  # 존(zone)에서 맨 뒤 두 글자를 제거하여 지역(region) 생성
  region=${zone::-2}
  
  echo "존(zone): $zone, 지역(region): $region 에서 make 명령어를 실행합니다..."
  
  # 환경 변수 설정
  export TF_VAR_region=$region
  export TF_VAR_zone=$zone
  
  # make 명령어 실행
  make
  
  # make 명령어의 종료 상태 확인
  if [ $? -ne 0 ]; then
    echo "존 $zone 에서 make 명령어가 실패했습니다. 10초 후에 make clean을 실행합니다..."
    sleep 30
    make clean
  else
    echo "존 $zone 에서 make 명령어가 성공적으로 완료되었습니다."
    # make 명령어가 성공하면 스크립트 종료
    exit 0
  fi
done

# 모든 존(zone)에서 make 명령어가 실패한 경우
echo "모든 존에서 make 명령어가 실패했습니다."
exit 1
