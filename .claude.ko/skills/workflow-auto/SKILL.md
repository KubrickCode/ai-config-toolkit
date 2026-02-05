---
name: workflow-auto
description: workflow-analyze → workflow-plan → workflow-execute → commit을 중간 승인 없이 연속 실행 (단일 커밋)
disable-model-invocation: true
---

# 자동 워크플로우 명령

## 사용자 입력

```text
$ARGUMENTS
```

사용자 입력이 비어있지 않다면 **반드시** 고려해야 합니다.

---

## 개요

이 명령은 전체 워크플로우(analyze → plan → execute → commit)를 **중간 승인 없이 연속으로** 실행합니다.

**개별 커맨드와의 차이점**:

- 단계 간 중간 승인 없음
- 계획은 **단일 커밋**으로 제한 (커밋 분리 없음)
- 마지막에 커밋 메시지 자동 생성
- 그 외 모든 과정은 원본 커맨드와 동일

**사용 시점**:

- 단일 커밋으로 완료 가능한 작업
- 수동 단계 전환을 생략하고 싶을 때

**사용하지 말아야 할 때**:

- 여러 커밋이 필요한 복잡한 기능 → 개별 커맨드 사용
- 검증이 필요한 작업 → `/workflow-validate` 사용
- 실행 전 분석/계획을 검토하고 싶을 때

---

## 실행 흐름

### 1단계: 분석

**`/workflow-analyze`** 커맨드와 **완전히 동일하게** 실행:

1. 사용자 입력 파싱, 작업명 생성
2. 구체적 시나리오로 문제 정의
3. 2-4개 해결방안 조사
4. 최종 방안 선택 및 반려 이유 명시
5. 확인 질문 생성 (최대 3개)
6. 문서 작성: `docs/work/{작업명}/analysis.md` (한글)

**workflow-analyze의 전체 템플릿 사용** (간소화 X).

→ **승인 없이 즉시 다음 단계 진행**

---

### 2단계: 계획

**`/workflow-plan`** 커맨드와 **완전히 동일하게** 실행, 단 하나의 제약:

1. 1단계에서 생성한 작업명 파싱
2. analysis.md 요구사항 로드
3. 영향 범위 파악
4. **단일 커밋 계획 수립** (커밋 분리 없음)
5. 원칙 위반 시 정당화 검토
6. 문서 작성: `docs/work/{작업명}/plan.md` (한글)

**workflow-plan의 전체 템플릿 사용** (간소화 X).

**단일 커밋 제약**: 모든 변경사항을 수직 슬라이싱(타입 + 로직 + 테스트 함께)으로 하나의 커밋으로 계획.

→ **승인 없이 즉시 다음 단계 진행**

---

### 3단계: 실행

**`/workflow-execute`** 커맨드와 **완전히 동일하게** 실행:

1. plan.md 체크리스트 로드
2. 컨텍스트용 analysis.md 참조
3. 코딩 원칙 엄격 준수
4. 모든 작업 순차 실행
5. 테스트 작성
6. 검증 (테스트 실행, 동작 확인)
7. 요약 생성:
   - `docs/work/{작업명}/summary-commit-1.md`
8. 완료 보고

**workflow-execute의 전체 템플릿 사용** (간소화 X).

→ **승인 없이 즉시 다음 단계 진행**

---

### 4단계: 커밋 메시지

**`/commit`** 커맨드와 **완전히 동일하게** 실행:

1. git status로 staged/unstaged 파일 확인
2. git diff로 변경사항 분석
3. 브랜치명에서 이슈 번호 확인
4. Conventional Commits 형식으로 커밋 메시지 생성
5. `commit_message.md`에 작성 (한글/영어 버전)

**commit 커맨드의 전체 과정 사용**.

---

## 핵심 규칙

### ✅ 해야 할 것

- 각 단계의 원본 커맨드를 정확히 따름
- 원본 템플릿 사용 (간소화 버전 X)
- 세 단계 모두 멈추지 않고 실행
- 계획은 단일 커밋으로 제한
- 코딩 원칙 엄격 준수

### ❌ 하지 말아야 할 것

- 단계의 과정을 간소화하거나 생략
- 커스텀/축약 템플릿 사용
- 중간 승인 요청
- 여러 커밋으로 분리

---

## 문서 구조

개별 커맨드와 동일:

```
docs/work/{작업명}/
├── analysis.md             (한글 - workflow-analyze)
├── plan.md                 (한글 - workflow-plan)
└── summary-commit-1.md     (한글 - workflow-execute)

commit_message.md           (commit)
```

---

## 실행

각 커맨드 파일을 읽고 따라서 전체 워크플로우를 실행하세요:

1. **`.claude.ko/skills/workflow-analyze/SKILL.md` 읽고** 전체 과정 실행
2. 멈추지 않고 **`.claude.ko/skills/workflow-plan/SKILL.md` 읽고** 실행 (단일 커밋만)
3. 멈추지 않고 **`.claude.ko/skills/workflow-execute/SKILL.md` 읽고** 커밋 1 실행
4. 멈추지 않고 **`.claude.ko/skills/commit/SKILL.md` 읽고** commit_message.md 생성

정확한 과정과 템플릿을 이해하기 위해 각 커맨드 파일을 반드시 읽어야 합니다.
