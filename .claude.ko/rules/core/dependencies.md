# 의존성 관리

## 버전 고정

- 의존성: 정확한 버전만 (`package@1.2.3`)
- `^`, `~`, `latest`, 범위 금지
- 새 설치: 최신 안정 버전 확인 후 고정

## 패키지 매니저

- 워크스페이스 도구 컨벤션 존중
- lock 파일로 감지: pnpm-lock.yaml → pnpm, yarn.lock → yarn, package-lock.json → npm
- CI는 frozen 모드 사용 (`npm ci`, `pnpm install --frozen-lockfile`)

## 워크스페이스 도구

- justfile에 태스크가 있거나 반복 작업 추가 시 just 명령어 선호
- 일회성 작업은 직접 명령 실행 가능
