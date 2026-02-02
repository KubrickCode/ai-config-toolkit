---
paths:
  - "**/*_test.go"
---

# Go 테스팅 표준

## 파일 명명

형식: `{대상-파일명}_test.go`

예시: `user.go` → `user_test.go`

## 테스트 함수

형식: `func TestXxx(t *testing.T)`. 메서드당 `TestMethodName` 함수 작성, `t.Run()`으로 서브테스트 구성.

## 서브테스트

`t.Run()`으로 도메인 컨텍스트 계층 제공. 서브테스트 경로가 가장 강력한 구조적 신호.

```go
// Good: Domain > Feature > Scenario 계층
func TestAuthService(t *testing.T) {
    t.Run("Login", func(t *testing.T) {
        t.Run("valid credentials", func(t *testing.T) { ... })
        t.Run("invalid password", func(t *testing.T) { ... })
    })
    t.Run("Token", func(t *testing.T) {
        t.Run("refresh expired", func(t *testing.T) { ... })
    })
}

// Bad: 평면 구조
func TestLoginWorks(t *testing.T) { ... }
func TestLogoutWorks(t *testing.T) { ... }
```

각 케이스는 독립 실행 가능해야 함. 병렬 실행 시 `t.Parallel()` 호출.

## 테이블 기반 테스트

여러 케이스가 유사한 구조일 때 권장. `[]struct{ name, input, want, wantErr }`로 케이스 정의.

```go
tests := []struct {
    name    string
    input   int
    want    int
    wantErr bool
}{
    {"normal case", 5, 10, false},
    {"negative input", -1, 0, true},
}
for _, tt := range tests {
    t.Run(tt.name, func(t *testing.T) {
        got, err := Func(tt.input)
        if (err != nil) != tt.wantErr { ... }
        if got != tt.want { ... }
    })
}
```

## Imports

테스트 대상 도메인 패키지를 실제 import. import 문이 테스트 목적 이해를 위한 가장 강력한 신호.

```go
// Good: 명확한 도메인 imports
import (
    "myapp/modules/order"
    "myapp/validators/payment"
)

// Bad: 테스트 유틸리티만, 도메인 컨텍스트 없음
import "testing"
```

## 모킹

인터페이스 기반 의존성 주입 활용. 수동 모킹 선호; 복잡한 경우 gomock 고려. 테스트 전용 구현은 `_test.go` 내에 정의.

## 에러 검증

`errors.Is()`와 `errors.As()` 사용. 에러 메시지 문자열 비교 피하기; 센티넬 에러나 에러 타입으로 검증.

## Setup/Teardown

`TestMain(m *testing.M)`으로 전역 설정/정리. 개별 테스트 준비는 각 테스트 함수 내에서 또는 헬퍼 함수로 추출.

## 테스트 헬퍼

반복되는 설정/검증은 `testXxx(t *testing.T, ...)` 헬퍼로 추출. `*testing.T`를 첫 인자로 받고 `t.Helper()` 호출.

## 벤치마크

성능 중요 코드에 `func BenchmarkXxx(b *testing.B)` 작성. `b.N`으로 루프, `b.ResetTimer()`로 설정 시간 제외.
