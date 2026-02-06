---
name: prepare-pr
description: 여러 커밋을 분석하여 PR 제목과 설명 생성 (한국어/영어). 단일 커밋 PR은 커밋 메시지를 직접 사용할 것.
allowed-tools: Bash(git:*), Write
disable-model-invocation: true
---

# Pull Request 내용 생성기

현재 브랜치와 베이스 브랜치 사이의 모든 커밋을 분석하여 PR 제목과 설명을 생성합니다. **한국어와 영어 버전 모두 생성하여 편리하게 복사할 수 있습니다.**

## 저장소 상태 분석

- Git 상태: !git status --porcelain
- 현재 브랜치: !git branch --show-current
- 기본 브랜치: !git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "main"
- 원격 브랜치: !git branch -r --list 'origin/main' 'origin/master' 2>/dev/null
- 분기 이후 커밋: !git log --oneline origin/HEAD..HEAD 2>/dev/null || git log --oneline origin/main..HEAD 2>/dev/null || git log --oneline origin/master..HEAD 2>/dev/null || echo "베이스 브랜치 감지 불가"
- 변경 파일 요약: !git diff --stat origin/HEAD..HEAD 2>/dev/null || git diff --stat origin/main..HEAD 2>/dev/null || git diff --stat origin/master..HEAD 2>/dev/null

## PR 제목 형식 (Conventional Commits)

```
<type>[(optional scope)]: <description>
```

### PR용 타입 선택

모든 커밋을 분석하여 주요 타입 선택:

| 패턴                     | PR 타입              |
| ------------------------ | -------------------- |
| `feat` 커밋이 대부분     | `feat`               |
| `fix` 커밋이 대부분      | `fix`                |
| `feat`와 `fix` 혼합      | `feat` (기능이 우선) |
| `docs` 커밋만 있음       | `docs`               |
| `chore`/`ci` 커밋만 있음 | `chore`              |
| `refactor` 중심          | `refactor`           |

**우선순위**: `feat` > `fix` > `refactor` > `perf` > `docs` > `chore`

## 출력 템플릿

```markdown
## PR 제목 (한국어)

{type}: {한글 제목}

## PR 제목 (영어)

{type}: {English title}

---

## PR 본문 (한국어)

### 요약

{변경사항 요약 1-3문장}

### 주요 변경사항

- {변경사항 1}
- {변경사항 2}
- {변경사항 3}

### 관련 이슈

fix #{issue_number}

---

## PR 본문 (영어)

### Summary

{1-3 sentence summary of changes}

### Changes

- {Change 1}
- {Change 2}
- {Change 3}

### Related Issues

fix #{issue_number}
```

## 중요 사항

- 이 명령은 PR 내용만 생성하며 -- 실제 PR을 생성하지 않는다
- **pr_content.md 파일에 두 버전 모두 저장** -- 원하는 것 선택하여 사용
- 브랜치명 이슈 번호 자동 감지
- CLI 워크플로우: 생성된 내용으로 `gh pr create` 사용

## 실행

1. 베이스 브랜치 결정 (인자 또는 origin/HEAD에서 자동 감지)
2. git log, git diff로 커밋 정보 수집
3. 커밋 분석: 타입 카운트, 주요 타입 식별, 스코프 및 이슈 번호 추출
4. PR 제목(≤50자) 및 본문 생성 (한국어/영어 양쪽)
5. `pr_content.md`에 작성
