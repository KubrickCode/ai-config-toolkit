# 테스팅 핵심 원칙

## 테스트 파일 구조

테스트 대상 파일과 1:1 매칭. 테스트 파일은 대상 파일과 같은 디렉토리에 위치. 파일 경로는 도메인 구조 반영.

```
# Good: 도메인 기반 구성
src/auth/__tests__/login.test.ts
src/payment/__tests__/checkout.test.ts

# Bad: 평면 테스트 디렉토리
tests/test1.test.ts
tests/test2.test.ts
```

## 테스트 계층

중첩 suite 구조로 도메인 컨텍스트 제공. suite 경로가 테스트 목적 이해를 위한 가장 강력한 구조적 신호.

```
Good: 계층에 풍부한 컨텍스트, 간결한 테스트 이름
  Suite: OrderService > Sorting > "created desc"

Bad: 모든 컨텍스트가 테스트 이름에 집중
  Test: "OrderService returns items sorted by creation date"
```

suite 컨텍스트가 풍부하면 짧은 테스트 이름도 허용.

## 테스트 커버리지 선택

명확하거나 너무 단순한 로직(단순 getter, 상수 반환) 생략. 비즈니스 로직, 조건 분기, 외부 의존성 코드 우선 테스트.

## AI 테스트 생성 가이드

AI는 커버리지는 높지만 인사이트가 낮은 테스트를 생성하는 경향. 다음 제약 적용:

- **trivial 테스트 제외**: 단순 getter, setter, pass-through 함수 테스트 금지
- **고가치 영역 집중**: 경계값, 에러 경로, 경쟁 조건, 통합 지점에 AI 집중
- **테스트 bloat 방지**: 각 테스트는 다른 테스트가 다루지 않는 고유한 인사이트 제공 필수
- **AI 제안 검토**: AI가 뻔한 happy path 테스트 제안 시 edge case 요청

## 테스트 케이스 구성

최소 하나의 기본 성공 케이스 필수. 실패 케이스, 경계값, 엣지 케이스, 예외 시나리오 중점.

## 테스트 독립성

각 테스트는 독립 실행 가능해야 함. 테스트 실행 순서 의존성 금지. 각 테스트에서 공유 상태 초기화.

## Given-When-Then 패턴

테스트 코드를 3단계로 구성—Given (설정), When (실행), Then (검증). 복잡한 테스트는 주석이나 빈 줄로 단계 구분.

## 테스트 데이터

하드코딩된 의미 있는 값 사용. 랜덤 데이터는 재현 불가능한 실패 유발하므로 피하기. 필요시 시드 고정.

## 모킹 원칙

외부 의존성(API, DB, 파일 시스템) 모킹. 같은 프로젝트 내 모듈은 실제 사용 선호; 복잡도 높을 때만 모킹.

## 실제 도메인 모듈 Import

테스트 대상 서비스/모듈을 이름으로 실제 import. import 문이 어떤 코드를 테스트하는지 이해하는 가장 강력한 신호.

- Good: 도메인 모듈 import (`OrderService`, `PaymentValidator`)
- Bad: 테스트 유틸리티만 import하거나, import 없이 모든 것을 인라인으로 처리

## 테스트 재사용성

반복되는 모킹 설정, 픽스처, 헬퍼 함수는 공통 유틸리티로 추출. 과도한 추상화로 테스트 가독성 해치지 않도록 주의.

## 통합/E2E 테스팅

단위 테스트 우선. 복잡한 흐름이나 다중 모듈 상호작용이 코드만으로 이해 어려울 때 통합/E2E 테스트 작성. 별도 디렉토리(`tests/integration`, `tests/e2e`)에 배치.

## 테스트 이름

테스트 이름은 구현 세부사항이 아닌 동작 설명.

- Good: `rejects expired tokens with 401 status`, `sorts orders by creation date descending`
- Bad: `test token validation`, `works correctly`, `handles edge case`

권장 형식: "should do X when Y" 또는 직접적인 동작 서술.

## 검증 개수

하나의 테스트에 관련된 여러 검증 가능, 단 다른 개념 검증 시 테스트 분리.
