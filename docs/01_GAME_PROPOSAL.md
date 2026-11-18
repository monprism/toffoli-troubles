# Toffoli Troubles — Game Proposal

**Working title:** Toffoli Troubles
**Project:** Meta VR Start Developer Competition 2026  
**Engine:** Godot 4.7.2 stable, GDScript  
**Target device:** Meta Quest 3S (standalone Android/OpenXR)  
**Primary format:** Seated, hands-only, 3D miniature mixed-reality roguelite  
**Document status:** Living design proposal — 18 November 2026

## 1. One-sentence pitch

A small world of dungeons appears in front of you; you defeat strange creatures and alter the dungeon's routes by applying real quantum gates to glowing quantum cores, discovering surprising combinations through short, replayable runs.

## 2. The player fantasy

You are simultaneously (a) the tiny adventurer battling through a strange dungeon and (b) the giant operator whose hands can reach into the miniature world to change the rules of its quantum machinery. The world reacts physically and spectacularly when a gate combination succeeds. Think the **short-room rhythm, weird item synergies, and replayability** associated with action roguelites, paired with a **3D tabletop diorama** and quantum interference puzzles. Art, designs, and assets must be original, not copies of any reference game.

**Core thesis:** The fun is not dragging textbook circuit symbols onto wires. It is discovering that the same small set of operations can open a door, reroute an attack, or expose a boss's weakness.

## 3. Competition design contract (hard requirements)

The user supplied these as requirements/guidelines; confirm the full official submission rules and latest policies before shipping.

| Rule | How the game complies | Concrete acceptance test |
|---|---|---|
| **Hands-first, end-to-end** | Hand rays + pinch/select, large targets, single-hand accessible UI; controllers optional, never needed | Launch, play, pause, resume, finish, restart, and quit with **no controllers paired** |
| **Seated-optimized** | Board anchored in a comfortable forward viewing zone; player does not have to walk around it | Complete the game seated with interactions in approximately a **two-foot reach radius** |
| **Fast sessions** | Quick-start, brief rooms, checkpoint on transition; a satisfying win/lose loop within 10 minutes | First successful or failed mini-run and summary reachable in **<= 10 minutes** |
| **Original, not a wrapper** | Entrant-written GDScript simulation, combat, procedural encounters, art direction and content | Game is enjoyable offline without any cloud AI or third-party service |
| **Policy compliance** | Original/licensed content, suitable content ratings, minimal permissions, respectful user comfort | Pre-submission Meta policy and competition rule audit passes |

**Important constraint:** Quest 3S has hand tracking, but no physical feedback. The UI must not depend on grabbing tiny moving objects, complex hand signs, fast repeated pinches, or precise two-hand coordination.

## 4. Design Guidelines:

- **Seated-optimized**: Design for seated, stationary use. Limit roomscale, no large physical movement. Apply the airplane seat test: does every interaction work in a two-foot radius?
- **Easy to get into and out of**: Fast cold start, clean pause/resume, and something satisfying in 10 minutes or less. Apply the one bus stop test: can someone have a complete moment in a short ride?
- **Original, not a wrapper**: Core experience is Entrant-built. Thin wrappers around existing platforms or services (YouTube, ChatGPT, etc.) are highly discouraged. Apply the take it away test: if you remove the third-party service, is there still a Project?

## 5. Look and feel

- **3D miniature diorama** floating in the user's forward field of view, with **optional passthrough** background. Do not require a real desk, table detection, room scanning, or spatial anchors for the MVP.
- **Carved tabletop pieces and weathered materials**: faceted silhouettes, muted stone and timber, tarnished brass, readable floor layout, subtle creepiness without graphic violence.
- Color-code quantum outcomes consistently (e.g. emerald for |0>, ruby for |1>, double ghost trails for superposition), while also using shape/icons for color-blind legibility.
- Quantum computing concepts should come in a subtle manner -- don't say "it's |0> state", call it yin. |1> can be yang.
- Gates look like tangible magical **runes or oversized tiles**. The dungeon uses exaggerated doors, phase rings, beam paths, traps, and crystals rather than a conventional circuit editor.
- Camera is user/head-driven, board stays steady; allow easy **recenter, scale, and angle** controls. Avoid forced camera motion.
- Keep translucency and particle effects affordable on the standalone Quest 3S; focus on legibility rather than expensive realism.

