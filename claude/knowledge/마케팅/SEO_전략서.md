# 범용 SEO 전략서

> 어떤 웹 프로젝트에든 적용 가능한 SEO 체크리스트 & 실행 가이드
> 최종 업데이트: 2026-04-03

---

## 1. SEO 기반 설정 (Day 1)

### 1.1 필수 파일

| 파일 | 역할 | 핵심 포인트 |
|------|------|-------------|
| `robots.txt` | 크롤러 접근 제어 | Allow/Disallow 접두사 매칭 주의, 구체적 경로를 먼저 선언 |
| `sitemap.xml` | 페이지 목록 제출 | `<lastmod>` 필수, 동적 콘텐츠는 빌드/배포 시 자동 생성 |
| `rss.xml` | 콘텐츠 피드 | 네이버 서치어드바이저 RSS 제출용, 최신 콘텐츠 노출 가속 |

### 1.2 검색엔진 등록

| 검색엔진 | 등록처 | 필수 작업 |
|----------|--------|-----------|
| Google | [Search Console](https://search.google.com/search-console) | 소유권 인증 + sitemap 제출 |
| Naver | [서치어드바이저](https://searchadvisor.naver.com) | 소유권 인증 + sitemap + RSS 제출 |
| Bing | [Webmaster Tools](https://www.bing.com/webmasters) | IndexNow 프로토콜 활용 |

### 1.3 IndexNow (선택, 권장)

- 콘텐츠 발행/변경 시 검색엔진에 즉시 알림 (Bing, Yandex 등 지원)
- Google은 미지원 → sitemap + Search Console로 커버
- 키 검증 파일(`/{key}.txt`)을 루트에 배치, 콘텐츠 CUD 후 자동 제출

---

## 2. 메타 태그 & 구조화 데이터

### 2.1 필수 메타 태그

```html
<!-- 기본 -->
<title>{페이지별 고유 타이틀} | {브랜드명}</title>
<meta name="description" content="{60~80자 이내, 핵심 키워드 포함}" />
<meta name="keywords" content="{타겟 키워드 쉼표 구분}" />
<meta name="robots" content="index, follow" />
<link rel="canonical" href="{정규 URL}" />

<!-- Open Graph -->
<meta property="og:type" content="website" />
<meta property="og:title" content="{타이틀}" />
<meta property="og:description" content="{설명}" />
<meta property="og:image" content="{1200x630 이미지 URL}" />
<meta property="og:url" content="{정규 URL}" />

<!-- Twitter Card -->
<meta name="twitter:card" content="summary_large_image" />
<meta name="twitter:title" content="{타이틀}" />
<meta name="twitter:description" content="{설명}" />
```

**주의사항**:
- description은 네이버 기준 80자 이내 권장
- 모든 페이지에 고유한 title/description 필수 (중복 시 SEO 경고)
- canonical URL은 쿼리스트링 없는 정규 URL로 통일
- SPA는 프리렌더 또는 SSR로 크롤러에게 고유 메타 태그 제공

### 2.2 JSON-LD 구조화 데이터

| 스키마 | 적용 위치 | 효과 |
|--------|-----------|------|
| `WebSite` | 홈페이지만 | 사이트 정보 + 검색 기능 노출 |
| `Organization` | 홈페이지만 | 구글 검색 로고, sameAs(SNS) |
| `FAQPage` | 홈/랜딩 | 검색결과 리치 스니펫 (Q&A 펼침) |
| `Article` | 블로그/콘텐츠 상세 | 작성일, 저자, 이미지 등 리치 결과 |
| `BreadcrumbList` | 모든 하위 페이지 | 검색결과에 경로 표시 |
| `SoftwareApplication` | 앱/서비스 랜딩 | 앱스토어 유사 리치 결과 |
| `CollectionPage` | 목록/카테고리 페이지 | 컬렉션 구조 명시 |
| `Product` | 상품 페이지 | 가격, 평점 리치 결과 |

**원칙**: 홈페이지 전용 스키마(WebSite, Organization)는 다른 페이지에 중복 삽입 금지

---

## 3. 기술적 SEO

### 3.1 렌더링 전략

| 방식 | 적합한 경우 | SEO 효과 |
|------|-------------|----------|
| SSR (Server-Side Rendering) | 동적 콘텐츠, 개인화 | 크롤러가 완성된 HTML 수신 |
| SSG (Static Site Generation) | 블로그, 랜딩 | 빌드 시 HTML 생성, 최고 성능 |
| ISR (Incremental Static Regen) | 자주 변하는 콘텐츠 | SSG + 주기적 갱신 |
| 프리렌더 (SPA용) | CSR 기반 SPA | 빌드 후 정적 HTML 생성 스크립트 |

**SPA의 SEO 한계**: CSR만으로는 크롤러가 메타 태그를 인식 못함 → 프리렌더 또는 SSR 필수

### 3.2 폰트 최적화

- CDN `<link>` → `next/font` 또는 self-hosting (렌더 블로킹 제거)
- `font-display: swap` 적용 (FOIT 방지)
- 가변 폰트(Variable Font) 단일 파일로 용량 절감

### 3.3 이미지 SEO

- 모든 이미지에 의미 있는 `alt` 속성 (네이버 진단 항목)
- 장식용 아이콘도 `alt=""` 대신 역할 설명 (`alt="조회수"` 등) — 네이버 크롤러는 빈 alt를 누락으로 판단
- 뷰포트 밖 이미지 → `loading="lazy"`
- Hero 이미지 → `loading="eager"` 또는 `fetchpriority="high"`
- OG 이미지: 1200x630px 권장, 각 페이지별 고유 이미지가 이상적

### 3.4 AI 크롤러 차단 (콘텐츠 보호)

```txt
# robots.txt
User-agent: GPTBot
Disallow: /

User-agent: ClaudeBot
Disallow: /

User-agent: CCBot
Disallow: /

User-agent: Google-Extended
Disallow: /
```

AI 학습용 크롤러와 검색 크롤러는 별개 — 검색 노출은 유지하면서 AI 학습만 차단

### 3.5 robots.txt 설계 원칙

- 인덱싱 불필요 페이지 차단: 로그인, 결제, 결과, 관리자, 에러 페이지
- 접두사 매칭 주의: `Disallow: /terms`는 `/terms-of-service`도 차단
- 해결: 구체적 Allow를 Disallow 위에 배치 (`Allow: /terms-of-service` → `Disallow: /terms`)
- SPA 동적 페이지: `<meta name="robots" content="noindex" />`로 보조 차단

---

## 4. 콘텐츠 SEO

### 4.1 블로그/콘텐츠 마케팅

**키워드 리서치 → 콘텐츠 작성 플로우**:
1. 타겟 키워드 월간 검색량 조사 (네이버 키워드 도구, Google Keyword Planner)
2. 검색량 500+ 롱테일 키워드 우선 공략
3. URL slug에 키워드 포함 (한글 slug OK — 네이버/구글 모두 인식)
4. H1에 타겟 키워드, H2/H3로 관련 키워드 구조화
5. 본문 내 관련 글 상호 링크 ("함께 읽어보세요")

**블로그 SEO 체크리스트**:
- Article JSON-LD (headline, datePublished, author, publisher)
- BreadcrumbList JSON-LD (홈 → 카테고리 → 글)
- 글별 고유 title/description/OG 이미지
- sitemap에 동적 포함 (lastmod = published_at)
- 관련 글 추천 (같은 카테고리, 조회수 순)

### 4.2 프로그래매틱 SEO

자동 생성 페이지로 롱테일 키워드 대량 커버:

| 축 | URL 패턴 | 예시 |
|----|----------|------|
| 카테고리 | `/topics/{category}` | `/topics/면접`, `/topics/이직` |
| 태그 | `/tags/{tag}` | `/tags/자기소개서`, `/tags/연봉협상` |
| 소스/출처 | `/sources/{source}` | `/sources/잡코리아` |
| 저자 | `/authors/{name}` | `/authors/홍길동` |

**필수 요소**:
- 각 페이지 고유 메타데이터 + JSON-LD (CollectionPage)
- `generateStaticParams` + `revalidate` (ISR)
- 내부 링크 네트워크: 카테고리 ↔ 태그 ↔ 소스 ↔ 저자 상호 링크
- sitemap에 모든 프로그래매틱 URL 동적 포함
- Breadcrumb (홈 → 축 → 상세)

### 4.3 내부 링크 전략

- 홈 → 블로그 목록 → 블로그 상세 (계층 구조)
- 콘텐츠 본문 내 관련 글 링크 (앵커 텍스트에 키워드)
- 카테고리/태그/저자 페이지 간 "더 탐색하기" 상호 링크
- Footer에 주요 카테고리 링크
- `<a href>` 태그 사용 필수 (JS 라우팅만으로는 크롤러가 링크를 인식 못함)

---

## 5. 다국어 SEO (i18n)

### 5.1 URL 전략

| 방식 | 예시 | 권장도 |
|------|------|--------|
| 서브디렉토리 | `/ko/`, `/en/`, `/ja/` | **권장** (도메인 권위 통합) |
| 쿼리 파라미터 | `?lang=ko` | 비권장 (Google hreflang 비공식) |
| 서브도메인 | `ko.example.com` | 가능하나 도메인 권위 분산 |

### 5.2 hreflang 태그

```html
<link rel="alternate" hreflang="ko" href="https://example.com/ko/page" />
<link rel="alternate" hreflang="en" href="https://example.com/en/page" />
<link rel="alternate" hreflang="x-default" href="https://example.com/ko/page" />
```

- 모든 언어 버전 페이지에 모든 hreflang 상호 참조
- `x-default`는 기본 언어 또는 언어 선택 페이지
- sitemap에도 각 로케일별 URL 별도 엔트리

### 5.3 자동 언어 감지

- Vercel: `x-vercel-ip-country` 헤더로 접속 국가 감지
- 국가→언어 매핑 → `Accept-Language` 헤더 fallback → 기본값
- 첫 방문 시 302 리다이렉트 (캐시 방지), 이후 쿠키/설정 유지

### 5.4 Baidu SEO (중국)

- `robots.txt`에 Baiduspider 별도 규칙 (`crawlDelay: 1`)
- `/zh/` 경로만 허용
- Baidu 웹마스터 도구 등록 (중국 전화번호 필요)

---

## 6. 동적 OG 이미지

- `next/og` (Vercel) 또는 유사 라이브러리로 Edge Runtime에서 실시간 생성
- 파라미터: title, description, type (article/blog/product 등)
- type별 디자인 분기 (색상, 아이콘 등)
- 정적 fallback 이미지도 유지 (홈/랜딩용)

---

## 7. 도메인 마이그레이션

- 구 도메인 → 신 도메인 301 영구 리다이렉트 필수
- Search Console에 양쪽 도메인 등록 + 주소 변경 요청
- sitemap은 신 도메인 URL로 업데이트
- 구 도메인 리다이렉트는 최소 6개월 유지

---

## 8. 경쟁사 분석 프레임워크

분석 항목:

| 항목 | 체크 포인트 |
|------|-------------|
| Sitemap URL 수 | 규모감 파악 |
| 블로그/콘텐츠 볼륨 | 롱테일 커버 범위 |
| 프로그래매틱 페이지 | 자동 생성 랜딩 수 |
| JSON-LD 구현 수준 | Organization, Article, FAQ 등 |
| SSR 여부 | CSR vs SSR vs SSG |
| hreflang 다국어 | 국제 검색 노출 |
| RSS/IndexNow | 크롤링 가속 |
| OG/Twitter 카드 | 소셜 공유 최적화 |
| 외부 블로그/백링크 | 도메인 권위 |
| 소셜 채널 | 브랜드 시그널 |

### 8.1 키워드 갭 분석 (경쟁사 vs 자사)

**갭 키워드 선정 조건** (AND):
1. 경쟁사 순위 ≤ 20위
2. 자사 순위 > 50위 (또는 순위 없음)
3. 자사 도메인 관련 키워드
4. 노이즈 키워드 제외 (도구명, 브랜드명 등)

**우선순위 = Impact(시장 매력도) × Confidence(달성 가능성)**

#### Impact Score (0~10)

| 항목 | +3 | +2 | +1 |
|------|----|----|-----|
| 월간 검색량 | ≥ 10,000 | ≥ 2,000 | ≥ 500 |
| CPC | $15+ | $5+ | $1+ |
| 트렌드 모멘텀 | +50% 증가 | +20% 증가 | — |
| 구매 의도 | — | BOFU (하단) | MOFU (중간) |

#### Confidence Score (0~10)

| 항목 | 점수 |
|------|------|
| KD ≤ 10 | +4 |
| KD ≤ 30 | +3 |
| KD ≤ 50 | +2 |
| 현재 상위 10위 | +3 |
| 현재 상위 30위 | +2 |
| 관련 주제 5개+ 보유 | +2 |

#### 실행 경로 (KD 기반)

| KD | 경로 |
|----|------|
| ≤ 20 & 순위 없음 | 신규 콘텐츠 작성 |
| ≤ 20 & 순위 있음 | 기존 콘텐츠 리프레시 |
| 21~40 | AI 초안 + 수동 검토 |
| 41~60 | 수동 작성 + AI 최적화 |
| 60+ | 전문가 콘텐츠 + 링크빌딩 |

### 8.2 GSC 핵심 분석 포인트

| 분석 | 용도 |
|------|------|
| **Striking Distance** (4~20위) | 순위 상승 기회 — 콘텐츠 보강으로 1페이지 진입 가능 |
| **키워드-페이지 매트릭스** | 캐니발리제이션 감지 — 같은 키워드에 여러 페이지 경쟁 시 통합 |
| **기기별/국가별 분할** | 모바일 vs 데스크톱 성과 차이, 국가별 기회 |

**모니터링 주기**: Striking Distance 주 1회, 전체 갭 분석 월 1회

### 8.3 트렌드 감지 (다중 출처)

| 출처 | 빈도 | 용도 |
|------|------|------|
| Google Trends | 주 2회 | 검색량 추이 변화 |
| 커뮤니티 (Reddit, HN 등) | 주 2회 | 업계 화제 선행 지표 |
| SNS (X, 스레드) | 수시 | 실시간 화제성 |

관련성 점수: 높음(+25) / 중간(+10) / 낮음(+5), 상한 100점

---

## 9. SEO 체크리스트

### 새 페이지 추가 시
- [ ] 고유 title/description 설정
- [ ] sitemap.xml에 자동 포함 확인
- [ ] robots.txt에서 차단되지 않았는지 확인
- [ ] canonical URL 설정
- [ ] OG/Twitter 메타 태그
- [ ] 적절한 JSON-LD 스키마
- [ ] 이미지 alt 속성
- [ ] 내부 링크 연결

### 콘텐츠 발행 시
- [ ] 타겟 키워드 title/H1에 포함
- [ ] description 80자 이내
- [ ] URL slug에 키워드
- [ ] 관련 글 상호 링크
- [ ] IndexNow 제출 (자동화)
- [ ] sitemap 갱신

### 정기 점검 (월 1회)
- [ ] Google Search Console: 색인 상태, 크롤링 오류, 검색 성과
- [ ] 네이버 서치어드바이저: 노출/클릭, SEO 경고
- [ ] sitemap 오류 확인
- [ ] Core Web Vitals 확인
- [ ] Lighthouse SEO 점수 (목표: 90+)

### 검증 도구
- [Google Rich Results Test](https://search.google.com/test/rich-results) — JSON-LD 검증
- [Google PageSpeed Insights](https://pagespeed.web.dev) — 성능 + SEO
- Lighthouse (Chrome DevTools) — SEO 종합 점수
- View Source — 크롤러가 보는 실제 HTML 확인

---

## 10. SEO 로드맵 템플릿

| Phase | 내용 | 우선순위 |
|-------|------|----------|
| 1 | 기반: robots, sitemap, 메타 태그, OG, canonical | **필수** |
| 2 | SSR/SSG 전환 (SPA인 경우) | **필수** |
| 3 | JSON-LD 구조화 데이터 | **필수** |
| 4 | 검색엔진 등록 (Google, Naver, Bing) | **필수** |
| 5 | 블로그/콘텐츠 마케팅 시작 | **높음** |
| 6 | 프로그래매틱 SEO 페이지 | **높음** |
| 7 | RSS + IndexNow | 중간 |
| 8 | 동적 OG 이미지 | 중간 |
| 9 | 다국어 i18n (해외 타겟 시) | 중간 |
| 10 | AI 크롤러 차단 | 낮음 |
| 11 | 백링크 확보 (외부 블로그, 커뮤니티) | 지속 |
| 12 | 키워드 최적화 반복 (데이터 기반) | 지속 |

---

## 11. 핵심 원칙 요약

1. **모든 페이지에 고유한 메타 태그** — 중복 title/description은 SEO 페널티
2. **크롤러가 볼 수 있는 HTML** — SPA라면 프리렌더 또는 SSR 필수
3. **내부 링크 네트워크** — 페이지 간 상호 링크로 크롤러 탐색 유도
4. **콘텐츠 볼륨** — 롱테일 키워드 타겟 블로그 + 프로그래매틱 페이지
5. **구조화 데이터** — JSON-LD로 리치 스니펫 획득
6. **모바일 우선** — 모바일 친화적 디자인, Core Web Vitals 최적화
7. **측정 → 개선 반복** — Search Console 데이터 기반 키워드/콘텐츠 전략 조정
