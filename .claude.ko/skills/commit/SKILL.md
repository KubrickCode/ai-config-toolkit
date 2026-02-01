---
name: commit
description: Conventional Commits 규격(feat/fix/docs/chore)에 따라 한국어와 영어 커밋 메시지 생성
allowed-tools: Bash(git status:*), Bash(git diff:*), Bash(git log:*), Bash(git branch:*), Read, Grep, Write
disable-model-invocation: true
---

# Conventional Commits 메시지 생성기

[Conventional Commits v1.0.0](https://www.conventionalcommits.org/) 규격을 따르는 커밋 메시지를 한국어와 영어로 생성합니다. **하나를 선택하여 커밋에 사용하세요.**

## 저장소 상태 분석

- Git 상태: !git status --porcelain
- 현재 브랜치: !git branch --show-current
- 스테이징된 변경사항: !git diff --cached --stat
- 스테이징되지 않은 변경사항: !git diff --stat
- 최근 커밋: !git log --oneline -10

## 이 명령의 기능

1. 현재 브랜치명을 확인하여 이슈 번호 감지 (예: develop/shlee/32 → #32)
2. git status로 스테이징된 파일 확인
3. git diff를 수행하여 커밋될 변경사항 파악
4. 한국어와 영어로 Conventional Commits 형식의 커밋 메시지 생성
5. 브랜치명이 숫자로 끝나면 "fix #N" 추가
6. **commit_message.md 파일로 저장하여 복사하기 편리하게 제공**

## Conventional Commits 형식 (필수)

```
<type>[(optional scope)]: <description>

[optional body]

[optional footer: fix #N]
```

### 사용 가능한 타입

스테이징된 변경사항을 분석하여 가장 적절한 타입을 제안:

| 타입         | 사용 시점                                   | SemVer 영향   |
| ------------ | ------------------------------------------- | ------------- |
| **feat**     | 새로운 기능이나 역량 추가                   | MINOR (0.x.0) |
| **fix**      | 사용자가 겪는 버그 수정                     | PATCH (0.0.x) |
| **ifix**     | 인프라/내부 버그 수정 (CI, 빌드, 배포)      | PATCH (0.0.x) |
| **perf**     | 성능 개선                                   | PATCH         |
| **docs**     | 문서만 변경 (README, 주석 등)               | PATCH         |
| **style**    | 코드 포매팅, 세미콜론 누락 (로직 변경 없음) | PATCH         |
| **refactor** | 동작 변경 없는 코드 구조 개선               | PATCH         |
| **test**     | 테스트 추가 또는 수정                       | PATCH         |
| **chore**    | 빌드 설정, 의존성, 도구 업데이트            | PATCH         |
| **ci**       | CI/CD 설정 변경                             | PATCH         |

**BREAKING CHANGE**: 반드시 type! 형식(타입 뒤에 느낌표)과 BREAKING CHANGE: footer에 마이그레이션 가이드를 함께 포함해야 함 (major 버전 증가).

### 타입 선택 결정 트리

git diff 출력을 분석하여 파일 패턴 기반으로 타입 제안:

```
변경된 파일 → 제안 타입

src/**/*.{ts,js,tsx,jsx} + 새 함수/클래스 → feat
src/**/*.{ts,js,tsx,jsx} + 버그 수정 → fix
README.md, docs/**, *.md → docs
package.json, pnpm-lock.yaml, .github/** → chore
**/*.test.{ts,js}, **/*.spec.{ts,js} → test
.github/workflows/** → ci
```

여러 타입이 해당되면 우선순위: `feat` > `fix` > 기타 타입.

### 헷갈리는 케이스: fix vs ifix vs chore 구분

**핵심 기준**: **사용자**에게 영향을 주는가, **개발자/인프라**에만 영향을 주는가?

| 상황                                                    | 타입       | 이유                                        |
| ------------------------------------------------------- | ---------- | ------------------------------------------- |
| 백엔드 GitHub Actions 테스트 워크플로우가 동작하지 않음 | `ifix`     | 개발을 막는 CI/CD 버그                      |
| OOM 에러로 배포 실패                                    | `ifix`     | 릴리스를 막는 인프라 버그                   |
| E2E 테스트가 불안정하여 오탐 발생                       | `ifix`     | 테스트 인프라 버그                          |
| Vite 프로덕션 빌드 시 타임아웃 발생                     | `ifix`     | 빌드 시스템 버그                            |
| API가 정상 요청에 500 에러 반환                         | `fix`      | 사용자가 에러 응답을 경험함                 |
| 페이지 로딩 속도가 3초에서 0.8초로 개선                 | `perf`     | 사용자가 직접 체감하는 개선                 |
| 프로필 페이지 접근 시 앱 종료                           | `fix`      | 사용자가 크래시를 경험함                    |
| 내부 데이터베이스 쿼리 최적화 (사용자 무체감)           | `refactor` | 코드 개선, 사용자에게 측정 가능한 이점 없음 |
| 의존성 보안 패치 (CVE 수정)                             | `chore`    | 빌드/도구 업데이트 (버그 수정 아님)         |
| 새로운 기능을 위한 React 버전 업그레이드                | `chore`    | 의존성 업데이트 (버그 수정 아님)            |

**판단 플로우차트:**

```
버그(고장난 것)인가?
├─ 아니오 → chore/refactor/docs 등 사용
└─ 예 → 최종 사용자에게 영향을 주는가?
    ├─ 예 → fix (사용자 대면 버그)
    └─ 아니오 → ifix (인프라/개발자 버그)
```

## 커밋 메시지 작성 가이드라인

**핵심 원칙: 근본 원인 → 선택 근거 → 구현 방법**

커밋 메시지는 의사결정의 **역사**를 기록합니다. 단순한 코드 변경 목록이 아닙니다.

### 복잡도 기반 형식

#### 매우 간단한 변경사항 (WHY 불필요)

```
type: 간결한 설명
```

**예시:**

```
docs: README 오타 수정
```

#### 간단한 변경사항 (최소한의 WHY)

```
type: 문제 상황 설명

근본 원인 한 문장.
이 해결책을 선택한 이유 (자명하지 않은 경우).
```

#### 표준 변경사항

```
type: 문제 상황 설명

발생한 문제 상황 설명
(재현 가능하면 간단한 재현 방법)

근본 원인 설명과 이 해결 방법을 선택한 이유

fix #N
```

## 출력 형식

명령이 제공하는 내용:

1. 스테이징된 변경사항 분석 (없으면 모든 변경사항)
2. **commit_message.md 파일 생성** - 한국어와 영어 버전 모두 포함
3. 파일에서 원하는 버전을 복사하여 사용

## 중요 사항

- 이 명령은 커밋 메시지만 생성하며 - 실제 커밋은 수행하지 않음
- **commit_message.md 파일에 두 버전 모두 저장** - 원하는 것 선택
- **근본 원인과 선택 근거에 집중** - 단순 변경사항 나열 금지
- 메시지는 간결하게 - 코드에서 명백한 내용은 과도하게 설명하지 않음
- 브랜치 이슈 번호(예: develop/32)는 자동으로 "fix #N" 추가
- 생성된 파일에서 메시지 복사 후 `git commit`을 수동으로 실행
