---
paths:
  - "**/*.go"
---

# Go 표준

## 에러 처리 (Go 특화)

- 에러 체인에는 %w, 단순 로깅에는 %v 사용
- 노출하지 않을 내부 에러는 %v로 감싸기
- 함수의 반환 에러 무시 금지; 명시적으로 처리
- 센티넬 에러: 호출자가 처리해야 할 예상 조건에는 `var ErrNotFound = errors.New("not found")` 사용

## 파일 구조

### 파일 내 요소 순서

1. package 선언
2. import 문 (그룹화)
3. 상수 정의 (const)
4. 변수 정의 (var)
5. Type/Interface/Struct 정의
6. 생성자 함수 (New\*)
7. 메서드 (receiver 타입별 그룹, 알파벳 순서)
8. 헬퍼 함수 (알파벳 순서)

## 인터페이스와 구조체

### 인터페이스 정의 위치

- 사용하는 패키지에서 인터페이스 정의 (Accept interfaces, return structs)
- 여러 패키지가 사용하는 공유 인터페이스만 분리

### 포인터 리시버 규칙

- 상태 변경, 큰 구조체(3+ 필드), 일관성 필요 시 포인터 리시버
- 그 외에는 값 리시버

## Context 사용

### Context 매개변수

- 항상 첫 번째 매개변수로 전달
- `context.Background()`는 main과 테스트에서만 사용

## 테스팅

### 테스팅 라이브러리

- testify 같은 assertion 라이브러리보다 표준 라이브러리의 if + t.Errorf 선호
- gomock보다 수동 모킹 선호

## 금지 사항

### init() 함수

- 등록 패턴(데이터베이스 드라이버, 플러그인)에 필요한 경우 외 피하기
- 비즈니스 로직에는 명시적 초기화 함수 선호
- 허용 케이스:
  - 드라이버/플러그인 등록 (예: `database/sql` 드라이버)
  - I/O 없는 정적 라우트/핸들러 등록
  - 부작용 없는 복잡한 상수 초기화
- 금지 케이스:
  - 외부 I/O (데이터베이스, 파일, 네트워크)
  - 전역 상태 변경
  - 에러 발생 가능한 초기화 (에러 반환하는 생성자 사용)

## 패키지 구조

### internal 패키지

- 라이브러리에는 적극 사용, 애플리케이션에는 필요 시에만 사용

## 권장 라이브러리

- 웹: chi
- DB: Bun, SQLBoiler (마이그레이션 외부 관리 시)
- 로깅: slog
- CLI: cobra
- 유틸리티: samber/lo, golang.org/x/sync
- 설정: koanf (cobra 통합 필요하면 viper)
- 검증: go-playground/validator/v10
- 스케줄링: github.com/go-co-op/gocron
- 이미지 처리: github.com/h2non/bimg
