---
allowed-tools: Bash(git status:*), Bash(git diff:*), Bash(git log:*), Bash(git show:*), Task
description: 현재 git 변경사항 또는 최신 커밋을 code-reviewer와 architect-reviewer 에이전트로 리뷰
---

# 코드 리뷰 커맨드

## 목적

현재 변경사항 또는 최신 커밋에 대한 종합적인 코드 리뷰 수행. 자동으로 호출되는 에이전트:

- **code-reviewer 에이전트**: 항상 (코드 품질, 보안, 유지보수성)
- **architect-reviewer 에이전트**: 조건부 (아키텍처 영향 평가)

---

## 워크플로우

### 1. 리뷰 대상 결정

**커밋되지 않은 변경사항 확인:**

```bash
git status --porcelain
```

**결정:**

- 변경사항 있음: `git diff`로 미커밋 변경사항 리뷰
- 변경사항 없음: `git log -1` 및 `git show HEAD`로 최신 커밋 리뷰

### 2. 변경 범위 분석

**git 출력에서 메트릭 추출:**

수치화:

- 변경된 파일 수
- 추가/삭제된 라인 수
- 영향받는 디렉토리 수
- 신규 파일 vs 수정 파일

탐지:

- 데이터베이스 마이그레이션 파일 (`migrations/`, `schema.prisma`, `*.sql`)
- API 계약 파일 (`*.graphql`, `openapi.yaml`, API 라우트 파일)
- 설정 파일 (`package.json`, `go.mod`, `docker-compose.yml`)
- 신규 디렉토리 또는 모듈

### 3. code-reviewer 에이전트 호출

**항상 Task 도구로 subagent_type: "code-reviewer" 사용하여 실행:**

```
현재 변경사항에 대한 종합적인 코드 리뷰 수행.

집중 영역:
- 코드 품질: 가독성, 네이밍, 구조
- 보안: 노출된 시크릿, 입력 검증, 취약점 패턴
- 에러 처리: 엣지 케이스, 에러 메시지, 복구
- 성능: 명백한 병목, 비효율적 패턴
- 테스트: 중요 경로 커버리지
- 스킬 준수: .claude/skills/ 가이드라인 확인

리뷰할 변경사항:
{git diff 또는 git show 출력 붙여넣기}

피드백을 다음으로 구성:
- 치명적 이슈 (머지 전 반드시 수정)
- 경고 (수정 권장)
- 제안 (개선 고려)

구체적인 코드 예시와 수정 권장사항 포함.
```

code-reviewer 에이전트는 Read, Write, Edit, Bash, Grep 도구에 접근하여 코드를 철저히 분석합니다.

### 4. 조건부 architect-reviewer 호출

**범위 분류 기준** (해당 기준마다 점수 부여):

| 기준                | 임계값                                       | 점수 |
| ------------------- | -------------------------------------------- | ---- |
| 변경된 파일 수      | ≥ 8개 파일                                   | +1   |
| 변경된 라인 수      | ≥ 300줄                                      | +1   |
| 영향받는 디렉토리   | ≥ 3개 디렉토리                               | +1   |
| 새 모듈/패키지      | 3개 이상 파일이 있는 새 디렉토리             | +1   |
| API 계약 변경       | 수정: schema/, .graphql, api/, 라우트 파일   | +1   |
| 데이터베이스 스키마 | 수정: migrations, 스키마 파일, ORM 모델      | +1   |
| 설정/인프라         | 수정: docker-compose, Dockerfile, K8s, CI/CD | +1   |
| 의존성 변경         | 수정: package.json, go.mod, requirements.txt | +1   |

**결정**:

- **점수 < 3** → `code-reviewer`만 호출
- **점수 ≥ 3** → `code-reviewer`와 `architect-reviewer` 모두 호출

**Task 도구로 subagent_type: "architect-reviewer" 사용하여 요청:**

