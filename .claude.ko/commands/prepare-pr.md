---
allowed-tools: Bash(git:*), Write
description: 여러 커밋을 분석하여 PR 제목과 설명 생성 (한국어/영어)
argument-hint: [BASE-BRANCH (기본값: 자동 감지)]
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

## 이 명령의 기능

1. 베이스 브랜치(main/master) 자동 감지 또는 인자로 지정된 브랜치 사용
2. 베이스부터 현재 HEAD까지 모든 커밋 수집
3. 커밋 메시지와 변경 파일 분석
4. 통합된 PR 제목 생성 (Conventional Commits 스타일)
5. 요약, 변경사항, 관련 이슈를 포함한 PR 설명 생성
6. **pr_content.md 파일로 저장하여 복사하기 편리하게 제공**

## 이 명령을 사용해야 할 때

| 상황               | 권장사항                                           |
| ------------------ | -------------------------------------------------- |
| 단일 커밋 PR       | 커밋 메시지 그대로 사용 (GitHub이 자동으로 처리함) |
| **다중 커밋 PR**   | **이 명령 사용** - 변경사항 통합                   |
| 대규모 기능 브랜치 | 이 명령 사용 - 모든 작업 요약                      |

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

### 제목 작성 가이드라인

- **50자 이하** (GitHub이 긴 제목은 잘라냄)
- 구현 세부사항 대신 **사용자 관점의 가치**에 집중
- 명령형 사용: "기능 추가"가 아닌 "add feature"

**예시:**

- ✅ `feat: OAuth2를 통한 사용자 인증 기능 추가`
- ✅ `fix: 대시보드 메모리 누수 해결`
- ❌ `파일 업데이트` (너무 모호함)
- ❌ `feat: Google과 GitHub 프로바이더 및 세션 관리를 포함한 OAuth2 인증 플로우 구현` (너무 김)

## PR 본문 형식

### 요약 섹션

전체 변경 내용과 목적을 설명하는 1-3문장.

### 변경사항 섹션

- 주요 변경사항을 글머리 기호로 정리
- 변경사항이 많으면 카테고리별로 그룹화
- **어떻게** 했는지가 아닌 **무엇을** 변경했는지에 집중

### 관련 이슈 섹션

- 브랜치명과 커밋에서 이슈 번호 추출
- `fix #N` 형식 사용 (commit.md와 일관성 유지)

### 테스트 계획 섹션 (선택)

- 변경사항이 제대로 작동하는지 확인하는 방법
- 비자명한 테스트가 필요한 경우에만 포함

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

### 테스트 계획

{테스트 방법 - 필요시만}

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

### Test Plan

{How to test - if needed}
```

## 이슈 번호 감지

이슈 번호 추출 위치:

1. **브랜치명**: `feature/123-add-auth` → `#123`
2. **커밋 메시지**: `fix: 버그 수정 (fix #456)` → `#456`
3. **브랜치 패턴**: `develop/user/42`, `issue-42-fix` → `#42`

## 중요 사항

- 이 명령은 PR 내용만 생성하며 - 실제 PR을 생성하지 않는다
- **pr_content.md 파일에 두 버전 모두 저장** - 원하는 것 선택하여 사용
- 단일 커밋 PR의 경우 커밋 메시지를 직접 사용하는 것을 고려
- 브랜치명에 이슈 번호가 포함되어 있으면 자동 감지됨
- 생성된 파일에서 내용 복사 후 GitHub PR 폼에 붙여넣기
- CLI 워크플로우의 경우 생성된 내용으로 `gh pr create` 사용

## Claude 실행 지침

1. **베이스 브랜치 결정**:
   - 인자가 제공되면 사용: `$ARGUMENTS`
   - 그렇지 않으면: `origin/HEAD`, `origin/main`, 또는 `origin/master`에서 감지

2. **커밋 정보 수집**:
   - 실행: `git log --oneline {base}..HEAD`
   - 실행: `git log --pretty=format:"%s" {base}..HEAD` (전체 메시지용)
   - 실행: `git diff --stat {base}..HEAD` (변경 파일용)

3. **커밋 분석**:
   - 커밋 타입 카운트 (feat, fix, docs 등)
   - 빈도 기반으로 주요 타입 식별
   - 커밋들이 공통 scope를 공유하면 scope 추출

4. **이슈 번호 추출**:
   - 브랜치명에서 (현재 브랜치)
   - 커밋 메시지에서 (fix #N, closes #N 패턴)

5. **PR 제목 생성**:
   - 주요 타입 사용
   - 전체 변경사항을 50자 이하로 요약
   - 사용자 가치에 집중

6. **PR 본문 생성**:
   - 요약: 무엇을 왜
   - 변경사항: 주요 수정 내용 (3-7개 글머리 기호)
   - 이슈: 감지된 모든 이슈 번호
   - 테스트 계획: 비자명한 경우에만

7. **두 버전 생성**:
   - 한국어 버전 먼저
   - 영어 버전 다음

8. **파일 저장**:
   - `/workspaces/ai-config-toolkit/pr_content.md`에 저장
   - 기존 파일 덮어쓰기

**토큰 최적화**:

- 전체 diff가 아닌 커밋 메시지에 집중
- 파일 변경사항을 카테고리별로 요약
- 커밋이 많은 브랜치는 최근 20개로 제한
