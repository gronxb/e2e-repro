# iOS: `locator.tap` is refused with `window-origin-unknown` right after a web view loads

On an iPhone simulator, a `locator.tap()` fails right after a large web view
loads:

```
perform tap failed: Ref @e2 has no established screen-coordinate origin
```

agent-device 0.21.37 (callstack/agent-device#4439) refuses any action aimed
from a snapshot whose viewport is not `reported`. A heavy web view makes the
runner's XCTest tree capture overrun its slice, so the runner penalizes its
XCTest channel and reads the screen through its private AX fallback. Under the
penalty that fallback skips the XCTest viewport read and declares the root
frame `derived`. On an iPhone the root is the whole screen at the origin
(`0,0,440,956` here), so the coordinates are right, but the press is refused
anyway. The penalty lasts as long as the heavy screen stays up: snapshots
taken over 150 s never got the viewport back, so re-observing doesn't help.

Packages: `e2e@0.23.1`, `@e2e-dev/mobile@0.12.7` (agent-device 0.21.37).

## Needs

- macOS with Xcode and a booted iPhone simulator. No Xcode project: the app
  builds with `swiftc`.

## Run

```sh
npm install
./repro.sh            # first booted iPhone simulator
./repro.sh <udid>     # or a specific one
```

`repro.sh` builds `App/main.swift` (a "Tap me" button and a tap counter above a
`WKWebView` that loads 3,000 links), installs it, and runs
`tests/tap.e2e.ts`: three rounds of reload the web view, tap "Tap me", expect
the counter.

## What you see

| agent-device | Result |
| --- | --- |
| 0.21.37 (`@e2e-dev/mobile@0.12.7`) | Fails 2/2 at the second round: `ENGINE_FAILURE`, `perform tap failed: Ref @e2 has no established screen-coordinate origin` |
| 0.21.36 (`@e2e-dev/mobile@0.12.6`) | Fails 2/2 differently: `the iOS automation runner is still finishing a command…` |

The same refusal without e2e, on agent-device's CLI:

```sh
agent-device open dev.e2e.repro.taporigin --platform ios
agent-device press 'id="reload-web"'
agent-device snapshot -i     # warns: This snapshot cannot establish the window origin on screen
agent-device press @e2       # Ref @e2 has no established screen-coordinate origin (window-origin-unknown)
```

## Testing a fix

agent-device from a source checkout, linked in with an npm override:

```sh
git clone -b fix/ios-private-ax-full-screen-origin https://github.com/gronxb/agent-device.git
(cd agent-device && pnpm install --frozen-lockfile && pnpm build && pnpm build:xcuitest:ios)
npm pkg set "overrides.agent-device=file:$PWD/agent-device"
npm install && ./repro.sh
```

Stop the published daemon first (`npx agent-device daemon stop`); a client
refuses to replace a newer daemon.
