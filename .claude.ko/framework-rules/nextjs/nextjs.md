# Next.js 프로젝트 아키텍처 규칙

**버전**: Next.js 15.5+ with App Router

## 1. BFF 아키텍처 (필수)

### 절대 규칙

Next.js는 오직 얇은 Backend for Frontend (BFF) 레이어로만 사용:

```
브라우저 ↔ Next.js 서버 ↔ 백엔드 API ↔ 데이터베이스
```

**금지**:

- Next.js에서 직접 DB 접근 (Prisma, ORM 금지)
- Next.js에서 비즈니스 로직 구현
- 입력 새니타이징 이상의 데이터 검증

**필수**:

- 모든 비즈니스 로직은 별도 백엔드 서비스에
- 모든 DB 작업은 백엔드 API를 통해
- Next.js 용도: SSR/SSG, API 집계, 세션 관리, 캐싱

## 2. 컴포넌트 전략 (강제)

### Server Components 우선

**규칙**: 기본은 Server Components. `'use client'`는 리프 노드에서만.

**Client Component 허용 케이스**:

- 이벤트 핸들러 (onClick, onChange)
- 브라우저 API (localStorage, window)
- React hooks (useState, useEffect)

**위반**: Client Component가 Server Components를 래핑

## 3. 렌더링 전략 (명시적 선언 필수)

### 필수 Export

모든 페이지는 렌더링 의도를 명시적으로 선언:

```typescript
// 필수 - 하나 선택:
export const dynamic = "force-static"; // SSG
export const dynamic = "force-dynamic"; // SSR
export const revalidate = 3600; // ISR
```

**암묵적 렌더링 금지**. 캐싱 동작 항상 명시.

## 4. 데이터 페칭 (Server Actions vs API Routes)

### Server Actions (내부 작업 기본)

**용도**:

- 폼 제출
- 데이터 변경
- 내부 Next.js 작업

**위치**: `app/actions/*.ts` 또는 `'use server'`로 인라인

### API Routes (외부 통합 전용)

**용도**:

- 웹훅 (Stripe, GitHub 등)
- OAuth 콜백
- 모바일 앱 엔드포인트
- 서드파티 서비스 통합

**위치**: `app/api/*/route.ts`

**금지**: 내부 Next.js-to-Next.js 통신에 API routes 사용

## 5. 캐싱 정책 (명시적 의도 필수)

### 필수 캐시 선언

모든 fetch 호출은 캐싱을 명시적으로 지정:

```typescript
// 필수 - 하나 선택:
fetch(url, { next: { revalidate: 3600 } }); // 시간 기반
fetch(url, { cache: "no-store" }); // 동적
```

**React `cache()` 사용**으로 렌더 사이클 내 중복 요청 방지.

**암묵적 캐싱 금지**. 항상 의도 선언.

## 주요 위반 사항

1. **Next.js에서 직접 DB 접근** → 아키텍처 위반
2. **내부 변경에 API Routes** → Server Actions 사용
3. **렌더링 전략 선언 누락** → 명시적 export 추가
4. **리프가 아닌 Client Component** → `'use client'` 하위로 이동
5. **암묵적 캐싱** → 명시적 캐시 선언 추가
6. **백엔드 미분리** → 별도 서비스 필수
