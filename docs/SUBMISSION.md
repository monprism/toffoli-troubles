# Toffoli Troubles — Competition Submission

## Inspiration

Quantum computing is famously hard to learn because it's invisible — amplitudes, phases, and interference live in math, not in the world. We wanted to make it tangible. The name is a pun on the Toffoli gate, and our cast is a roll call of quantum ideas: Hadamard the Archemage, Pauli the stranded puppy, a Split Slime that forces you to learn interference, and a boss guarding the vault with two quantum seals. We were inspired by the short-room rhythm of roguelites, the step-by-step tactics of NetHack, and a single question: what if the dungeon's rules weren't fixed, but rewritable — and the thing you're rewriting is a real, honest quantum circuit?

## What it does

Toffoli Troubles is a seated, hands-only VR tabletop dungeon running on Meta Quest 3S. A miniature diorama floats in front of you, and you are two things at once: the tiny adventurer walking the board, and the giant hand that reaches down to rewire its quantum machinery. You solve real one-qubit puzzles with Hadamard, X, and phase gates; the results physically reshape the dungeon — lower a bridge, recombine a split sluice, merge two wisps, or expose a boss's weakness. Measurement is an explicit, honest action: you sample a real probability distribution and the world commits to the outcome. The run spans five handcrafted rooms — the Practice Yard, Tidemark Mill, Ember Kilns, the Glaze Orchard, and the Gilt Conservatory — with turn-based movement, roaming monsters, healing tonics, and items that play by quantum rules, all built to fit inside ten minutes.

## How we built it

Everything runs in Godot 4.7.2 with GDScript, the Mobile renderer, and OpenXR hand tracking. The quantum engine is a pure, testable state-vector simulator in `scripts/register.gd` — each qubit is stored as complex amplitudes (`yin` and `yang`), gates are exact operations (H, X, P(θ)), and measurement is a seeded collapse-and-renormalize sample rather than a dice roll. The game is procedurally assembled: `scripts/world.gd` directs the run, `scripts/diorama.gd` builds the boards, bridges, waterwheel, kilns, and conservatory from code-generated primitives, and custom shaders paint the water, stone, meadow, and the cyan/pink amplitude ribbons. We shipped it to the Quest 3S as an Android build with the OpenXR Vendors plugin and validated the flow on real optical hand tracking. A desktop mouse shim kept iteration fast, while a headless smoke test (`tests/world_smoke.gd`) walks the whole route to verify circuit outcomes, checkpoints, healing, and boss persistence.

## Challenges we ran into

The hardest challenge was fairness: quantum effects must never feel like arbitrary magic. We wrote it down as a non-negotiable — measurement is not peeking, superposition is not cloning, and a gate can't lie about the math. That discipline forced us to design puzzles around real identities like H→P(π)→H = X and H→P(π/2)→H = a genuine 50/50 interference. The second was hands-only VR: every action has to work seated, within a two-foot reach, with either hand alone, and survive tracking dropouts without a phantom pinch. Getting that reliable on-device meant enlarging colliders, adding hover focus, and tuning board distance, tilt, and target size in the headset rather than trusting desktop numbers. The third was building an entire miniature world with no art pipeline, just GDScript geometry and shaders, while keeping it readable. Finally, circuit editing and turn-based combat had to coexist: editing and pausing freeze the monsters, but measuring is the moment the world commits.

## Accomplishments that we're proud of

We shipped a complete five-room run where the physics is real: the game state is an actual quantum register, its probabilities match the math, and measurement genuinely collapses the state. The entire route passes a headless smoke test — title to epilogue, both routes to Pauli, healing caps, guardian defeat surviving reloads, and treasure restoration — with zero failures. We passed the hands-only gate on real Quest 3S hardware: cold launch with no controllers paired, the full route completed seated with each hand alone, pause/recenter working, and tracking-loss recovery that never drops a run. We're proud that the tutorial teaches a true quantum lesson (relative phase becomes visible only after interference) rather than a button-mashing shortcut, and that the whole diorama is original, code-generated work — no copied assets.

## What we learned

We learned that quantum mechanics is a surprisingly good game system when you respect it: gates become verbs, measurement becomes a commitment, and interference becomes a payoff. The hard part wasn't the math — it was legibility: turning amplitudes into readable arcs, pointer angles, and probability previews a tired player can parse. On-device testing taught us that optical hand tracking and desktop previews disagree in subtle ways, and that comfort is a tuning problem — distance, angle, and target size only become real when someone plays them in the headset. Writing the constraints down first (seated, ten minutes, hands-only, no fake physics) is what kept scope in check and kept every room teaching something real.

## What's next for Toffoli Troubles

With the hands-only baseline proven, we're expanding the quantum sandbox: two-qubit CP(θ) and SWAP gates for linked-sentry and state-thief puzzles, then the stretch Toffoli Tokkaebi GHZ encounter and a QFT finale. We'll add item synergies, a run seed, and light procedural variation to deepen replays, then move into production — original models and music, optional passthrough, comfort and accessibility passes, on-device profiling, and a signed, policy-clean submission with footage of real hands playing it.
