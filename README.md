# ComputeEngineGPU-Terraform

## 사용방법
1. `src/s3_init` 디렉토리로 이동한다.
```bash
cd src/s3_init
```
2. tfstate를 원격으로 관리할 s3와 dynamoDB를 생성한다.
```bash
terraform init
terraform plan
terraform apply
```
3. `src` 디렉토리로 이동한다.
```bash
cd ..
```
4. instance를 생성한다.
```bash
terraform init
terraform plan
terraform apply
```