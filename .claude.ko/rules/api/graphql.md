# GraphQL API 표준

## 페이지네이션

### Relay Connection 명세

```graphql
type UserConnection {
  edges: [UserEdge!]!
  pageInfo: PageInfo!
}

type UserEdge {
  node: User!
  cursor: String!
}

type PageInfo {
  hasNextPage: Boolean!
  endCursor: String
}
```

- 매개변수: `first`, `after`

## 정렬

- `orderBy: [{ field: "createdAt", order: DESC }]`

## 타입 명명

- Input: `{동사}{타입}Input`
- Connection: `{타입}Connection`
- Edge: `{타입}Edge`

## Input

- 생성과 수정 분리 (생성은 필수, 수정은 선택)
- 중첩 피하기 - ID만 사용

## 에러

### extensions (기본)

- `errors[].extensions`에 `code`, `field`

### Union (타입 안전)

- `User | ValidationError`

## N+1

- DataLoader 필수

## 문서화

- `"""설명"""` 필수
- Input 제약조건 명시적 기술

## Deprecation

- `@deprecated(reason: "...")`
- 타입 삭제 금지
