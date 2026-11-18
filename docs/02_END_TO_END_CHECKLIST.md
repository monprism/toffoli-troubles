# Toffoli Troubles — End-to-End Development & Submission Checklist

**Target:** Quest 3S; Godot 4.7.2 + GDScript + OpenXR; fully hands-only, seated, short sessions.  
**Last updated:** 2026-11-18  
**Instructions:** Check items only after evidence exists. **[GATE]** means stop and validate before proceeding. This list covers ideation -> real-device proof -> production -> QA -> submission -> handoff.

## Current build evidence

- [x] Run the five-room desktop smoke test in Godot 4.7.2. It passed on 18 November 2026 with zero failures, including title startup, the briefing and both coordinate choices, the epilogue, mouse selection, both routes to Pauli, the meadow checkpoint, cave entry, healing capped at 5 HP, guardian defeat after reload, and treasure restoration. [Reproduce the check](../README.md#verify-the-route)
- [ ] Run the same route hands-only on a standalone Quest 3S and record completion time, comfort and tracking results.

## Phase 0 — Product and competition validation

- [ ] Read `01_GAME_PROPOSAL.md` and agree on game thesis and MVP scope.
- [ ] Read and record current competition announcement, official eligibility, location/age requirements, category, deadline/time zone, judging rubric, allowed engines, permitted assets, build format, submission method, and demo/video constraints.
- [ ] Recheck all Meta VR Start terms, Developer App Policies, Content Guidelines, Community Standards, and VR conduct rules.
- [ ] Verify originality/overlap with existing VR quantum puzzle games and tabletop dungeon games; keep brief competitor notes.
- [ ] Check the working title Toffoli Troubles for name/trademark collisions before public branding.
- [ ] Select a content-rating target and acceptable level of stylized combat/creepiness.
- [ ] Decide milestone success criteria: standalone XR, hands-only, seated, short win/lose loop, math correctness, performance.
- [ ] **[GATE]** Write the minimum live-demo scope on one page and explicitly reject out-of-scope features.

## Phase 1 — Mac and Quest setup

- [ ] Verify Homebrew is available, or install it from official Homebrew instructions.
- [ ] Install **Godot 4.7.2 stable** and record exact version (`godot --version`).
- [ ] Install matching Godot export templates.
- [ ] Install Android Studio and Android SDK components required by current Godot export docs.
- [ ] Install Java JDK 17 (e.g., Homebrew `temurin@17`) and verify Java path/version.
- [ ] Install `adb` / platform-tools and check `adb version`.
- [ ] Enable Quest Developer Mode through Meta's developer setup.
- [ ] Connect Quest 3S with a data-capable USB-C cable; authorize ADB in headset.
- [ ] Verify `adb devices` lists status `device`.
- [ ] Configure Godot Editor Settings -> Android SDK path and Java SDK path.
- [ ] Configure the existing `toffoli-troubles` repository and its `.gitignore`; exclude private keys and generated files.
- [ ] Commit initial docs and record engine/plugin versions in README.
- [ ] **[GATE]** Export a **blank XR Android APK** and run on Quest 3S; no black-screen/bootstrap error.

## Phase 2 — Godot OpenXR / interaction proof

- [ ] Create XR startup scene with `XROrigin3D` and `XRCamera3D`.
- [ ] Enable OpenXR, suitable action map, hand tracking and hand interaction profile in project.
- [ ] Configure Quest Android export preset: OpenXR, Gradle (if required), runnable, correct vendor/plugin selection.
- [ ] Install and pin compatible **Godot OpenXR Vendors** plugin (test version 5.1.0 stable first).
- [ ] Test both renderer candidates if needed; log known-good renderer/settings on Quest 3S.
- [ ] Display tracked hands or clearly visible hand-ray cursors from *optical* hand tracking.
- [ ] Implement point -> hover highlight -> pinch select for one large target.
- [ ] Verify target selection and menu actions with either hand alone.
- [ ] Implement large **Start**, **Pause**, **Resume**, **Recenter**, **Quit** targets.
- [ ] Validate no controllers paired, including cold launch and initial OS dialogs.
- [ ] Test brief hand tracking loss; prevent phantom pinches and state loss.
- [x] Add desktop mouse input shim for offline debugging.
- [ ] **[GATE]** On real Quest 3S, user can select 10 consecutive targets without requiring controller, standing, tiny grabs, or uncomfortable reaching.

## Phase 3 — Tabletop readability and comfort prototype

- [ ] Make a single 3D miniature room using original primitive meshes.
- [ ] Position board in front of seated user, slightly below neutral forward gaze; validate in headset.
- [ ] Add simple recenter, tilt, and scale controls usable with hands.
- [ ] Enlarge selectable collider areas; show hover/selected feedback and valid targets.
- [ ] Add gate toolbar with readable labels and icons, large hit regions, and one-hand reach.
- [ ] Test board against virtual background **without a physical table**.
- [ ] Add optional passthrough mode via vendor plugin; confirm fallback if passthrough unavailable.
- [ ] Avoid fast camera motion, forced locomotion, constant arm extension and strenuous pinch chains.
- [ ] Recruit at least one new tester; watch for arm/neck fatigue and unclear controls.
- [ ] **[GATE]** Entire room interaction works seated/stationary in approximately two-foot reach radius, without leaning or repeated tracking loss.

## Phase 4 — Correct quantum engine (desktop-testable)

- [ ] Specify bit-order convention for multi-qubit state-vector indexing.
- [x] Implement complex-amplitude representation and a normalized |0> register.
- [ ] Implement H; test `H^2=I` and norm preservation.
- [ ] Implement X; test `X^2=I` and basis flips.
- [ ] Implement P(theta); verify phase angle and unchanged Z-basis probabilities before recombination.
- [ ] Implement explicit measurement, seeded randomness, state collapse and normalization.
- [ ] Test `H -> P(pi) -> H` flips |0> to |1> (up to global phase).
- [x] Test `H -> P(pi/2) -> H` gives equal computational outcome probabilities.
- [ ] Implement deterministic headless test command that exits nonzero on failures.
- [ ] If advanced rooms are included, add CP(theta) for 2 qubits; test basis-state effects and entanglement-ready input states.
- [ ] If advanced rooms are included, add SWAP; test permutations across all 2-qubit basis inputs.
- [ ] For a stretch GHZ encounter, verify the intended joint state and sampled correlations. For a QFT finale, implement 3-qubit QFT and validate against an independent reference matrix, respecting ordering.
- [ ] **[GATE]** All physics tests pass without XR, animation or network access.

## Phase 5 — First gameplay room (vertical slice)

- [ ] Implement Observe → Resolve → Navigate → automatic Achieve. Verify inspecting intentions and waiting for a stronger hint preserve the state.
- [ ] Add one hero figurine, simple move/attack animation and readable HP state.
- [x] Place Pauli beyond two impassable channels. Initialize the bridge winch to yin.
- [x] Verify that 0 holds the first bridge up and X followed by measurement lowers it and unlocks its square.
- [ ] In Resolve, select target then rune, preview odds and confirm or undo. Verify the phase dial can select π/4, π/2 and π.
- [ ] At Tidemark Mill, verify the visible choice between solving the sluice for a shorter route and fighting/evading along the long route without resolving.
- [ ] Verify the mill tonic is placed after the creature route and can be collected after that turn's damage when below 5 HP.
- [ ] On entering Navigate, sample any pending readout once. Keep the resulting environment fixed during single-step movement, attacks, blocks and combat item use.
- [ ] Verify that both relay outcomes reach Pauli, then return to the relay and lower the other bridge before leaving; show that the second crossing is optional.
- [ ] Verify that dungeon exits remain reachable with each shortcut sealed and the navigation message explains the open route.
- [ ] Animate coherent path splitting, phase adjustment and recombination, with outcomes tied to simulation.
- [ ] Add invalid-action explanations and Undo-before-resolve where sensible.
- [ ] Save at a safe room boundary and verify that a cold restart restores that checkpoint.
- [ ] Add success and failure result cards plus Replay/Quit.
- [x] Add at least one concise tutorial hint teaching phase/interference correctly.
- [ ] **[GATE]** Someone can boot, learn, solve, win/lose, and replay the slice **hands-only** in <=5 minutes.

## Phase 6 — Full 6–9 minute run

- [ ] Build a 5–6-room run covering the tutorial, combat, interference branch, reward and boss. Show the summary after the run.
- [ ] Select two enemy types from the roster and build one boss encounter using gates available in the competition build. Test the chosen mechanics (e.g., Pauli Puppy’s X toggle and Split Slime’s interference routes). Reserve Toffoli Tokkaebi’s GHZ and Fourier Fenrir’s QFT for stretch encounters.
- [ ] Add 2–3 meaningful item synergies that preserve underlying gate math.
- [ ] Test a room with an item-assisted alternative and its ordinary puzzle solution. If Noisy Lucky Coins are chosen, verify limited attempts, disable use after success and solve normally after exhaustion.
- [ ] Add clear item pickup/reward UI without tiny precision grabs.
- [ ] Add room navigation/branching with large hand-selectable nodes.
- [ ] Add difficulty ramp and at least one interesting non-obvious combination.
- [ ] Add boss telegraphs, health/phase changes and a satisfying defeat sequence.
- [x] Start and restart at 5 HP. Verify a tonic is consumed when stepped on below full health and healing caps at 5 HP.
- [x] Verify the defeated guardian stays down at the exit and after a checkpoint reload.
- [ ] Add a run seed and minor room/reward variation only after fixed run is good.
- [ ] Add audio cues, captions/text equivalents for critical game state, menus, and tutorial replay.
- [ ] **[GATE]** New testers get a satisfying complete run or loss/summary in <=10 minutes.

## Phase 7 — 3D art, sound, and production polish

- [ ] Establish an original visual style sheet: characters, colors, rune icons, dungeon materials.
- [ ] Replace gray-box assets incrementally while preserving hit volumes and readability.
- [ ] Build original or properly licensed 3D models, textures, SFX, music and fonts; track license/attribution.
- [ ] Avoid directly copying recognizable characters, art, UI, music or logos from reference games.
- [ ] Use yin and yang for player-facing basis outcomes. Verify each is recognizable by shape with color removed.
- [ ] Minimize expensive dynamic shadows, transparent effects, particle overdraw, and high-poly assets.
- [ ] Add readable quantum-state previews, probability/outcome effects and low-clutter UI.
- [ ] Add understandable onboarding (possibly skip for repeat runs) and a discoverable help panel.
- [ ] Add a default virtual background that looks intentional even if passthrough is unavailable.
- [ ] Verify all buttons/menus remain accessible after resizing or recentering the board.

## Phase 8 — Quality assurance and accessibility

- [ ] Test with **no controllers paired**: install/open, first launch, gameplay, pause/resume, quit/relaunch, tutorial, game over, replay.
- [ ] Complete each phase using only the left hand, then only the right, including backpack access.
- [ ] For enabled gestures, test snap to pause/resume, thumbs-up to advance, pinch/touch to edit gates, thumb directions and forward index to step, flick to attack and palm to block. Repeat via large ray-selectable controls.
- [ ] Test hand occlusion, low/uneven lighting, different hand sizes, and varying distance to board.
- [ ] Test headset remove/re-wear, app focus loss, pause and resume, and ADB launch from cold boot.
- [ ] Test board recenter/scale/tilt without moving outside seated comfort zone.
- [ ] Test every quantum puzzle with unit tests and manually; probability display should match actual distribution.
- [ ] Test no unwinnable random room or boss sequence; review procedural seeds if enabled.
- [ ] Test no accidental controller-only OS or in-app gate after onboarding.
- [ ] Test mono UI contrast/legibility, icon shapes, left-/right-handed targeting, sounds with volume muted.
- [ ] Profile on-device render rate, frame timing, dropped frames, memory, crashes, thermal throttling, and battery.
- [ ] Check offline play, permission minimization and no unexpected personal/spatial data collection.
- [ ] Run extended 10–20 minute comfort test with breaks and solicit motion/fatigue feedback.
- [ ] **[GATE]** No critical bugs, black screens, blocker hand interactions, policy violations or severe discomfort.

## Phase 9 — Policy / legal / privacy / submission audit

- [ ] Verify latest VR Start Terms and active contest details from official competition page.
- [ ] Confirm project eligibility: entrant, country, dates, team size, prior work rules, allowed engines, hardware, judging category.
- [ ] Confirm Meta Developer App Policies and Content Guidelines are met.
- [ ] Confirm platform privacy notices and permissions: passthrough/scene/hand data as applicable; no unnecessary retention.
- [ ] Confirm age/content rating and disclosures, original/legally licensed assets, attributions.
- [ ] Check required stability/performance, privacy policy URL (if applicable), and distribution method.
- [ ] Document exact engine, plugin versions, source licenses and any external libraries.
- [ ] Create release signing keystore securely; back it up privately; keep it outside Git.
- [ ] Prepare a signed release build using correct package ID/version/build number; install and smoke-test it.
- [ ] Validate all requirements directly on the **submitted release build**, not only debug.
- [ ] **[GATE]** Eligible, signed, reproducible build with passing hands-only full-flow test.

## Phase 10 — Demo, store page and competition submission

- [ ] Capture clean Quest footage of the real interactions, not just desktop editor captures.
- [ ] Record a short trailer that shows the **hands-only** mechanic within the first few seconds.
- [ ] Capture screenshots of the tabletop, quantum gates, combat, interference puzzle, and boss.
- [ ] Write a concise project description (what it is, why XR, why hands-first, what is original).
- [ ] Write how-to-play text that a judge can follow without assistance.
- [ ] Build a clear `README.md`: install, launch, controls, recenter, pause/resume, expected runtime.
- [ ] Include required disclosures, attribution, privacy documents, submission fields and links.
- [ ] Review video and screenshots for readable text, no copyrighted reference game assets, no sensitive environment recordings.
- [ ] Submit through the **actual current competition page** ahead of its verified cutoff; record confirmation and URLs.
- [ ] Install the exact submitted artifact from the delivery path and smoke-test again.
- [ ] **[GATE]** Submission confirmation and working install evidence are archived.

## Phase 11 — Post-submission handoff / follow-up

- [ ] Tag final release in Git and archive exact APK/hash, source revision, docs, plugin versions, build logs.
- [ ] Create known-issues list and reproduction steps; separate release blockers from stretch goals.
- [ ] Capture headset acceptance notes and playtest findings.
- [ ] Identify next iteration: richer item synergies, CP/SWAP, entanglement puzzles, 3-qubit QFT boss, more procedural runs.
- [ ] If a team/Codex continues: update handover with verified facts, changed assumptions, and next 3 tasks.
- [ ] Track relevant competition updates/feedback only if needed, through official channels.

---

## Next build session

1. Launch the desktop build and run the isolated smoke test using the [README instructions](../README.md).
2. Verify matching Android export templates, SDK, JDK, OpenXR vendor configuration and Quest authorization.
3. Export and install the prototype on Quest 3S. Complete the Phase 2 hand-selection gate on the actual headset.
4. Test the five-room route seated with each hand alone. Record run time, tracking interruptions and checkpoint recovery.

## No-go / stop conditions

- **If hand input isn't reliably usable:** pause feature work. Make targets bigger, change ray/action profile, use confirmation/tap fallback, or reduce tempo.
- **If the tabletop is uncomfortable:** change distance/angle/scale and minimize reach. Do not insist on physical desk or room-scale navigation.
- **If passthrough breaks exports:** keep the complete experience in a virtual background while investigating.
- **If quantum effects are misleading:** fix the simulation/explanation before adding rooms.
- **If the 10-minute session is not satisfying:** cut content, improve tutorial and one encounter rather than expanding scope.
- **If a deadline approaches:** preserve an excellent hands-only vertical slice over an incomplete QFT campaign.

> **Source of truth:** The supplied competition rules take precedence over design preferences. The **current** official contest page, developer policies, and engine/plugin docs take precedence over any dated setup details in this checklist.
