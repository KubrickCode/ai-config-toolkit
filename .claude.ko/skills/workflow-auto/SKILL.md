---
name: workflow-auto
description: workflow-analyze → workflow-plan → workflow-execute → commit을 중간 승인 없이 연속 실행 (단일 커밋). 단일 커밋으로 완료 가능한 소규모 작업에서 수동 단계 전환을 생략하고 싶을 때 사용. 여러 커밋이 필요한 복잡한 기능, 검증이 필요한 작업(/workflow-validate), 실행 전 분석/계획을 검토하고 싶을 때는 사용하지 말 것.
disable-model-invocation: true
---

# 자동 워크플로우

## 사용자 입력

```text
$ARGUMENTS
```

사용자 입력이 비어있지 않다면 **반드시** 고려해야 한다.

---

## 제약사항 (개별 커맨드 대비)

- 단계 간 중간 승인 없음
- 계획은 **단일 커밋**으로 제한 (커밋 분리 없음, 수직 슬라이싱만)
- 마지막에 커밋 메시지 자동 생성
- 그 외 모든 과정은 원본 커맨드와 **완전히 동일** -- 간소화 금지

---

## 문서 구조

```
docs/work/{작업명}/
├── analysis.md             (한글 - workflow-analyze)
├── plan.md                 (한글 - workflow-plan)
└── summary-commit-1.md     (한글 - workflow-execute)

commit_message.md           (commit)
```

---

## 실행

각 스킬 파일을 읽고 순서대로 따른다. 정확한 과정과 템플릿을 이해하기 위해 각 파일을 **반드시** 읽어야 한다.

1. **`.claude.ko/skills/workflow-analyze/SKILL.md`** 읽고 → 전체 과정 실행
2. 멈추지 않고 → **`.claude.ko/skills/workflow-plan/SKILL.md`** 읽고 → 실행 (단일 커밋만)
3. 멈추지 않고 → **`.claude.ko/skills/workflow-execute/SKILL.md`** 읽고 → 커밋 1 실행
4. 멈추지 않고 → **`.claude.ko/skills/commit/SKILL.md`** 읽고 → commit_message.md 생성

**간소화, 단계 생략, 축약 템플릿 사용 금지.** 각 스킬의 정확한 과정을 따른다.
