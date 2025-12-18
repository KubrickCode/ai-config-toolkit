# React 개발 표준

## 컴포넌트 구조

### 파일당 컴포넌트 규칙

export 컴포넌트는 파일당 하나 원칙; 내부 컴포넌트는 필요시 복수 가능 (권장하지 않음).

- export default 금지 (리팩토링 및 tree-shaking 문제)
- named export만 사용
- 내부 헬퍼 컴포넌트는 export 금지
- 파일 순서: 메인 export 컴포넌트 → 추가 export 컴포넌트 → 내부 헬퍼 컴포넌트

## 상태 관리 규칙

### 상태 관리 계층

1. **로컬 상태 (useState)**: 단일 컴포넌트에서만 사용
2. **Props Drilling**: 최대 2단계 허용
3. **Context API**: 3단계 이상 props drilling 필요 시 사용
4. **전역 상태 (Zustand 등)**:
   - 5개 이상 컴포넌트에서 공유
   - 서버 상태 동기화 필요
   - 복잡한 상태 로직 (computed, actions)
   - 개발자 도구 지원 필요

## Hook 사용 규칙

### 커스텀 Hook 추출 기준

- useState/useEffect 3개 이상 조합
- 2개 이상 컴포넌트에서 재사용
- 50줄 이상 로직

### useEffect 사용 최소화

- useEffect는 외부 시스템 동기화에만 사용
- 상태 업데이트는 이벤트 핸들러에서 처리
- 파생 값은 직접 계산하거나 useMemo 사용
- 정말 필요할 때만 사용하고 이유 주석

```typescript
// Bad: 상태 동기화에 useEffect
useEffect(() => {
  setFullName(`${firstName} ${lastName}`);
}, [firstName, lastName]);

// Good: 직접 계산
const fullName = `${firstName} ${lastName}`;
```

## Props 규칙

### 공통 컴포넌트 Props 추가 규칙

- 새 props 추가 전 구조 검토 (공유 레벨에 무분별한 props 추가 방지)
- 단일 책임 원칙 위반 확인
- 선택적 props 3개 이상이면 composition 패턴 고려
- variant prop으로 통합 가능한지 검토

## 조건부 렌더링

### 기본 규칙

```typescript
// 단순 조건: && 연산자
{isLoggedIn && <UserMenu />}

// 이진 선택: 삼항 연산자
{isLoggedIn ? <UserMenu /> : <LoginButton />}

// 복잡한 조건: 별도 함수 또는 early return
const renderContent = () => {
  if (status === 'loading') return <Loader />;
  if (status === 'error') return <Error />;
  return <Content />;
};
```

### Activity 컴포넌트

- 숨겨진 부분 사전 렌더링 또는 상태 유지 필요 시 사용
- visible/hidden 모드로 관리
- 탭 전환, 모달 콘텐츠 등 자주 토글되는 UI에 활용

## 메모이제이션

### React Compiler 사용

- 자동 메모이제이션에 의존
- 수동 메모이제이션 (React.memo, useMemo, useCallback)은 특수 케이스에만
- 컴파일러가 최적화 못할 때 escape hatch로 사용
