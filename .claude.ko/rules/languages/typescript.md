---
paths:
  - "**/*.ts"
  - "**/*.tsx"
---

# TypeScript 표준

## 패키지 관리

- pnpm을 기본 패키지 매니저로 사용
- npm, yarn 금지 (lock 파일 충돌 방지)

## 파일 구조

### 모든 파일 공통

1. Import 문 (그룹화)
2. 상수 정의 (여러 개면 알파벳 순서)
3. Type/Interface 정의 (여러 개면 알파벳 순서)
4. 메인 콘텐츠

### 클래스 내부

- 데코레이터
- private readonly 멤버
- readonly 멤버
- constructor
- public 메서드 (알파벳 순서)
- protected 메서드 (알파벳 순서)
- private 메서드 (알파벳 순서)

### 함수 기반 파일의 함수 배치

- 메인 export 함수
- 추가 export 함수 (알파벳 순서, 많이 두지 않기)
- 헬퍼 함수

## 함수 작성

### 화살표 함수 사용

- 클래스 메서드 외에는 항상 화살표 함수 사용
- function 키워드 전면 금지 (예외: generator function\*, function hoisting 등 기술적으로 불가능한 경우만)

### 함수 인자: 플랫 vs 객체

- 단일 인자이거나 향후 추가 불확실하면 플랫 사용
- 2개 이상 인자는 대부분 객체 형태 사용. 플랫 허용 케이스:
  - boolean 인자 없이 모두 필수 인자일 때
  - 순서가 명확한 필수 인자들 (예: (width,height), (start,end), (min,max), (from,to))

## 타입 시스템

### 타입 안전성

- any, as, !, @ts-ignore, @ts-expect-error 등 안전하지 않은 타입 우회 금지
- 예외: 외부 라이브러리 타입 누락/오류, 빠른 개발 필요 (주석에 이유 명시)
- 타입 가드가 명확할 때 unknown 타입 일부 허용
- 리터럴 타입(as const) 필요 시 as assertion 허용
- 리터럴/HTML 타입을 더 넓은 타입으로 확장 시 as assertion 허용
- TypeScript 한계로 타입 가드 후 타입 좁히기 불가능 시 "!" assertion 허용
- 테스트 코드에서만 @ts-ignore, @ts-expect-error 허용 (프로덕션 절대 금지)

### Interface vs Type

- 기본적으로 모든 경우 Type 우선
- Interface는 다음 예외에만 사용:
  - 라이브러리 public API 같은 외부 사용자 제공 Public API
  - 외부 라이브러리처럼 기존 interface 확장 필요 시
  - OOP 스타일 클래스 설계 시 구현 계약 명확히 정의 필요

### null/undefined 처리

- Optional Chaining (`?.`) 적극 사용
- Nullish Coalescing (`??`)으로 기본값 제공
- `null`과 `undefined` 의미론적 구분:
  - `undefined`: 초기화되지 않은 상태, 선택적 매개변수, 아직 할당되지 않은 값
  - `null`: 의도적 값 부재 (Go의 nil과 유사)

## 코드 스타일

### 불변성 유지

- 가능한 한 `const` 사용, `let` 최소화
- 배열/객체 직접 수정 대신 새 값 생성
- `push`, `splice` 대신 `spread`, `filter`, `map` 사용
- 예외: 극도로 성능이 중요한 경우

## 권장 라이브러리

- 테스팅: Vitest, Playwright
- 유틸리티: es-toolkit, dayjs
- HTTP: ky, @tanstack/query, @apollo/client
- 폼: React Hook Form
- 타입 검증: zod
- UI: Tailwind + shadcn/ui
- ORM: Prisma (엣지 지원 중요하면 Drizzle)
- 상태 관리: zustand
- 코드 포맷팅: prettier, eslint
- 빌드: tsup
