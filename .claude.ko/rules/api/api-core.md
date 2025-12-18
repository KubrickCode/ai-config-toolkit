# API 핵심 표준

## 명명 규칙

### 필드 명명

- Boolean: `is/has/can` 접두사 필수
- Date: `~At` 접미사 필수
- 프로젝트 전체에서 일관된 용어 사용 ("create" 또는 "add" 중 통일)

## 날짜 형식

- ISO 8601 UTC
- DateTime 타입 사용

## 페이지네이션

### 커서 기반 (업계 표준)

- 매개변수: `?cursor=xyz&limit=20` (REST) 또는 `first`, `after` (GraphQL)
- 응답 포함: 데이터, 다음 커서, 다음 페이지 존재 여부

## 정렬

- sortBy와 sortOrder 매개변수 지원
- 다중 정렬 기준 지원
- 기본값 명확히 명시

## 필터링

- 범위: `{ min, max }` 또는 `{ gte, lte }`
- 복잡한 조건은 중첩 객체 사용