```
이 변경사항에 대한 아키텍처 리뷰 수행.

변경 범위:
- 변경된 파일: {개수}
- 라인: +{추가} -{삭제}
- 영향받는 디렉토리: {목록}
- 범위 점수: {X}/8
- 트리거 기준: {충족된 기준 목록}

평가:
- 시스템 설계 영향
- 확장성 함의
- 기술 선택 정당성
- 통합 패턴 건전성
- 보안 아키텍처
- 도입/해결된 기술 부채
- 진화 경로 명확성

전략적 권장사항을 우선순위별로 제공:
- 치명적 아키텍처 리스크
- 설계 개선 기회
- 장기 유지보수성 우려

리뷰할 변경사항:
{git diff 또는 git show 출력 붙여넣기}
```

architect-reviewer 에이전트는 종합적인 분석을 위해 Read, Write, Edit, Bash, Glob, Grep 도구에 접근합니다.

---

## 출력 형식

**통합 리뷰 요약 생성:**

```markdown
# 코드 리뷰 보고서

**생성일**: {타임스탬프}
**범위**: {미커밋 변경사항 / 최신 커밋: {해시}}
**변경된 파일 수**: {개수}
**호출된 리뷰어**: code-reviewer{, 해당 시 architect-reviewer}

---

## 📊 변경사항 요약

- **라인**: +{추가} -{삭제}
- **파일**: {개수} ({신규} 신규, {수정} 수정)
- **디렉토리**: {영향받는 디렉토리}

---

## 🔍 코드 리뷰어 피드백

{code-reviewer 에이전트의 통합 출력}

---

## 🏗️ 아키텍처 리뷰어 피드백

{호출된 경우, architect-reviewer 에이전트의 통합 출력}
{호출되지 않은 경우: "이 변경 범위에서는 아키텍처 리뷰가 필요하지 않습니다"}

---

## ✅ 리뷰 체크리스트

에이전트 피드백을 기반으로 액션 아이템 생성:

### 치명적 (반드시 수정)

- [ ] {이슈 1}
- [ ] {이슈 2}

### 우선순위 높음 (수정 권장)

- [ ] {이슈 3}

### 제안 (고려)

- [ ] {개선 1}

---

## 📝 다음 단계

{리뷰 결과에 따른 권장 조치}
```

---

## 중요 사항

- **코드 직접 수정 금지** - 이 커맨드는 리뷰만 수행
- **에이전트 자율성**: code-reviewer와 architect-reviewer는 필요에 따라 파일 읽기, 테스트 실행, 의존성 분석 가능
- **스킬 가이드라인**: code-reviewer가 자동으로 .claude/skills/의 위반사항 확인
- **점진적 리뷰**: 대규모 변경(20개 이상 파일)의 경우, 에이전트가 영향도 높은 영역을 우선 집중
- **Git 안전성**: 모든 git 명령은 읽기 전용 (status, diff, log, show)

---

## 사용 예시

```bash
# 미커밋 변경사항 리뷰
/code-review

# 특정 커밋 리뷰 (대화에서 커밋 해시 전달)
# 사용자: "commit abc123 리뷰해줘"
# 그 다음: /code-review
```

---

## Claude 실행 지침

1. `git status --porcelain` 실행하여 변경사항 감지
2. 변경사항 있으면:
   - `git diff`로 미커밋 변경사항 가져오기
   - `git diff --stat`로 메트릭 가져오기
3. 변경사항 없으면:
   - `git log -1 --oneline`로 최신 커밋 가져오기
   - `git show HEAD`로 커밋 변경사항 가져오기
   - `git show HEAD --stat`로 메트릭 가져오기
4. 8개 기준에 대해 범위 점수 계산
5. **항상** Task 도구로 subagent_type: "code-reviewer" 사용하여 code-reviewer 호출
6. **점수 ≥ 3이면** Task 도구로 subagent_type: "architect-reviewer" 사용하여 architect-reviewer 호출
7. 에이전트 분석 완료 대기
8. 피드백을 구조화된 보고서로 통합
9. 실행 가능한 체크리스트 생성

**토큰 최적화:**

- 메트릭에 `git diff --stat`와 `git show --stat` 사용 (전체 diff 파싱 회피)
- 전체 diff 내용은 에이전트에만 전달, 자체 분석에는 사용하지 않음
- 에이전트가 파일 읽기 처리하도록 함 - 변경된 모든 파일 미리 읽지 않음
