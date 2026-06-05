# Salaria Jobs (iOS)

Production-quality SwiftUI job browser built for the Salaria technical assessment. Users can browse remote jobs, search by title or company, and view rich job details with proper loading, empty, and error states.

## Features

- **Job listing** — title, company, location, and salary range per row
- **Search** — filter by job title or company name (client-side, instant)
- **Job details** — description, company metadata, salary, location, and link to apply
- **State handling** — loading, empty (including no search results), and retryable error states
- **Offline resilience** — bundled fallback JSON when the network is unavailable

## Requirements

- macOS with **Xcode 15+**
- iOS **17.0+** simulator or device
- Internet for live Remotive API data (optional; fallback JSON works offline)

## Setup

1. Clone the repository:
   ```bash
   git clone <your-repo-url>
   cd SalariaSales
   ```

2. Generate the Xcode project (requires [XcodeGen](https://github.com/yonaskolb/XcodeGen)):
   ```bash
   brew install xcodegen   # once
   xcodegen generate
   ```

3. Open the project in Xcode:
   ```bash
   open SalariaSales.xcodeproj
   ```

4. Select the **SalariaSales** scheme and an iOS simulator (e.g. iPhone 16).

5. Run with **⌘R**.

### Regenerating the Xcode project

The `.xcodeproj` is generated from `project.yml`. After adding or moving files:

```bash
xcodegen generate
```

Do not hand-edit `project.pbxproj` — Xcode 26 requires properly quoted build settings (e.g. `"$(TARGET_NAME)"`).

## Running tests & coverage

Unit tests target ViewModels, repositories, and business utilities. Code coverage is enabled on the shared scheme.

```bash
xcodebuild test \
  -project SalariaSales.xcodeproj \
  -scheme SalariaSales \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -enableCodeCoverage YES \
  -resultBundlePath TestResults.xcresult
```

View coverage in Xcode: **Report navigator → Coverage** after tests complete.

To inspect coverage from the command line:

```bash
xcrun xccov view --report --only-targets TestResults.xcresult
```

**Business-logic coverage goal:** ≥ 70% on `JobListViewModel`, `JobDetailViewModel`, `JobRepository`, `JobSearchFilter`, and `HTMLTextSanitizer` (see test targets in `SalariaSalesTests/`).

## Architecture

The app follows **MVVM** with protocol-based **dependency injection**.

```
┌─────────────────────────────────────────────────────────┐
│  Views (SwiftUI)                                        │
│  JobListView · JobDetailView · StateViews               │
└───────────────────────────┬─────────────────────────────┘
                            │ @StateObject / bindings
┌───────────────────────────▼─────────────────────────────┐
│  ViewModels (@MainActor)                                │
│  JobListViewModel · JobDetailViewModel                    │
└───────────────────────────┬─────────────────────────────┘
                            │ async/await
┌───────────────────────────▼─────────────────────────────┐
│  Repository                                             │
│  JobRepository → NetworkClient + FallbackLoader           │
└───────────────────────────┬─────────────────────────────┘
                            │
┌───────────────────────────▼─────────────────────────────┐
│  Remotive Public API  /  jobs_fallback.json             │
└─────────────────────────────────────────────────────────┘
```

| Layer | Responsibility |
|-------|----------------|
| **AppContainer** | Composes dependencies; `live` vs `preview` factories |
| **ViewModels** | Screen state, search, and user actions |
| **JobRepository** | Fetches and maps API DTOs to domain `Job` models |
| **NetworkClient** | Injectable `URLSession` wrapper for testability |
| **Utilities** | `JobSearchFilter`, `HTMLTextSanitizer` |

### Key design decisions

- **SwiftUI + async/await** — no Combine required; simple `Task` / `.task` integration
- **Remotive API** — `https://remotive.com/api/remote-jobs` (public, no API key)
- **Search on device** — API has no search parameter; filtering keeps UX responsive
- **Fallback bundle** — `jobs_fallback.json` ensures the app works in airplane mode or CI without network mocks

## Project structure

```
SalariaSales/
├── App/                    # @main entry point
├── Core/
│   ├── DI/                 # AppContainer
│   ├── Models/             # Job domain model
│   ├── Networking/         # API client & DTOs
│   ├── Repositories/       # JobRepository
│   └── Utilities/          # Search & HTML sanitization
├── Features/
│   ├── JobList/            # List screen MVVM
│   ├── JobDetail/          # Detail screen MVVM
│   └── Common/             # Shared UI states
└── Resources/              # Assets & fallback JSON
SalariaSalesTests/          # Unit tests
scripts/                    # Xcode project generator
```

## Assumptions

1. **iOS 17+** — enables modern SwiftUI (`ContentUnavailableView`, `.searchable`, NavigationStack).
2. **Remotive as data source** — remote jobs API is stable and permitted for demo use; attribution link on detail screen points to Remotive.
3. **Salary display** — salaries are shown in **USD ($)** and use the raw API salary strings. Many listings omit salary; UI shows *“Salary not disclosed”* when empty.
4. **HTML descriptions** — job descriptions are converted to plain text for readability (not rendered as rich HTML).
5. **Search scope** — title and company only (per requirements); location is visible but not searchable.
6. **No authentication** — public API only; no user accounts or persistence.
7. **Portrait iPhone** — primary target; iPad runs as compatible iPhone app.

## API reference

- Endpoint: `GET https://remotive.com/api/remote-jobs`
- Docs: [Remotive API](https://remotive.com/api/remote-jobs)

## License

Assessment submission — adjust license as needed for your GitHub repository.
