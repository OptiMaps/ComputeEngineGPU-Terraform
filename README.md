# ComputeEngineGPU-Terraform

## 사용방법
### 처음 사용하는 경우
```bash
make init
```
### 나중에 사용하는 경우
```bash
make
```
### gcp 인스턴스만 삭제하고 싶은 경우
```bash
make clean
```

### aws s3까지 삭제하고 싶은 경우 (완전 초기화)
```bash
make fclean
```

### 꿀팁
사용가능한 딥러닝 이미지를 보고 싶은 경우
```bash
gcloud compute images list --project deeplearning-platform-release | grep cu123
```

사용가능한 region을 보고 싶은 경우
```bash
gcloud compute machine-types list --filter="name=n1-standard-16"
```

사용가능한 gpu를 보고 싶은 경우
```bash
gcloud compute accelerator-types list --filter="nvidia-tesla-t4"
```

교집합
```bash
comm -12 <(gcloud compute machine-types list --filter="name=n1-standard-8" | grep asia | awk '{print $2}' | sort | uniq) <(gcloud compute accelerator-types list --filter="name=nvidia-tesla-t4" | grep asia | awk '{print $2}' | sort | uniq)
```