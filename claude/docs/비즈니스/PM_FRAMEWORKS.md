# PM 프레임워크 레퍼런스

> 제품 전략, GTM, 가격 책정, 디스커버리에 필요한 핵심 프레임워크 모음
> 출처: phuryn/pm-skills (MIT), Product Compass
> 기존 AARRR_FUNNEL_STRATEGY.md(퍼널), UNIVERSAL_GROWTH_FORMULA.md(성장 엔진)와 상호 보완
> 최종 업데이트: 2026-04-03

---

## 1. Value Proposition — 6파트 JTBD 템플릿

고객 가치를 명확히 정의하는 프레임워크. Strategyzer 캔버스보다 단순하고 액셔너블.

| 파트 | 질문 | 예시 (Canva) |
|------|------|-------------|
| **Who** | 누구를 위한 것인가? | 디자인 비전문가 |
| **Why** | 고객의 핵심 문제/JTBD? | 전문적 디자인이 필요하지만 도구가 어려움 |
| **What Before** | 현재 어떻게 해결하는가? | PPT, 포토샵(복잡), 외주(비쌈) |
| **How** | 어떻게 해결하는가? | 드래그&드롭 템플릿, AI 디자인 |
| **What After** | 해결 후 달라지는 것? | 몇 분 만에 프로 수준 디자인, 비용 절감 |
| **Alternatives** | 왜 우리를 선택하는가? | 포토샵보다 쉽고, 외주보다 빠르고 쌈 |

**최종 산출물**: 1~2문장 Value Proposition Statement (마케팅/세일즈/온보딩에 즉시 사용 가능)

**팁**: 세그먼트별로 별도 VP를 작성. VP가 강할수록 마케팅/세일즈/제품 결정이 쉬워짐.

---

## 2. Lean Canvas — 비즈니스 가설 검증

린 스타트업 방식으로 비즈니스 모델 가설을 빠르게 테스트.

### 9칸 구조

```
┌──────────────┬──────────────┬──────────────┐
│   Problem    │   Solution   │     UVP      │
│  (Top 3)     │  (Top 3)     │ (한 문장)     │
├──────────────┼──────────────┼──────────────┤
│  Unfair      │   Customer   │   Channels   │
│  Advantage   │  Segments    │              │
├──────────────┼──────────────┴──────────────┤
│  Key Metrics │                             │
├──────────────┤  Cost Structure / Revenue   │
│  (NSM 포함)   │  Streams                    │
└──────────────┴─────────────────────────────┘
```

**한계 (알고 쓸 것)**:
- Problem ↔ Segments, Solution ↔ VP 중복 발생
- 비전, 트레이드오프, 상대적 비용 누락
- 단일 "Unfair Advantage"로는 방어력 설명 부족
- **용도**: 빠른 가설 테스트용 브레인스토밍 도구. 전략 문서로는 부족.

---

## 3. North Star Metric — 지표 프레임워크

하나의 고객 중심 KPI로 조직 전체를 정렬.

### 3가지 비즈니스 게임

| 게임 | 측정 대상 | 예시 |
|------|----------|------|
| **Attention** | 사용 시간 | YouTube, TikTok, Spotify |
| **Transaction** | 거래 횟수 | Amazon, Uber, Airbnb |
| **Productivity** | 효율성 | Canva, Notion, Loom |

### NSM 7가지 검증 기준

1. **이해하기 쉬운가** — 조직 전체가 이해
2. **고객 중심인가** — 매출/활동이 아닌 고객 가치 반영
3. **지속 가능한 가치인가** — 장기 습관과 인게이지먼트
4. **비전 정렬인가** — 회사 미션 방향과 일치
5. **정량적인가** — 명확한 숫자로 추적 가능
6. **행동 가능한가** — 팀이 직접 영향을 줄 수 있음
7. **선행 지표인가** — 미래 매출/성장을 예측

**NSM이 아닌 것**: 매출/LTV(고객 중심이어야 함), OKR(그건 목표 설정), 전략 자체(전략적 선택이긴 함)

**구조**: NSM 1개 + Input Metrics 3~5개 (NSM을 직접 움직이는 선행 지표)

---

## 4. Growth Loops — 5가지 성장 루프

유료 광고에 의존하지 않는 제품 내재적 성장 메커니즘.
> 기존 UNIVERSAL_GROWTH_FORMULA.md의 ③확산 설계, ⑤잠금 설계와 연결

| 루프 | 메커니즘 | 예시 | 강점 | 난점 |
|------|---------|------|------|------|
| **Viral** | 유저 콘텐츠 → 외부 공유 → 신규 유입 | Figma, Loom | 지수적 성장 | 공유 인센티브 필요 |
| **Usage** | 생성 → 공유 → 소비 → 생성 반복 | Twitter, Medium | 사용=성장 | 생성 마찰 낮아야 함 |
| **Collaboration** | 동료 초대 → 조직 내 확산 | Google Docs, Slack | 강한 리텐션 | 협업 제품에만 적합 |
| **UGC** | 콘텐츠 발견 → 유사 콘텐츠 생성 → 확산 | TikTok, Pinterest | 콘텐츠 플라이휠 | 임계 질량 필요 |
| **Referral** | 추천 → 가입 → 보상 → 재추천 | Dropbox, Uber | 측정 용이 | 유닛 이코노미 주의 |

**실행 순서**:
1. 제품에 가장 자연스러운 루프 1개 선택
2. 루프 계수 측정 (유저당 초대 수 × 전환율)
3. 최적화 후 2번째 루프 레이어링

---

## 5. Ideal Customer Profile (ICP) — 고객 프로파일링

