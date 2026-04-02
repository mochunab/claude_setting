# 나다운세 온톨로지 구축 가이드

> **목적**: 나다운세 서비스의 도메인 지식을 구조화된 그래프(온톨로지)로 구축하고, 네뷸라(Nebula)로 시각화하기 위한 단계별 가이드
> **작성일**: 2026-03-17

---

## 목차

1. [온톨로지를 왜 먼저 설계해야 하나](#1-온톨로지를-왜-먼저-설계해야-하나)
2. [핵심 개념 정리](#2-핵심-개념-정리)
3. [전체 구축 흐름 (8단계)](#3-전체-구축-흐름-8단계)
4. [온톨로지 설계 원칙](#4-온톨로지-설계-원칙)
5. [온톨로지 설계 절차 (7 Step)](#5-온톨로지-설계-절차-7-step)
6. [Active Metadata 4계층](#6-active-metadata-4계층)
7. [문서 파이프라인 설계](#7-문서-파이프라인-설계)
8. [그래프 스키마 설계](#8-그래프-스키마-설계)
9. [그래프 구축 (Neo4J)](#9-그래프-구축-neo4j)
10. [ReBAC 적용 가이드](#10-rebac-적용-가이드)
11. [시각화 설계 가이드](#11-시각화-설계-가이드)
12. [품질 관리 체크리스트](#12-품질-관리-체크리스트)
13. [나다운세 도메인 적용 예시](#13-나다운세-도메인-적용-예시)
14. [기술 스택 & 도구](#14-기술-스택--도구)
15. [피해야 할 실수](#15-피해야-할-실수)
16. [최종 권장안](#16-최종-권장안)
17. [권장 산출물](#17-권장-산출물)
18. [부록 A: 온톨로지 정의 템플릿](#부록-a-온톨로지-정의-템플릿)
19. [부록 B: 초기 워크숍 질문](#부록-b-초기-워크숍-질문)

---

## 1. 온톨로지를 왜 먼저 설계해야 하나

많은 팀이 문서를 수집한 뒤 바로 임베딩하고 검색부터 붙인다.
하지만 이 방식만으로는
"무엇이 중요한 개체인지",
"어떤 관계가 허용되는지",
"에이전트가 어디까지 읽고 행동할 수 있는지"
를 통제하기 어렵다.

**온톨로지는 이 문제를 해결하는 상위 설계도다.**

온톨로지가 있으면:

- 도메인이 바뀌어도 구조가 덜 무너진다
- 엔티티와 관계를 일관되게 추출할 수 있다
- 잘못된 엣지 생성을 줄일 수 있다
- 권한, 검증, 시각화를 같은 기준 위에 올릴 수 있다
- 에이전트가 읽을 세계와 행동할 경계를 명확히 정의할 수 있다

```
온톨로지 없는 에이전트 → 똑똑해 보여도 불안정
에이전트 없는 온톨로지 → 정교해도 정적

둘이 결합할 때 → 살아 움직이는 차세대 AI 업무 시스템
```

즉, 온톨로지는 단순 분류표가 아니라 **지능형 시스템이 작동하는 세계의 문법**이다.

---

## 2. 핵심 개념 정리

### 2-1. Vector (벡터)

텍스트나 객체를 의미 공간상의 좌표로 표현한 것. 주로 **유사도 탐색**에 사용.

- 역할: 비슷한 문서 찾기, 관련 청크 찾기, 후보군 빠르게 좁히기
- 한계: 왜 연결되는지 설명하기 어렵고, 관계의 종류를 표현하는 데 약함

### 2-2. Node (노드)

의미를 가지는 개체. 사람, 문서, 개념, 프로젝트 등 의미를 가진 '하나의 점'.

- 역할: 그래프의 중심 단위, 질의와 추론의 기본 대상

### 2-3. Edge (엣지)

노드와 노드 사이의 관계. 포함한다, 영향을 준다, 설명한다 등 노드 사이의 연결.

- 역할: 연결 구조 설명, 추론 경로 형성, 권한과 영향 범위 계산

### 2-4. Meta-edge (메타엣지)

실제 엣지를 생성할 수 있는 **허용 규칙**. 관계의 문법.

```
실제 엣지 (문장):  John → Project A : 참여한다
메타엣지 (문법):  사람 → 프로젝트 : 참여한다 / 관리한다 관계만 허용
```

- 역할: 그래프 난잡화 방지, 엣지 생성 품질 향상, 잘못된 관계 차단
- **메타엣지가 존재해야만 도메인에 맞는 관계 체계를 유지할 수 있다**
- 그래프는 이 문법으로 쓰인 거대한 문장이다

### 2-5. Meta-ontology (메타온톨로지)

엔티티 타입, 속성, 관계 타입, 관계 허용 범위, 검증 규칙, 운영 기준까지 포함하는 **상위 설계**.

- 온톨로지는 실제 구조, 메타온톨로지는 그 구조를 통제하는 상위 규칙
- **확장성**: 도메인이 바뀌어도 관계 타입과 데이터 구조가 무너지지 않음
- **재사용성**: 한 번 만든 구조를 여러 프로젝트에 이식 가능
- **에이전트 친화성**: 에이전트가 무엇을 읽고, 어디까지 추론해야 하는지 경로를 명확히 제시

### 구성 요소 비교

| 요소 | 설명 | 비유 | 탐색 방식 |
|------|------|------|----------|
| **Vector** | 의미 공간 좌표 | 좌표 | 유사성 탐색 |
| **Node** | 의미적 개체 | 명사 | 직접 조회 |
| **Edge** | 개체 간 관계 | 동사 | 연결성 탐색 |
| **Meta-edge** | 관계의 허용 규칙 | 문법 | 검증 |
| **Meta-ontology** | 상위 설계도 | 헌법 | 통제 |

---

## 3. 전체 구축 흐름 (8단계)

이 흐름은 "문서 검색 시스템"을 만드는 것이 아니라, **"구조화된 의미 세계"를 만드는 과정**으로 이해해야 한다.

```
파싱 → 청킹 → 임베딩/벡터 → 그래프 구조화 → 메타온톨로지 규정 → ReBAC 권한 제어 → 오케스트레이션 → 에이전트 실행
```

| # | 단계 | 설명 | 산출물 |
|---|------|------|--------|
| 1 | **데이터 확보 & 파싱** | 원본 데이터(문서, DB, API)를 구조화된 텍스트로 변환 | 파싱된 텍스트 |
| 2 | **청킹** | 의미 단위로 분할 (문단, 섹션, 개념 단위) | 청크 목록 |
| 3 | **임베딩/벡터** | 청킹된 데이터를 벡터 공간에 배치 | 벡터 DB (ChromaDB) |
| 4 | **엔티티/관계 추출 → 그래프 구조화** | 엔티티와 관계 추출 → 노드와 엣지로 구조화 | 그래프 DB (Neo4J) |
| 5 | **메타온톨로지 규정** | 상위 설계도 정의 (클래스, 허용 관계, 메타엣지) | 온톨로지 스키마 |
| 6 | **ReBAC 권한 제어** | 관계 기반 접근 통제 (누가 무엇에 접근/실행 가능한지) | 권한 그래프 |
| 7 | **오케스트레이션** | LangGraph로 멀티스텝 워크플로우 조직 | 워크플로우 정의 |
| 8 | **시각화 & 에이전트 실행** | 그래프 시각화 + AI 에이전트가 추론·행동 | 시각화 대시보드 |

---

## 4. 온톨로지 설계 원칙

### 원칙 1. 처음부터 크게 만들지 않는다

초기에는 한 도메인만 잡는 것이 좋다.

권장 시작 범위:
- 핵심 엔티티 **10~20개**
- 핵심 관계 **15~30개**
- **필수 속성만** 우선 정의

처음부터 전사 범용 온톨로지를 만들면 정의만 많고 운영은 어려워진다.

### 원칙 2. 명사와 동사를 분리해서 설계한다

- 엔티티는 **명사** 중심
- 관계는 **동사** 중심

```
엔티티: 사용자, 콘텐츠, 상담세션, 결제, 리포트
관계:   생성했다, 조회했다, 속한다, 구매했다, 참조한다
```

이 원칙이 무너지면 그래프 질의와 시각화가 매우 복잡해진다.

### 원칙 3. 속성보다 관계를 먼저 본다

실무에서는 속성을 많이 붙이는 것보다 **어떤 관계가 중요한지** 먼저 정하는 것이 더 중요하다.

예: 문서의 제목보다 → 누가 작성했고, 어떤 프로젝트와 연결되고, 어떤 정책을 참조하는지가 더 큰 의미를 가질 수 있다.

### 원칙 4. 추출 가능성까지 고려한다

좋은 온톨로지는 아름다운 이론이 아니라 **실제로 추출 가능한 구조**여야 한다.

LLM 또는 규칙 기반 파이프라인이 문서에서 안정적으로 뽑아낼 수 있는 단위여야 한다.

### 원칙 5. 권한 확장을 염두에 둔다

처음부터 ReBAC을 완전하게 구축하지 않더라도,
나중에 관계 기반 권한 제어가 가능하도록
**주체, 자원, 소속, 역할, 범위 정보**를 염두에 두고 설계해야 한다.

---

## 5. 온톨로지 설계 절차 (7 Step)

### Step 1. 도메인 정의

먼저 이 그래프가 다룰 세계를 **한 문장으로** 정의한다.

좋은 도메인 정의는 무엇을 포함하고, 무엇을 제외하는지까지 분명해야 한다.

#### 나다운세 대상 도메인 후보

| 도메인 | 범위 | 활용 |
|--------|------|------|
| **서비스 아키텍처** | 컴포넌트, Edge Function, DB, 페이지 간 관계 | 개발 생산성, 영향도 분석 |
| **사주/타로 지식** | 오행, 천간, 지지, 타로 78장, 궁합 관계 | AI 해석 품질 향상, 콘텐츠 자동 생성 |
| **사용자 행동 흐름** | 인증 → 결제 → 콘텐츠 소비 → 나다움 태그 | 퍼널 분석, 개인화 추천 |
| **콘텐츠 관계** | 무료↔유료 매핑, 업셀링, 카테고리 | 추천 시스템 고도화 |

#### 도메인 정의 체크리스트

- [ ] 온톨로지의 **목적**은 무엇인가? (검색? 추천? 분석? 에이전트 추론?)
- [ ] **경계**는 어디까지인가? (서비스 전체? 특정 기능?)
- [ ] **제외 범위**는 무엇인가?
- [ ] 핵심 **사용자/소비자**는 누구인가? (개발자? AI 에이전트? 최종 사용자?)
- [ ] **데이터 소스**는 무엇인가? (코드베이스? DB? 문서? 외부 API?)
- [ ] **주요 질의 예시**는 무엇인가? (실제 업무에서 가장 많이 묻는 질문)

### Step 2. 핵심 엔티티 추출

도메인 안에서 반복적으로 등장하는 개체를 추출한다.

#### 추출 방법

1. **Top-down**: 상위 개념에서 하위로 세분화
2. **Bottom-up**: 실제 데이터(인스턴스)에서 공통 패턴을 추상화
3. **Middle-out**: 핵심 개념부터 시작해 위아래로 확장 (권장)

#### 판별 기준

- 독립적으로 식별 가능한가
- 다른 개체와 관계를 맺는가
- 조회, 분석, 추론의 대상이 되는가

#### 예시: 나다운세 서비스 아키텍처 도메인

```
Level 0 (최상위)
├── Service          # 서비스 전체
│
Level 1 (주요 클래스)
├── Page             # 페이지 (55개)
├── Component        # React 컴포넌트 (72개)
├── EdgeFunction     # Supabase Edge Function (46개)
├── DBTable          # 데이터베이스 테이블
├── Library          # 비즈니스 로직/유틸리티
├── Hook             # Custom React Hook
│
Level 2 (하위 클래스)
├── Page
│   ├── AuthPage         # 인증 관련
│   ├── ContentPage      # 콘텐츠 (무료/유료)
│   ├── ProfilePage      # 프로필/설정
│   └── AdminPage        # 관리자
├── EdgeFunction
│   ├── AIGeneration     # AI 생성 (9개)
│   ├── Payment          # 결제/환불 (5개)
│   ├── Coupon           # 쿠폰 (4개)
│   └── Report           # 주간보고서 (4개)
```

#### 예시: 사주/타로 지식 도메인

```
Level 0
├── Fortune            # 운세 체계
│
Level 1
├── Saju               # 사주
│   ├── Cheongan        # 천간 (10개: 갑을병정무기경신임계)
│   ├── Jiji            # 지지 (12개: 자축인묘진사오미신유술해)
│   ├── Ohaeng          # 오행 (목화토금수)
│   └── Gunghap         # 궁합
├── Tarot              # 타로
│   ├── MajorArcana     # 메이저 아르카나 (22장)
│   ├── MinorArcana     # 마이너 아르카나 (56장)
│   ├── Suit            # 슈트 (완드/컵/소드/펜타클)
│   └── Spread          # 배열법
├── NadaumTag          # 나다움 태그
├── WeeklyReport       # 주간 보고서
```

### Step 3. 속성 정의

각 엔티티에 **꼭 필요한 속성만** 정의한다.

> 속성은 많을수록 좋은 것이 아니다.
> 검색, 정렬, 필터, 권한, 추적에 필요한 것부터 넣어야 한다.

#### 속성 유형

| 유형 | 설명 | 예시 |
|------|------|------|
| **식별 속성** | 고유 식별자 | id, name, slug |
| **기술 속성** | 개체를 설명하는 특성 | description, type, status |
| **수량 속성** | 측정 가능한 값 | price, count, score |
| **시간 속성** | 시점/기간 | created_at, updated_at |
| **참조 속성** | 외부 리소스 링크 | file_path, url |

#### 예시: 클래스별 속성

```yaml
Page:
  - name: string            # 페이지명
  - route: string           # URL 경로
  - file_path: string       # 소스 파일 경로
  - auth_required: boolean  # 인증 필요 여부
  - category: enum          # auth | content | profile | admin

Component:
  - name: string
  - file_path: string
  - props: list             # 받는 props 목록
  - dependencies: list      # 의존하는 라이브러리

EdgeFunction:
  - name: string
  - verify_jwt: boolean     # JWT 검증 여부
  - ai_model: string        # 사용하는 AI 모델
  - category: enum          # ai | payment | coupon | report | etc

TarotCard:
  - name: string            # 카드명
  - number: integer         # 번호
  - arcana: enum            # major | minor
  - suit: enum              # wands | cups | swords | pentacles | null
  - upright_meaning: string # 정방향 의미
  - reversed_meaning: string # 역방향 의미
  - image_path: string      # 이미지 경로
```

### Step 4. 관계 정의

엔티티 사이의 연결을 **동사형으로** 정의한다.

#### 좋은 관계 정의 조건

- 방향성이 분명하다
- 의미가 중복되지 않는다
- 질의에 바로 활용 가능하다

#### 관계 유형

| 관계 유형 | 방향 | 설명 | 예시 |
|----------|------|------|------|
| **포함 (contains)** | A → B | A가 B를 포함 | Page → Component |
| **호출 (calls)** | A → B | A가 B를 호출 | Component → EdgeFunction |
| **의존 (depends_on)** | A → B | A가 B에 의존 | Component → Library |
| **읽기/쓰기 (reads/writes)** | A → B | A가 B를 읽거나 씀 | EdgeFunction → DBTable |
| **연관 (related_to)** | A ↔ B | 양방향 연관 | TarotCard ↔ Ohaeng |
| **생성 (generates)** | A → B | A가 B를 생성 | EdgeFunction → OrderResult |
| **상극/상생 (conflicts/harmonizes)** | A ↔ B | 오행 관계 | 목 → 화 (상생) |

#### 예시: 서비스 아키텍처 관계

```
MasterContentDetailPage  --contains-->  PaymentNew
PaymentNew               --calls-->     process-payment (EdgeFunction)
process-payment          --writes-->    orders (DBTable)
generate-content-answers --reads-->     saju_records (DBTable)
generate-content-answers --writes-->    order_results (DBTable)
generate-content-answers --uses_model-> GPT-5.1
```

#### 예시: 사주/타로 지식 관계

```
목(木)  --상생-->  화(火)       화(火)  --상생-->  토(土)
토(土)  --상생-->  금(金)       금(金)  --상생-->  수(水)
수(水)  --상생-->  목(木)

목(木)  --상극-->  토(土)       화(火)  --상극-->  금(金)
토(土)  --상극-->  수(水)       금(金)  --상극-->  목(木)
수(水)  --상극-->  화(火)

The Fool  --belongs_to-->  MajorArcana
컵 슈트   --element-->     수(水)
```

### Step 5. 메타엣지 정의

어떤 타입끼리 어떤 관계만 허용할지 규정한다.

> **이 단계가 없으면 관계 추출 결과가 쉽게 오염된다.**

```yaml
meta_edges:
  # 소스 클래스 → 타겟 클래스 : 허용되는 관계 타입들
  Page → Component:
    - contains
    - renders

  Component → EdgeFunction:
    - calls
    - triggers

  Component → Library:
    - depends_on
    - imports

  EdgeFunction → DBTable:
    - reads
    - writes
    - deletes

  EdgeFunction → ExternalAPI:
    - calls

  TarotCard → Meaning:
    - upright_means
    - reversed_means

  Ohaeng → Ohaeng:
    - 상생
    - 상극

  # 금지 (이런 관계는 존재할 수 없음)
  # DBTable → Page: ❌ (DB가 페이지를 직접 참조하지 않음)
  # Library → EdgeFunction: ❌ (프론트 라이브러리가 서버 함수를 직접 호출 불가)
```

### Step 6. 추출 규칙 정의

문서에서 엔티티와 관계를 **어떤 기준으로 뽑을지** 정의한다.

- 사람 이름 패턴
- 문서 제목 패턴
- 프로젝트 코드명 패턴
- 날짜와 버전 표현 규칙
- 행위 동사 사전 (승인, 검토, 배포, 호출, 생성, 읽기, 쓰기 등)

### Step 7. 품질 기준 정의

그래프 적재 전 **검증 규칙**을 둔다.

- 필수 속성 누락 금지
- 동일 엔티티 중복 생성 방지
- 허용되지 않은 관계 차단 (메타엣지 규칙 위반)
- 신뢰도 임계값 미만 관계 제외
- 소스 문서 링크 없는 노드 생성 금지

---

## 6. Active Metadata 4계층

노드를 단순 데이터가 아닌 **살아있는 개체(Living Node)**로 만드는 메타데이터 프레임.

이 4계층은 단순 저장이 아니라 **운영과 통제를 위한 기준**이 된다.

### 6-1. Existence (존재)

객체의 존재와 기본 상태

- 존재 여부, 활성/비활성, 삭제 여부, 버전 상태
- 예: 이 Edge Function이 존재하는가? 배포되었는가?

### 6-2. Quality (품질)

신뢰도와 정제 수준

- 검수 완료 여부, 추출 신뢰도, 최신성, 중복 정리 상태
- 예: 이 콘텐츠의 AI 답변 품질 점수는?

### 6-3. Relational (관계)

다른 노드와의 관계 품질과 범위

- 허용 관계 여부, 연결 강도, 관계 타입 적합성, 상위/하위 연결 범위
- 예: 이 컴포넌트가 영향 주는 페이지는 몇 개?

### 6-4. Behavioral (행동)

실제 활용과 상호작용 정보

- 조회 빈도, 변경 빈도, 에이전트 사용 이력, 사용자 상호작용 로그
- 예: 이 Edge Function의 일일 호출 수는? 에러율은?

### 나다운세 적용 예시

```yaml
EdgeFunction: "generate-content-answers"
  Existence:
    deployed: true
    project_ref: kcthtpmxffppfbkjjkub
    verify_jwt: false
  Quality:
    avg_response_time: 3.2s
    error_rate: 0.02
    last_tested: 2026-03-15
  Relational:
    called_by: [LoadingPage, MasterContentDetailPage]
    writes_to: [order_results]
    reads_from: [saju_records, orders, master_contents]
    depends_on: [OpenAI GPT-5.1, SAJU_API]
  Behavioral:
    daily_calls: 150
    peak_hour: 21:00-22:00
    trend: increasing
```

---

## 7. 문서 파이프라인 설계

### 7-1. 데이터 수집

수집 대상부터 명확히 정한다.

- PDF, 마크다운 문서, 노션/위키
- 회의록, 정책 문서, 보고서
- 코드베이스 (소스코드, 설정 파일)
- DB 스키마, API 문서
- 로그 요약본

### 7-2. 파싱

문서 유형별 파싱 전략이 달라야 한다.

| 유형 | 파싱 전략 |
|------|----------|
| PDF | 페이지 구조, 표, 제목 계층 인식 |
| 마크다운 | 헤더 기반 분할 |
| HTML/위키 | 섹션 구조 분리 |
| 소스코드 | AST 파싱, import/export 관계 추출 |

### 7-3. 청킹

청킹은 단순 글자 수 기준보다 **의미 단위 중심**이 좋다.

권장 기준:
- 제목/소제목 단위
- 표와 본문 분리
- 문단 경계 유지
- **소스 문서 위치 정보 보존** (출처 추적용)

### 7-4. 임베딩

청크는 임베딩하여 벡터 검색 후보군으로 사용한다.
단, **벡터는 그래프를 대체하지 않는다**.

```
벡터: 빠른 후보 탐색 (유사성)
그래프: 관계 해석 및 추론 (연결성)
```

### 7-5. 엔티티/관계 추출

청크별로 다음을 추출한다:
- 엔티티 후보 + 엔티티 타입
- 관계 후보 + 근거 문장
- **신뢰도 점수**

### 7-6. 정규화 및 병합

같은 엔티티가 다른 이름으로 들어오는 것을 정리한다.

```
스타지오소프트 / Stargiosoft / stargiosoft  →  Stargiosoft (정규화)
MasterContentDetailPage / 유료 상세 페이지  →  MasterContentDetailPage
```

> **이 단계가 약하면 그래프가 빠르게 오염된다.**
> 초기에 대충 넣고 나중에 합치려 하면 비용이 훨씬 커진다.

---

## 8. 그래프 스키마 설계

### 노드 설계 시 체크포인트

- [ ] 고유 식별자가 있는가
- [ ] 사람이 이해할 이름이 있는가
- [ ] 생성 출처를 추적할 수 있는가
- [ ] 마지막 갱신 시점을 기록하는가
- [ ] 신뢰도 또는 상태를 표시하는가

### 엣지 설계 시 체크포인트

- [ ] 방향성이 필요한가
- [ ] 다대다 관계가 가능한가
- [ ] 시간 정보가 필요한가
- [ ] 관계 근거 문장을 보관할 것인가
- [ ] 사람이 만든 관계와 자동 추출 관계를 구분할 것인가

### 권장 공통 메타데이터

노드/엣지 공통으로 아래 속성을 추천한다.

```yaml
common_metadata:
  - source_id          # 출처 식별자
  - source_type        # 출처 유형 (code | doc | db | manual)
  - created_at         # 생성 시점
  - updated_at         # 갱신 시점
  - confidence         # 신뢰도 (0.0~1.0)
  - created_by         # 생성자 (human | llm | rule)
  - status             # 상태 (active | deprecated | pending)
```

---

## 9. 그래프 구축 (Neo4J)

### 설치 & 기본 설정

```bash
# Neo4J Community Edition (Docker)
docker run -d \
  --name neo4j \
  -p 7474:7474 -p 7687:7687 \
  -e NEO4J_AUTH=neo4j/password \
  neo4j:latest

# 브라우저 접속: http://localhost:7474
```

### Cypher 쿼리 예시 - 노드 생성

```cypher
// 페이지 노드
CREATE (:Page {name: 'HomeScreenNew', route: '/', file_path: '/pages/HomeScreenNew.tsx', auth_required: false, category: 'content', source_type: 'code', confidence: 1.0})
CREATE (:Page {name: 'MasterContentDetailPage', route: '/content/:id', file_path: '/components/MasterContentDetailPage.tsx', auth_required: false, category: 'content'})

// 컴포넌트 노드
CREATE (:Component {name: 'PaymentNew', file_path: '/components/PaymentNew.tsx'})
CREATE (:Component {name: 'BirthInfoInput', file_path: '/components/BirthInfoInput.tsx'})

// Edge Function 노드
CREATE (:EdgeFunction {name: 'generate-content-answers', verify_jwt: false, ai_model: 'GPT-5.1', category: 'ai'})
CREATE (:EdgeFunction {name: 'process-payment', verify_jwt: true, category: 'payment'})

// DB 테이블 노드
CREATE (:DBTable {name: 'orders', description: '결제 주문'})
CREATE (:DBTable {name: 'order_results', description: 'AI 생성 결과'})

// 오행 노드
CREATE (:Ohaeng {name: '목', element: 'Wood', color: 'green'})
CREATE (:Ohaeng {name: '화', element: 'Fire', color: 'red'})
CREATE (:Ohaeng {name: '토', element: 'Earth', color: 'yellow'})
CREATE (:Ohaeng {name: '금', element: 'Metal', color: 'white'})
CREATE (:Ohaeng {name: '수', element: 'Water', color: 'black'})
```

### Cypher 쿼리 예시 - 관계 생성

```cypher
// 페이지 → 컴포넌트 포함
MATCH (p:Page {name: 'MasterContentDetailPage'}), (c:Component {name: 'PaymentNew'})
CREATE (p)-[:CONTAINS]->(c)

// 컴포넌트 → Edge Function 호출
MATCH (c:Component {name: 'PaymentNew'}), (ef:EdgeFunction {name: 'process-payment'})
CREATE (c)-[:CALLS]->(ef)

// Edge Function → DB 읽기/쓰기
MATCH (ef:EdgeFunction {name: 'generate-content-answers'}), (t:DBTable {name: 'order_results'})
CREATE (ef)-[:WRITES]->(t)

// 오행 상생
MATCH (a:Ohaeng {name: '목'}), (b:Ohaeng {name: '화'})
CREATE (a)-[:상생 {description: '목생화'}]->(b)

// 오행 상극
MATCH (a:Ohaeng {name: '목'}), (b:Ohaeng {name: '토'})
CREATE (a)-[:상극 {description: '목극토'}]->(b)
```

### 유용한 조회 쿼리

```cypher
// 특정 Edge Function의 전체 의존 관계 탐색 (3홉까지)
MATCH path = (start)-[*1..3]-(end)
WHERE start.name = 'generate-content-answers'
RETURN path

// 특정 DB 테이블에 쓰는 모든 Edge Function
MATCH (ef:EdgeFunction)-[:WRITES]->(t:DBTable {name: 'orders'})
RETURN ef.name

// 페이지에서 최종 DB까지의 전체 경로
MATCH path = (p:Page)-[:CONTAINS]->(:Component)-[:CALLS]->(:EdgeFunction)-[:WRITES]->(t:DBTable)
RETURN path

// 고아 노드 찾기 (관계가 없는 노드)
MATCH (n) WHERE NOT (n)--() RETURN n

// 허브 노드 찾기 (연결이 가장 많은 노드)
MATCH (n)-[r]-() RETURN n.name, labels(n), count(r) as connections ORDER BY connections DESC LIMIT 10
```

---

## 10. ReBAC 적용 가이드

> GraphRAG가 세계의 의미를 만든다면, ReBAC은 그 세계의 경계를 만든다

초기에는 ReBAC을 너무 크게 시작하지 않는 것이 좋다. 하지만 나중을 위해 **구조는 열어두어야** 한다.

### ReBAC의 핵심 질문

- **누가** (주체)
- **어떤 관계를 통해** (경로)
- **어떤 자원에** (대상)
- **어디까지** 접근하고 행동할 수 있는가 (범위)

### 3계층 구조

```
Semantic Graph (온톨로지)     → 정적 지식 구조 (하단)
Permission Graph (ReBAC)     → 권한 제어 계층 (중단)
Agent                        → 추론 + 행동 (상단)

에이전트는 두 그래프를 모두 읽고, 자신이 통과할 수 있는 경계 내에서만 행동한다.
```

### 설계 원칙

- 역할만 보지 말고 **관계**도 본다
- 조회 권한과 수정 권한을 **구분**한다
- 노드 권한과 엣지 권한을 **분리**할 수 있게 한다
- 에이전트 행동 권한은 더 **보수적**으로 둔다

### 최소 적용 예시

```
사용자 → 콘텐츠 : 조회 가능
크리에이터 → 콘텐츠 : 편집 가능
관리자 → 통계 : 열람 가능
에이전트 → 콘텐츠 생성 : 실행 가능 (검증 후)
```

### 초기 MVP 권장 범위

- 공개/비공개 구분
- 프로젝트 소속 기반 접근
- 역할 기반 수정 권한
- 민감 데이터 차단

---

## 11. 시각화 설계 가이드

시각화는 예쁜 그래프를 그리는 일이 아니다.
**무엇을 탐색하게 할 것인지** 먼저 정해야 한다.

### 시각화 목적별 4유형

#### 1) 운영자 탐색용

- 검색, 필터
- 노드 상세 패널
- 관계 하이라이트
- 출처 문서 확인

#### 2) 분석/리포트용

- 중심 노드 분석
- 군집 보기
- 관계 밀도 보기
- 시계열 변화

#### 3) 에이전트 디버깅용

- 사용한 노드 표시
- 추론 경로 표시
- 차단된 권한 표시
- 사용된 문서 근거 표시

#### 4) 최종 사용자용

- 복잡한 전체 그래프보다 **설명형 카드**
- 관련 항목 추천
- 핵심 연결만 요약

### 좋은 시각화의 기준

- 노드가 많아도 **핵심이 보인다**
- 왜 연결됐는지 **설명 가능**하다
- **출처 추적**이 가능하다
- 권한에 따라 보이는 범위가 달라진다

### 시각화 도구 옵션

| 도구 | 특징 | 적합한 경우 |
|------|------|-----------|
| **NebulaGraph Explorer** | 공식 시각화 도구, 대규모 그래프 탐색 | 수천~수만 노드 |
| **Nebula.js** | 시각화 라이브러리 (커스터마이징) | 웹 앱 내장 |
| **Langent Nebula** | Hybrid/Graph/Vector 뷰, LLM 연동 | AI 에이전트 + 시각화 통합 |
| **Neo4J Browser** | Neo4J 내장 시각화 | 빠른 프로토타이핑 |
| **Neo4J Bloom** | 비개발자용 탐색 도구 | 비즈니스 사용자 |

### 시각화 렌더링 설정

- **노드 크기**: Behavioral 메타데이터(호출 빈도) 기반 크기 조절
- **엣지 굵기**: 관계 강도/빈도 반영
- **색상 코딩**: 클래스별 색상 (Page=파랑, Component=초록, EdgeFunction=주황 등)
- **클러스터링**: 관련 노드를 자동 그룹핑 (기능별, 도메인별)
- **필터링**: 특정 계층/관계만 표시하는 뷰 모드

### 시각화 도구 연계 시 체크리스트

#### 데이터 측면
- [ ] 노드/엣지 스키마가 안정적인가
- [ ] ID 체계가 일관적인가
- [ ] 노드 라벨과 관계 라벨이 정규화됐는가
- [ ] 중복 엔티티가 정리됐는가

#### UX 측면
- [ ] 검색 결과에서 그래프로 이동 가능한가
- [ ] 그래프에서 소스 문서로 다시 이동 가능한가
- [ ] 상세 패널에서 속성, 관계, 출처를 함께 보여주는가

#### 운영 측면
- [ ] 새 문서 유입 시 자동 갱신 가능한가
- [ ] 삭제/수정 시 그래프 동기화 가능한가
- [ ] 권한에 따라 시각화 범위를 줄일 수 있는가

---

## 12. 품질 관리 체크리스트

아래 항목을 주기적으로 점검해야 한다.

### 데이터 품질

- [ ] 동일 엔티티 중복 생성 여부
- [ ] 잘못된 타입 분류 여부
- [ ] 누락된 필수 속성 여부
- [ ] 비정상 관계 생성 여부

### 그래프 품질

- [ ] 허용되지 않은 관계 존재 여부
- [ ] 고아 노드 비율 (관계 없는 노드)
- [ ] 지나치게 연결된 허브 노드 존재 여부
- [ ] 너무 세분화된 불필요 노드 존재 여부

### 운영 품질

- [ ] 최신 문서 반영 지연 여부
- [ ] 잘못된 권한 노출 여부
- [ ] 추론 실패 시 원인 추적 가능 여부

---

## 13. 나다운세 도메인 적용 예시

### 도메인 A: 유료 콘텐츠 결제 플로우

```
[MasterContentDetailPage]
  ├──contains→ [PaymentNew]
  │              ├──calls→ [process-payment] ──writes→ [orders]
  │              └──contains→ [CouponBottomSheetNew]
  │                            └──calls→ [apply-coupon-to-order]
  ├──contains→ [BirthInfoInput]
  ├──navigates→ [LoadingPage]
  │              └──polls→ [orders.ai_generation_completed]
  └──navigates→ [UnifiedResultPage]
                  └──reads→ [order_results]
```

### 도메인 B: 오행 상생/상극 관계 그래프

```
        상생 (시계방향)
    목 ──→ 화 ──→ 토 ──→ 금 ──→ 수
    ↑                              │
    └──────────────────────────────┘

        상극 (별 모양)
    목 ──→ 토      화 ──→ 금
    토 ──→ 수      금 ──→ 목
    수 ──→ 화
```

### 도메인 C: 에이전트 분업 체계 (향후)

```
Agent (판단: 전체 목표 수립, 도구 선택)
├── Sub-agent: 사주 해석 (generate-saju-answer)
├── Sub-agent: 타로 해석 (generate-tarot-answer)
├── Sub-agent: 나다움 분석 (generate-nadaum-analysis)
└── Skills
    ├── 콘텐츠 추천 (consultRecommendationService)
    ├── 쿠폰 발급 (issue-welcome-coupon)
    └── 알림톡 발송 (send-alimtalk)
```

### 최소 MVP 구성 (초기 권장)

```yaml
엔티티 (10~15개):
  - User, Creator, Content, Product
  - SajuRecord, TarotCard, Ohaeng
  - Order, Report, Session

관계 (15~20개):
  - Creator CREATED Content
  - User PURCHASED Product
  - Content GENERATED Report
  - User PARTICIPATED_IN Session
  - EdgeFunction READS/WRITES DBTable
  - Component CALLS EdgeFunction
  - Ohaeng 상생/상극 Ohaeng

필수 속성:
  - 모든 노드: id, name, status, source_type, confidence
  - Content: title, category, price
  - EdgeFunction: verify_jwt, ai_model, category
```

이 정도만 있어도 초기 그래프 탐색, 기본 질의, 간단한 시각화까지 충분히 가능하다.

---

## 14. 기술 스택 & 도구

| 단계 | 도구 | 용도 |
|------|------|------|
| 파싱/청킹 | LangChain, 커스텀 파서 | 문서/코드 → 구조화된 청크 |
| 임베딩 | OpenAI Embeddings, ChromaDB | 벡터 저장소 |
| 그래프 DB | **Neo4J** | 노드/엣지 저장, Cypher 쿼리 |
| 온톨로지 스키마 | YAML/JSON 정의 | 메타온톨로지, 메타엣지 규칙 |
| 시각화 | **NebulaGraph** / Neo4J Browser | 그래프 탐색 및 시각화 |
| 오케스트레이션 | **LangGraph** | 멀티스텝, 분기 가능 워크플로우 |
| 권한 제어 | **ReBAC** | 관계 기반 접근 통제 |

### LangChain vs LangGraph

| | LangChain | LangGraph |
|---|-----------|-----------|
| 구조 | 체인 (순차 연결) | 그래프 (분기/병렬) |
| 역할 | LLM + Tool + Prompt 연결 | 멀티스텝 워크플로우 오케스트레이션 |
| 적합 | 단순 파이프라인 | 상태 기반, 조건 분기가 필요한 복잡 작업 |

---

## 15. 피해야 할 실수

### 실수 1. 모든 것을 엔티티로 만들기
의미가 약한 항목까지 노드로 만들면 그래프가 급격히 복잡해진다.

### 실수 2. 관계 이름을 일관성 없이 만들기
"참여", "참여함", "참여했다" 같은 중복 표현은 반드시 정리해야 한다.

### 실수 3. 출처를 저장하지 않기
근거 문장과 원문 링크가 없으면 운영 단계에서 신뢰를 잃는다.

### 실수 4. 중복 정규화를 뒤로 미루기
초기에 대충 넣고 나중에 합치려 하면 비용이 훨씬 커진다.

### 실수 5. 시각화 목적 없이 그래프부터 그리기
시각화는 사용 목적이 정해져야 좋은 UX가 나온다.

---

## 16. 최종 권장안

온톨로지 구축의 핵심은 많이 만드는 것이 아니라 **정확한 문법을 먼저 세우는 것**이다.

### 권장 구축 순서

| 순서 | 단계 | 설명 |
|------|------|------|
| 1 | 최소 도메인 온톨로지 정의 | 한 개 도메인, 핵심 엔티티/관계만 |
| 2 | 문서 파이프라인 구축 | 파싱→청킹→임베딩→추출→정규화 안정화 |
| 3 | 그래프 DB 적재 | 단순 노드/엣지, 중복 병합과 출처 추적 |
| 4 | 메타엣지 규칙 적용 | 허용 관계만 생성되도록 검증 레이어 |
| 5 | 기본 시각화 연결 | 탐색 UI로 실제 사용자가 그래프 이해 |
| 6 | 권한 구조 적용 | 소속/역할/민감도 기반 접근 범위 제어 |
| 7 | 에이전트 연결 | 권한 그래프 안에서만 읽고 행동 |

### 핵심 체크

- [ ] 한 개 도메인만 선택한다
- [ ] 핵심 엔티티 10~20개만 정의한다
- [ ] 관계는 실무 질의에 필요한 것만 남긴다
- [ ] 메타엣지로 허용 관계를 통제한다
- [ ] 출처와 신뢰도를 반드시 저장한다
- [ ] 시각화 목적을 먼저 정한 뒤 UI를 붙인다
- [ ] ReBAC과 에이전트는 구조를 열어두되 단계적으로 적용한다

---

## 17. 권장 산출물

온톨로지 구축 작업에서 반드시 남겨야 할 산출물:

### 17-1. 도메인 정의서
- 목적, 범위, 제외 범위, 주요 사용자, 주요 질의 예시

### 17-2. 엔티티 사전
- 엔티티명, 설명, 식별자, 필수/선택 속성, 예시

### 17-3. 관계 사전
- 관계명, 시작/종료 엔티티, 방향성, 설명, 생성 조건, 예시 문장

### 17-4. 메타엣지 규칙표
- 허용/금지 관계, 다중성, 역방향 허용 여부, 검증 규칙

### 17-5. 데이터 추출 명세서
- 입력 데이터 유형, 파싱/청킹 방식, 엔티티/관계 추출 방식, 예외 처리

### 17-6. 품질 검증 체크리스트
- 중복 제거, 정규화, 누락 검사, 신뢰도 기준, 표본 검수 절차

---

## 부록 A: 온톨로지 정의 템플릿

### 엔티티 템플릿

```yaml
entity:
  name:                # 엔티티명
  description:         # 설명
  identifier:          # 고유 식별자
  required_attrs:      # 필수 속성
  optional_attrs:      # 선택 속성
  example:             # 인스턴스 예시
  creation_rule:       # 생성 규칙
  dedup_rule:          # 중복 병합 규칙
```

### 관계 템플릿

```yaml
relation:
  name:                # 관계명 (동사형)
  source_entity:       # 시작 엔티티
  target_entity:       # 종료 엔티티
  direction:           # 방향성 (uni | bi)
  description:         # 설명
  required_attrs:      # 필수 속성
  creation_condition:  # 생성 조건
  prohibition:         # 금지 조건
  example_sentence:    # 예시 문장
```

### 메타엣지 템플릿

```yaml
meta_edge:
  source_type:         # 시작 엔티티 타입
  target_type:         # 종료 엔티티 타입
  allowed_relations:   # 허용 관계 목록
  prohibited_relations: # 금지 관계 목록
  cardinality:         # 다중성 (1:1 | 1:N | N:M)
  reverse_allowed:     # 역방향 허용 (true | false)
  validation_rule:     # 검증 규칙
```

---

## 부록 B: 초기 워크숍 질문

온톨로지 설계 워크숍에서 아래 질문으로 시작하면 좋다.

1. 이 도메인에서 **반드시 추적해야 하는 개체**는 무엇인가
2. 실제 업무에서 **가장 많이 묻는 질문**은 무엇인가
3. **어떤 관계를 알면** 의사결정이 쉬워지는가
4. **어떤 잘못된 관계**가 생기면 큰 문제가 되는가
5. **어떤 데이터는 누구에게** 보여주면 안 되는가
6. 최종 시각화는 **누가 어떤 목적**으로 사용할 것인가

이 질문에 답이 정리되면, 온톨로지는 훨씬 빠르고 정확하게 설계된다.

---

## 참고 자료

- MetaOntology OS 발표 자료 (NotebookLM)
- @AlexAI_la 8단계 로드맵
- NebulaGraph 공식 문서
- Neo4J Cypher 매뉴얼
- LangGraph 공식 문서

---

**최종 업데이트**: 2026-03-17
