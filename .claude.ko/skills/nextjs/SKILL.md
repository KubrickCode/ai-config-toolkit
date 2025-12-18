---
name: nextjs
description: |
  Next.js 프로젝트 아키텍처 표준과 BFF 패턴을 제공합니다. App Router 기반 구조, Server Components 전략, 데이터 페칭 정책을 구현하고, 서버/클라이언트 경계를 명확히 분리하며, 성능 최적화와 SEO 모범 사례를 보장합니다. Server Actions, Route Handlers, 레이아웃 계층 구조를 마스터하고, BFF(Backend for Frontend) 패턴을 강제 적용합니다.
  다음 경우에 사용: Next.js 프로젝트 개발, App Router 구조 설계, Server Components/Client Components 분리, Server Actions 구현, 데이터 페칭 전략 수립, BFF 아키텍처 구현, Route Handlers 작성, 메타데이터 및 SEO 최적화.
---

# Next.js 프로젝트 아키텍처 규칙

**범위**: 프로젝트 특화 정책 및 아키텍처 결정사항만 포함.

**버전**: Next.js 15.5+ App Router

---

## 1. BFF 아키텍처 (필수)

### 절대 규칙

Next.js는 오직 얇은 BFF(Backend for Frontend) 레이어로만 사용:

```
브라우저 ↔ Next.js 서버 ↔ 백엔드 API ↔ 데이터베이스
```

**절대 금지**:

- ❌ Next.js에서 직접 데이터베이스 접근 (Prisma, ORM 사용 금지)
- ❌ Next.js에 비즈니스 로직 구현
- ❌ 입력 검증 이상의 데이터 검증

**필수**:

- ✅ 모든 비즈니스 로직은 별도 백엔드 서비스에
- ✅ 모든 데이터베이스 작업은 백엔드 API 경유
- ✅ Next.js 용도: SSR/SSG, API 집계, 세션 관리, 캐싱

---

## 2. 컴포넌트 전략 (강제)

### Server Components 우선

**규칙**: 기본은 Server Components. `'use client'`는 리프 노드에만.

**Client Component 허용 조건**:

- 이벤트 핸들러 (onClick, onChange)
- 브라우저 API (localStorage, window)
- React hooks (useState, useEffect)

**위반**: Client Component가 Server Components를 감싸는 경우

---

## 3. 렌더링 전략 (명시 필수)

### 필수 export

모든 페이지는 렌더링 의도를 명시적으로 선언해야 함:

```typescript
// 필수 - 하나 선택:
export const dynamic = "force-static"; // SSG
export const dynamic = "force-dynamic"; // SSR
export const revalidate = 3600; // ISR
```

**암묵적 렌더링 금지**. 캐싱 동작을 항상 명시.

---

## 4. 데이터 페칭 (Server Actions vs API Routes)

### Server Actions (내부 작업 기본)

**사용처**:

- 폼 제출
- 데이터 변경
- 내부 Next.js 작업

**위치**: `app/actions/*.ts` 또는 `'use server'` 인라인

### API Routes (외부 통합 전용)

**사용처**:

- 웹훅 (Stripe, GitHub 등)
- OAuth 콜백
- 모바일 앱 엔드포인트
- 서드파티 서비스 통합

**위치**: `app/api/*/route.ts`

**절대 금지**: 내부 Next.js 통신에 API Routes 사용

---

## 5. 캐싱 정책 (명시 필수)

### 필수 캐시 선언

모든 fetch 호출은 캐싱을 명시적으로 지정해야 함:

```typescript
// 필수 - 하나 선택:
fetch(url, { next: { revalidate: 3600 } }); // 시간 기반
fetch(url, { cache: "no-store" }); // 동적
```

**React `cache()` 사용** 필수: 렌더 사이클 내 중복 요청 방지.

**암묵적 캐싱 금지**. 의도를 항상 선언.

---

## 중대 위반 사항

1. **Next.js에서 직접 DB 접근** → 아키텍처 위반
2. **내부 변경에 API Routes 사용** → Server Actions 사용 필수
3. **렌더링 전략 선언 누락** → 명시적 export 추가
4. **Client Component가 리프가 아님** → `'use client'`를 하위로 이동
5. **암묵적 캐싱** → 명시적 캐시 선언 추가
6. **백엔드 미분리** → 별도 서비스 필수
