---
paths:
  - "**/*.spec.ts"
  - "**/*.test.ts"
  - "**/*.spec.tsx"
  - "**/*.test.tsx"
---

# TypeScript 테스팅 표준

## 파일 명명

형식: `{대상-파일명}.spec.ts`

예시: `user.service.ts` → `user.service.spec.ts`

## 테스트 프레임워크

Vitest 사용. 프로젝트 내 일관성 유지.

## 구조

`describe`로 메서드/기능 그룹화, `it`으로 개별 케이스 작성. 중첩 `describe`로 시나리오 분류 가능.

## 모킹

Vitest의 `vi.mock()`, `vi.spyOn()` 활용. 외부 모듈은 최상위에서 모킹; 테스트별로 `mockReturnValue`, `mockImplementation`으로 동작 변경.

## 비동기 테스팅

`async/await` 사용. Promise rejection은 `await expect(fn()).rejects.toThrow()` 형태로 테스트.

## Setup/Teardown

`beforeEach`, `afterEach`로 공통 설정/정리. `beforeAll`, `afterAll`은 무거운 초기화(DB 연결 등)에만 사용.

## 타입 안전성

테스트 코드도 타입 체크. `as any`나 `@ts-ignore` 최소화. 필요시 타입 가드나 타입 단언 명시적 사용.

## 테스트 유틸 위치

단일 파일용은 같은 파일 하단에 배치. 다중 파일 공유용은 `__tests__/utils` 또는 `test-utils` 디렉토리.

## 커버리지

코드 커버리지는 참고 지표. 100% 맹목적 추구보다 의미 있는 테스트 커버리지 집중.