가장 가치 있는 고객을 정의하는 4가지 차원.

### 4가지 분석 축

| 축 | 핵심 질문 | 분석 포인트 |
|----|----------|------------|
| **Demographics** | 누구인가? | 회사 규모, 산업, 직책, 경험 |
| **Behaviors** | 어떻게 일하고 결정하는가? | 솔루션 탐색 방식, 의사결정 속도, 기술 리터러시 |
| **JTBD** | 무엇을 달성하려 하는가? | 기능적/감정적/사회적 Job, 성공 기준 |
| **Pain Points** | 어떤 문제를 겪는가? | 현재 워크어라운드, 비용/시간 부담, 감정적 좌절 |

### ICP 식별 프로세스

```
고객 데이터 수집 → 가치 기준 세그먼팅 (LTV, 리텐션, 확장)
  → Demographics 패턴 추출 → Behaviors 매핑
  → JTBD 정의 → Pain Points 종합
  → ICP 문서화 + 탈락 기준 정의
```

**핵심**: ICP는 "최고의 고객"과 "적합하지 않은 고객"을 동시에 정의. 분기별 재검토.

---

## 6. GTM Strategy — 시장 진출 전략

제품 런칭 시 채널, 메시징, KPI, 타임라인을 종합 설계.

### 5단계 프로세스

1. **리서치 수집** — 제품, 타겟, 시장, 경쟁 데이터
2. **채널 선택** — 디지털/콘텐츠/세일즈/커뮤니티/PLG 채널 평가
3. **메시징 개발** — VP 기반 세그먼트별 메시지, 차별점, 채널별 변형
4. **KPI 정의**
   - Awareness: 노출, 도달, 브랜드 인지
   - Engagement: CTR, CPC, 체류 시간
   - Conversion: 가입, 데모, 트라이얼
   - Revenue: MRR, CAC, LTV
5. **런칭 플랜** — Pre-launch → Launch Day → Post-launch → 최적화 사이클

**팁**: 채널 3개 이내에 집중. 많은 채널을 평범하게 < 적은 채널을 탁월하게.

---

## 7. Pricing Strategy — 가격 전략

가치 기반 가격 설계 + 경쟁 분석 + 실험 계획.

### 7가지 프라이싱 모델

| 모델 | 적합한 제품 | 예시 |
|------|-----------|------|
| **Flat-rate** | 단순 제품, 예측 가능한 비용 | Basecamp |
| **Per-seat** | 협업 도구, 팀 제품 | Slack, Figma |
| **Usage-based** | 인프라, API | AWS, Twilio |
| **Tiered** | 뚜렷한 유저 세그먼트 | 대부분 SaaS |
| **Freemium** | 바이럴/네트워크 효과 제품 | Spotify, Notion |
| **Freemium + Usage** | 플랫폼 | Vercel, OpenAI |
| **Value-based** | 고임팩트 엔터프라이즈 | Salesforce |

### 설계 체크리스트

- [ ] 핵심 가치 정량화 (시간 절약, 매출 증가, 비용 절감)
- [ ] 고객의 대안과 그 비용 파악
- [ ] Value Metric 선택 (유저, 이벤트, 저장공간, API 호출)
- [ ] 2~4개 티어, 명확한 차별화
- [ ] 앵커 프라이싱 (가장 인기 있는 티어 = 당연한 선택)
- [ ] 연간 할인 15~20%
- [ ] A/B 테스트 계획

---

## 8. Opportunity Solution Tree (OST) — 디스커버리 구조화

Teresa Torres의 Continuous Discovery Habits 기반. 결과 → 기회 → 솔루션 → 실험을 트리 구조로 연결.

### 4계층 구조

```
Desired Outcome (측정 가능한 목표 1개)
  ├── Opportunity A (고객 관점 니즈/페인)
  │     ├── Solution A-1
  │     │     └── Experiment (가설, 방법, 지표, 성공 기준)
  │     ├── Solution A-2
  │     └── Solution A-3
  ├── Opportunity B
  │     ├── Solution B-1
  │     └── Solution B-2
  └── Opportunity C
        └── ...
```

### 핵심 원칙

- **한 번에 하나의 Outcome** — 모든 걸 동시에 해결하려 하지 않음
- **Opportunity ≠ Feature** — 고객의 문제/니즈이지, 솔루션이 아님
- **솔루션은 3개 이상** — 첫 번째 아이디어 함정 방지
- **Opportunity Score**: Importance × (1 − Satisfaction) — 중요하지만 불만족인 기회 우선
- **Product Trio**: PM + 디자이너 + 엔지니어가 함께 아이디에이션 ("최고의 아이디어는 엔지니어에게서 나옴")
- **실험은 Skin-in-the-game** 기반 — 의견 기반 검증보다 행동 기반 검증

---

## 프레임워크 매핑 — 언제 뭘 쓰는가

| 단계 | 프레임워크 | 핵심 질문 |
|------|----------|----------|
| 아이디어 검증 | Lean Canvas | "이 사업이 성립하는가?" |
| 고객 정의 | ICP | "최고의 고객은 누구인가?" |
| 가치 정의 | Value Proposition | "왜 고객이 우리를 선택하는가?" |
| 디스커버리 | OST | "무엇을 만들어야 하는가?" |
| 지표 설계 | North Star Metric | "무엇을 측정해야 하는가?" |
| 시장 진출 | GTM Strategy | "어떻게 고객에게 도달하는가?" |
| 가격 설계 | Pricing Strategy | "얼마를 받아야 하는가?" |
| 성장 설계 | Growth Loops | "어떻게 유료 없이 성장하는가?" |
