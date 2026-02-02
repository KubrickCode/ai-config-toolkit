# 일반 규칙

## 의존성

AI는 기본적으로 버전 범위를 사용하여 재현 불가능한 빌드를 유발함.

- 정확한 버전만 - 버전 범위 금지
  - 예: `lodash@4.17.21`, `github.com/pkg/errors v0.9.1`
  - 금지: `^1.0.0`, `~1.0.0`, `>=1.0.0`, `latest` 등
- lock 파일로 패키지 매니저 감지
- CI는 frozen 모드 사용 (예: `--frozen-lockfile`)
- 태스크 러너 명령어 (just, make) 있으면 우선 사용

## 네이밍

AI는 코드가 실제로 무엇을 하는지 모호하게 만드는 제네릭 동사를 남발함.

- 목적이 명확하면서 간결하게
- 업계 표준 외 약어 금지 (id, api, db, err 등은 허용)
- 부모 스코프의 컨텍스트 반복 금지
- Boolean: `is`, `has`, `should` 접두사
- 함수명: 동사 또는 동사+명사 형태
- 금지 동사: `process`, `handle`, `manage`, `do`, `execute` 등
  - 도메인 특화 동사 사용: `validate`, `transform`, `parse`, `dispatch`, `route` 등
  - 예외: 이벤트 핸들러 (`onClick`, `handleSubmit`)
- 컬렉션: `users` (배열/슬라이스), `userList` (래핑), `userSet` (특정 구조)
- 필드 순서: 기본적으로 알파벳순

## 에러 처리

AI는 에러를 조용히 삼키는 catch-all 핸들러를 생성하는 경향이 있음.

- 의미 있는 응답이 가능한 곳에서 에러 처리
- 에러 메시지: 로그에는 기술적 세부사항, 사용자에게는 행동 가능한 안내
- 예상된 에러와 예상치 못한 에러 구분
- 에러 전파 시 컨텍스트 추가
- 에러를 조용히 무시하지 않기
  - 나쁨: `catch(e) {}`, `if err != nil { return nil }` 등
  - 좋음: 컨텍스트와 함께 로그 + 전파 또는 fallback 복구
- 도메인 특화 실패에는 커스텀 에러 타입 생성
- 비동기 에러 항상 처리 (Promise rejection 등)

## 주석

WHAT을 설명하는 주석은 금방 낡음; 코드 자체가 문서가 되어야 함.

- 작성할 것:
  - WHY: 비즈니스 규칙, 외부 제약, 반직관적 결정
  - Constraints: `// Constraint: Must complete within 100ms`
  - Intent: `// Goal: Minimize database round-trips`
  - Side Effects: `// Side effect: Sends email notification`
  - Anti-patterns: `// Intentionally sequential - parallel breaks idempotency`
- 금지: WHAT 설명, 코드 흐름 서술, 섹션 구분선, 주석 처리된 코드 등
- WHAT 주석이 필요하면 코드를 고칠 것 (이름 변경, 함수 추출)

## 코드 구조

- 하나의 함수, 하나의 책임
  - 함수명에 "and/or" → 별도 함수로 분리
  - if 분기마다 테스트 케이스 필요 → 분리
- 최대 중첩: 2단계 (early return/guard clause 사용)
- 부작용은 함수명에 명시
- 매직 넘버/문자열 → 명명된 상수
- 함수 순서: 호출 순서대로 (위에서 아래로)
- 코드 중복 금지 - 유사 패턴 모듈화
  - 같은 파일 → 함수 추출
  - 여러 파일 → 별도 모듈
  - 여러 프로젝트 → 별도 패키지
- 복잡한 로직은 검증된 외부 라이브러리 사용 (보안, 암호화 등)

## 단일 진실 공급원 (SSOT)

AI는 레이어 간 정의를 중복 생성하여 동기화 문제 유발.

- 모든 데이터 요소는 정확히 하나의 권위 있는 소스만 가짐
- 스키마 우선: 스키마 정의 (Zod/Prisma/OpenAPI) → 타입 생성
  - `type User = z.infer<typeof userSchema>`, 수동 인터페이스 중복 금지
- 상수: 단일 정의 파일, 여기서 enum/스키마 파생
- 설정: 하나의 검증된 config 모듈, 시작 시 fail fast
- API 계약: 스펙이 권위 있는 소스, 서버 인터페이스 + 클라이언트 SDK 생성
- 문서: 소스에서 생성 (JSDoc, OpenAPI), 별도 유지 금지
- 경고 신호: 여러 파일에 동일 인터페이스, "Y 변경 시 X 업데이트 잊지 말 것"

## 워크플로우

- 브랜치/커밋/푸시 자동 실행 금지 - 항상 사용자에게 요청
- 컨텍스트 먼저 수집
  - 작업 전 관련 파일 읽기
  - 기존 패턴과 컨벤션 확인
  - 파일 경로 추측 금지 - 검색 도구 사용
  - API 계약 추측 금지 - 실제 코드 읽기
- 스코프 관리
  - 이슈 크기 정확히 평가
  - 간단한 작업에 과도한 엔지니어링 피하기
- 주요 변경에만 CLAUDE.md/README.md 업데이트
- AI가 같은 실수 반복하면 CLAUDE.md에 명시적 금지 추가
- 백그라운드 프로세스 (dev 서버, watcher) 사용 후 정리
- 생성되는 모든 콘텐츠에 프로젝트 언어 컨벤션 적용
