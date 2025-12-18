---
name: rest-api
description: |
  REST API 설계 및 구현 표준을 제공합니다. RESTful 원칙에 따른 URL 구조, 리소스 명명, HTTP 메서드 사용을 구현하고, 커서 기반 페이지네이션, 정렬, 필터링 패턴을 보장하며, 일관된 에러 응답과 상태 코드 전략을 유지합니다. API 버전 관리, 인증/인가, CORS 설정, OpenAPI 문서화를 마스터합니다.
  다음 경우에 사용: REST API 설계, 엔드포인트 정의, RESTful URL 구조 설계, HTTP 메서드 선택(GET/POST/PUT/DELETE), 페이지네이션 구현, 정렬 및 필터링 파라미터 설계, HTTP 상태 코드 결정, 응답 구조 표준화, 에러 핸들링 전략 수립.
---

# REST API Design Standards

## 네이밍 규칙

### 필드 네이밍

- boolean: `is/has/can` 접두사 강제
- 날짜: `~At` 접미사 강제
- 같은 개념은 프로젝트 전체 동일 용어 (create vs add 중 하나로 통일)

## 날짜 형식

- ISO 8601 UTC
- DateTime 타입 사용

## 페이지네이션

### 커서 기반 사용 (업계 표준)

- 파라미터: `?cursor=xyz&limit=20`
- 응답: `{ data: [...], nextCursor: "abc", hasNext: true }`

## 정렬

- `?sortBy=createdAt&sortOrder=desc`
- 복수 정렬 지원
- 기본값 명시

## 필터

- 범위: `{ min, max }` 또는 `{ gte, lte }`
- 복잡한 조건은 중첩 객체

## URL 구조

### 중첩 리소스

- 최대 2단계

### 액션

- 리소스로 표현 불가시만 동사 허용
- `/users/:id/activate`

## 응답

### 목록

- `data` + 페이지네이션 정보

### 생성

- 201 + 리소스 (민감정보 제외)

### 에러 (RFC 7807 ProblemDetail)

- 필수: `type`, `title`, `status`, `detail`, `instance`
- 선택: `errors` 배열

## 배치

- `/batch` 서픽스
- 성공/실패 개수 + 결과