## 6. Core interaction loop

Will be done in four phases: Observe, Resolve, Navigate, Achieve.

1. **Observe:** See where the enemies are. What are their intentions? Look at the puzzle (it's really quantum circuit). Are there any hints? If taking too much time more hints will be given. Do we really need to resolve the puzzle always? Do you have an item that can get you through?
2. **Resolve:** Point at a big valid target, pinch to select; select a gate in the large near-board palette. Confirm or undo an action. If it changes probabilities, show a simple visual preview. Quantum actions can be used on either opening/closing passages or to weaken/eliminate/block enemies.
3. **Navigate:** Quantum measurements use explicit sampled outcomes. Environment is set. Now is the time to move and fight. You advance one step at a time. Just like NetHack, and Dungeon Crawl. Use combat items if you have them handy.
4. **Achieve:** Get a satisfying opening, damage sequence, item choice, or new route; repeat.

**Pacing:** Tactical/step-based with lively animations, not twitch-based twin-stick shooting. Avoid uninterrupted hand-held drag interactions. Use a gentle slow/paused planning phase and short energetic resolution. Think of Super Mario World (or Super Mario Bros. 3)'s world for **Observe** and **Resolve** and Nethack (or Dungeon Crawl) dungeon for **Navigate** and **Achieve**.


## 7. Single- and two-qubit gates and stretch encounters

These are the **only gate families** in the complete design. **Measurement is an action, not a gate**. A phase dial can choose discrete angles, so P(pi), P(pi/2), and P(pi/4) do *not* consume extra gate families.

| Gate | Math on quantum registers | Player-facing metaphor | Gameplay uses |
|---|---|---|---|
| **H — Hadamard** | Transforms Z-basis states to +/- superpositions; H²=I | Split / recombine | Put a wisp into paired routes, then recombine at a junction; prepare qubits for interference |
| **X — Bit flip** | Exchanges the two basis states | Invert / toggle | Flip a shield's quantum vulnerability, open a binary lock, reroute a beam |
| **P(theta) — Phase** | P(theta)=diag(1,e^{i theta}) | Twist / interfere | Change relative phase on a wisp; effects are visible at later recombination, not instantly as changed odds |
| **CP(theta) — Controlled phase** | Multiply the two-qubit component with both bits set of two-qubit state by e^{i theta} | Couple / condition | Correlated bosses, linked crystals, multi-core puzzles; combine with H and measurement for observable outcomes |
| **SWAP** | Exchange two qubit *states*, not physical locations | Exchange essence | Transfer a state from one mechanism/register to another; final QFT bit reversal |

**GHZ State or Quantum Fourier Transform (QFT) finale:** A standard 3-qubit QFT decomposition uses **H, controlled phase with pi/2 and pi/4 angles, and SWAP**. X and standalone P are gameplay conveniences. The final boss is a stretch goal: defer it until 1-qubit and 2-qubit interactions are tested and fun.

## 8. Flagship mechanics and examples

### A. Chamber of Two Doors — interference, not arbitrary collapse

A quantum wisp starts in `|0>`. The player applies `H`, chooses a relative phase, and applies a second `H` at the recombiner.

- `H -> H` returns `|0>`: Door 0 is certain.
- `H -> P(pi) -> H` yields `|1>`: Door 1 is certain.
- `H -> P(pi/2) -> H` gives 50/50 **when measured in the Z basis**. The dial snaps to the available angles, including π/4, π/2 and π.

Visually, the two routes are shown as translucent **amplitude paths**. Both exits are temporarily unstable until recombination/measurement. This is scientifically better than claiming H alone turns a solid door into an invalid one.

### B. Ghost Cutter — attack routing

Your projectile is a quantum wisp passing through two protected routes. Use H to prepare, P to shift phase, and H to recombine into the unshielded exit. This creates the fantasy of 'cutting through' defenses without claiming that an ordinary enemy literally occupies two places at once.

### C. Phase Shell enemies — transform the weakness

An enemy's quantum **shield register** begins `|0>`, but its weak mode is `|1>`. Apply X to flip immediately, or discover `H -> P(pi) -> H = X` as a more advanced route. The character still has ordinary spatial health and position.

### D. State Thief — two-target SWAP

A treasure pedestal carries a known quantum key state; an enemy lock carries another. SWAP their **registers**. The keys and enemies stay physically in place, but their associated quantum permissions change.

### E. Linked sentries — controlled phase

Two sentry cores are prepared in a superposition. CP(theta) changes conditional phase; subsequent H/readout exposes a useful joint pattern. Do **not** present entanglement as instantaneous remote-control commands or faster-than-light messaging.

### F. Observation trap — risk/reward

The player can measure a register early to get a usable answer now, or preserve coherence until another gate improves the odds. Measurement returns a sampled result and changes the quantum state; it is **not** just peeking at hidden information for free.

### G. Items: classical or quantum transformations (Isaac-like synergies)
Quantum actions shouldn't always be the only way to clear a dungeon.
Examples: **Noisy Lucky Coins** should introduce noise to the circuit to alternate results. If only |0> single gate measurement opens it and you are given |1>, each coin gives you one turn to measure to resolve the puzzle by chance if you didn't resolve it already (if resolved disable it). If chances run out, you gotta solve the puzzle. **Hadamard's Hints** will give further text hints. In the current route, the **Phase Lens** is a weapon charge earned by resolving Ember Kilns: its next strike deals one extra damage, then consumes the charge. **Deutsch's Dice** can give you a random gate you can try using to resolve, **Coherence Charm** allows one extra preparation turn before an enemy forces measurement. Upgrades **modify rules/resources**, not mathematically falsify gate effects. Classical items are typical combat items (HP recovery, buff/nerf, stuns an enemy, etc.)

## 9. Combat and dungeon systems

**Recommended combat:** During Resolve, confirm the selected quantum action and preview its effect. On entering Navigate, sample any pending measurement and set the route. Each confirmed step, attack, block or combat item advances one beat, then enemies carry out their telegraphed actions. Animate the beat immediately after input.

**Enemy roster by mechanic** (choose from these for the competition slice, with three-qubit encounters reserved for later):

1. **Pauli Puppy** single register becomes docile at a certain qubit state; teaches X.
2. **Split Slime:** two-branch route attacked by interference; teaches H/P/H.
3. **Phase Pheasant:** need to first shift phase to keep it frozen/alive; teaches the Z phase flip using P(π).
4. **Bell Bee:** mid-boss, need bell state to thwart.
5. **Toffoli Tokkaebi:** stretch GHZ encounter using a Toffoli operation composed from the allowed gate families.
6. **Fourier Fenrir (later):** multi-register boss requiring a multi-gate sequence, eventually QFT.

**Rooms for a complete miniature run:** intro/tutorial, battle, branching interference door, upgrade reward, boss, run summary. Some room ordering/rewards randomized after the handcrafted run is proven.

### Current playable route

| Room | What the player does |
|---|---|
| The Practice Yard | Use X to lower the first bridge, then stand beside either second-layer bridge and resolve its local winch: round lowers the detour, diamond lowers the shortcut. Both crossings are independently interactable before heading to Pauli. |
| Tidemark Mill | At the entrance, choose the long route through the mill creatures or recombine the nearby sluice into yin to open a clear, narrow passage before the creature gauntlet. A tonic waits farther along the creature route; earn a Lucky Coin after clearing the room. |
| Ember Kilns | At the right end, resolve the split-flame circuit with P(π), then H. The kiln forges a Phase Lens weapon charge: the next strike deals one extra damage and consumes it. |
| The Glaze Orchard | Two wisps and their resolve core wait at the right end. Approach and resolve H, P(π), H to merge the pair into one and clear the shortcut; the creature route remains playable if the puzzle is skipped. |
| The Gilt Conservatory | Two separate seals stand at the right end. Approach and resolve each in turn (X for the first; P(π), then H for the second) to expose the Crowned Split Slime, then strike it and choose a keepsake. |

Between the yard and Tidemark Mill, a walkable meadow leads to the cave entrance. Mossy threshold stones, ruined arches and lava vents give the dungeons their terrain. Three smaller monsters patrol each dungeon on tactical turns. Cyan and pink light distinguish quantum channels.

The title leads to a short briefing from Hadamard the Archemage. He asks the player to free the vault’s light and recommends helping Pauli to learn how the gates work. Before entering the yard, the player chooses whether to display coordinates and whether they would use hand gestures. The briefing shows the planned mapping—point to move, pinch to select, thumbs-up to advance, open palm to block and flick to strike—and says these controls are not ready to test yet. Hadamard returns in an epilogue after the player chooses a keepsake.

A layered sandstone mesa and low perimeter walls frame each dungeon. Nearby monster species have distinct calls on dungeon turns. Each room uses a 12 × 12 movement grid with orthogonal moves, obstacles and a marked exit.

The two Practice Yard crossings are independent. Each has its own nearby winch, and the interaction appears when the player stands next to that bridge. The player can lower either crossing without visiting a central relay or being forced onto one route. Dungeon shortcuts follow the same principle: the open stone route still reaches the exit when a shortcut remains sealed, and the navigation message makes that clear.

Each run starts with 5 HP. A tonic in Tidemark Mill and another in the Glaze Orchard each restore up to 2 HP when picked up below full health. Consuming a tonic or defeating a guardian saves the current crossing so healing and guard defeat persist through reload.

The Lucky Coin is a one-use noisy measurement aid. The Phase Lens earned in Ember Kilns is a one-use weapon charge that adds one damage to the next strike. The final vault offers the Noisy Lucky Coin, Phase Lens and Deutsch’s Dice as collectible keepsakes. This fixed route is playable on desktop. The session length and hands-only requirements below remain headset playtest targets. [Desktop launch and controls](../README.md#play-on-desktop)

## 10. Control via gesture
One hand mode: left or right hand
Prototype these as one-hand shortcuts after ray and pinch work. Provide a large ray-selectable control for every essential action.
1. **snap** to pause/resume
2. **a thumbs-up** to proceed across phases (observe -> resolve -> navigate). achieve will happen automatically
3. **pinch and touch the circuit** to insert the gates and manipulate them
4. **thumb pointed to right, backward (like using shoulder), left** to move right, back, left during navigate stage
5. **index finger pointed at forward** to move.
6. **flick** to attack.
7. **stop! like palm** to block.
8. interact with your backpack/inventory to use.
For movements if buttons are easy do that.


## 11. MVP cutline — what will actually ship first

### Must-have vertical slice

- Working standalone Quest 3S build in Godot, hands-only from boot to exit.
- Recenterable **virtual floating board**, with passthrough as an optional mode.
- One complete miniature room, one hero, one stranded Pauli Puppy and three local bridge winches.
- Hand-ray **point -> pinch -> confirm** flow, giant pause/recenter controls, one-hand alternative.
- **H, X, P(theta)** on a single qubit, plus explicit measurement and visually distinct probabilistic results.
- Correct quantum math and unit tests; tutorial + win/lose/restart loop.
- Saving/resuming at safe room boundaries and losing hand tracking safely.

### Version-1 competition slice (after prototype)

- 5–6 brief handcrafted rooms; two enemy types; one boss using the gate mechanics available in that build; 2–3 item synergies.
- 6–9 minute run, readable feedback, original music/SFX/assets or verified licenses.
- CP(theta) and SWAP **only if comfortably testable**, or as a separate optional advanced room.
- Repeatable mini-run with light variation; policy/test artifacts; submission media.

### Explicitly out of scope until after the slice works

Multiplayer, online accounts, generative AI, full procedural 3D geometry, physical room scans/scene understanding, complicated gestures, voice commands, cloud quantum hardware, a complete 3-qubit QFT campaign, complex physics combat, and elaborate real-world occlusion.

## 12. Primary risks and mitigations

| Risk | Impact | Mitigation / stop rule |
|---|---|---|
| Hand selection feels unreliable | Project-ending usability risk | Build hand-ray/pinch test **before combat/content**; enlarge targets, add focus highlights, use tap-to-select; pivot to slower board interactions if needed |
| Tabletop requires uncomfortable reaching | Violates seated design | Float board ahead and slightly below neutral gaze; all critical UI via ray; no obligatory direct grabs |
| Quantum effects feel arbitrary | Educational trust and puzzle fairness lost | Unitary/testable simulation; explicit measurement; show simplified before/after and success probabilities |
| Too much real-time action | Hands-first failure | Short tactical beats; clear intent telegraphs; forgiving timing |
| MR passthrough/plugin failure | Device compatibility | Playable fully virtual background; passthrough optional; test plugin/Android deployment immediately |
| FPS drops on Quest 3S | Comfort risk | Mobile-friendly geometry, restrained transparency, conservative lights, profile on device |
| Competition timing/policies unclear | Submission risk | Verify current contest page, eligibility, deadlines, required media and Meta policies with official sources |

## 13. Success measures

- **100%** of core flow completable without pairing a controller.
- Most test players can select a stationary room object and apply a gate reliably after a short tutorial.
- Players can play while seated, without repeatedly extending their arms or standing.
- A satisfying complete session fits within 10 minutes, including a boss/reward/restart prompt.
- Gameplay runs comfortably on the Quest 3S with no sustained discomfort or crashes; profile frame timing in-headset rather than assuming a target is achieved.
- Three physics invariants hold: gate norm preservation, accurate probabilities, and measurement collapse.
- Test players can explain at least one real lesson: e.g., **relative phase becomes visible after interference**.

## 14. Decision log

- **Chosen engine:** Godot, not Unity. Native GDScript first; Python remains useful for external math prototyping/tests, not the runtime.
- **Chosen input:** hands-only as the default and mandatory end-to-end path; optional controllers never substitute for it.
- **Chosen form factor:** stationary miniature 3D board with optional passthrough; not room-scale exploration.
- **Chosen pace:** short tactical-action beats rather than twin-stick real-time shooting.
- **Chosen gate scope:** H, X, P(theta), CP(theta), SWAP maximum; measurement separate.
- **Chosen delivery priority:** comfort and real-device hand interactions first; sophisticated graphics/procedural/QFT later.

## 15. Research / official references (recheck before submission)

- Godot stable releases: https://godotengine.org/download/archive/
- Godot XR setup: https://docs.godotengine.org/en/stable/tutorials/xr/setting_up_xr.html
- Godot OpenXR hand tracking: https://docs.godotengine.org/en/stable/tutorials/xr/openxr_hand_tracking.html
- Godot passthrough: https://docs.godotengine.org/en/stable/tutorials/xr/ar_passthrough.html
- Godot Quest deployment: https://docs.godotengine.org/en/stable/tutorials/xr/deploying_to_android.html
- Godot OpenXR Vendors: https://godotvr.github.io/godot_openxr_vendors/
- Meta VR Start terms: https://developers.meta.com/horizon/start/terms/
- Meta developer policies: https://developers.meta.com/horizon/policy/
- Meta developer content guidelines: https://developers.meta.com/horizon/policy/#content-guidelines
- Meta community standards: https://transparency.fb.com/policies/community-standards/

> **Note:** This proposal is a build plan, not confirmation that a design is novel or competition-eligible. Recheck similar games, eligible markets, category, and current event rules before final submission.
