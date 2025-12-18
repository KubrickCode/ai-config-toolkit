# REST API 표준

## 페이지네이션

### 커서 기반

- 매개변수: `?cursor=xyz&limit=20`
- 응답: `{ data: [...], nextCursor: "abc", hasNext: true }`

## 정렬

- `?sortBy=createdAt&sortOrder=desc`

## URL 구조

### 중첩 리소스

- 최대 2단계

### 액션

- 리소스로 표현 불가능할 때만 동사 허용
- `/users/:id/activate`

## 응답

### 목록

- `data` + 페이지네이션 정보

### 생성

- 201 + 리소스 (민감 정보 제외)

### 에러 (RFC 7807 ProblemDetail)

- 필수: `type`, `title`, `status`, `detail`, `instance`
- 선택: `errors` 배열

## 배치

- `/batch` 접미사
- 성공/실패 카운트 + 결과
