# CFD Postprocessing Report: Flow Maldistribution Mitigation
### Laminar Sheet Inserts — Chevron vs Teardrop Geometry
> OpenFOAM 12 | `foamRun` / `incompressibleFluid` | Laminar | t = 10 s

---

## 1. Simulation Setup

| Parameter | Value |
|---|---|
| Solver | `foamRun` — `incompressibleFluid` |
| Turbulence model | Laminar (`simulationType laminar`) |
| Fluid | Air (kinematic viscosity ν = 1.563 × 10⁻⁵ m²/s) |
| Domain | 200 mm × 1200 mm computational channel, height 97 mm above sheet (Z: 3→100 mm) |
| Inlet | Uniform U = 0.5 m/s, −Y direction (top-to-bottom) |
| Outlet | Zero-gradient U, fixed p = 0 |
| Walls | `noSlip` — bottom, top, sides, insert surface |
| Mesh | `snappyHexMesh` on hex background (20×120×22 base), surface refinement level 2 |
| End time | 10 s (chevron: t=10.00021, teardrop: t=9.9995) |
| Reynolds number | Re = U·L/ν = 0.5 × 0.097 / 1.563e-5 ≈ **3,103** (channel height as characteristic length; laminar model assumed, not validated) |

---

## Mesh and model limitations

The reported meshes are a single resolution per geometry; mesh independence and time-step independence have not been established. The γ difference of 0.0006 may be smaller than numerical uncertainty. Run at least three systematically refined meshes for each case and compare consistent weighted metrics, pressure drop, mesh quality, residuals and mass balance; see the README. Validate the laminar assumption and wake interpretations before making design recommendations. The pressure-extrema metric is not the same as inlet-to-outlet pressure drop.

---

## 2. Insert Geometry

### 2a. Chevron (`laminar_sheet_chevron`)
- **Base plate**: 200 × 1000 × 3 mm (scaled 1:1, metres in OpenFOAM)
- **Protrusion**: Triangular chevron — apex pointing **upstream** (+Y), triangle 200 mm long × 120 mm wide, protrudes **10 mm** above the plate
- **Mechanism**: Splits flow around the apex, deflects it laterally toward the channel sides, creating counter-rotating vortex pair downstream

### 2b. Teardrop (`laminar_sheet_teardrop`)
- **Base plate**: 200 × 1000 × 3 mm (scaled 0.001 → metres)
- **Protrusion**: Biconvex lens (teardrop) — intersection of two circles (r=145 mm, offset ±105 mm), extruded 10 mm height
- **Mechanism**: Streamlined bluff body — smoothly redirects flow around a symmetric lens shape, induces lateral spreading with lower separation loss than the sharp-apex chevron

---

## 3. Quantitative Postprocessing Results

### 3a. Patch-Averaged Results (OpenFOAM `foamPostProcess`)

| Patch | Field | Chevron | Teardrop |
|---|---|---|---|
| Inlet | p [m²/s²] | **0.07747** | **0.07606** |
| Inlet | U [m/s] | (0, −0.5, 0) | (0, −0.5, 0) |
| Outlet | p [m²/s²] | 0 (fixed) | 0 (fixed) |
| Outlet | U [m/s] | (≈0, −0.5, ≈0) | (≈0, −0.5, ≈0) |
| Bottom | p [m²/s²] | 0.03765 | — |
| Insert surface | p [m²/s²] | 0.02679 | 0.02633 |

**Pressure drop across domain** (inlet − outlet):
- Chevron: **Δp ≈ 0.0775 m²/s² = 0.0949 Pa** (kinematic)
- Teardrop: **Δp ≈ 0.0761 m²/s² = 0.0932 Pa** (kinematic)

### 3b. Volumetric Field Statistics (142,000+ cells)

| Metric | Chevron | Teardrop |
|---|---|---|
| Cell count | 142,466 | 141,386 |
| `|U|` mean [m/s] | 0.2704 | 0.2708 |
| `|U|` std [m/s] | 0.2252 | 0.2245 |
| `|U|` max [m/s] | 0.6528 | 0.6485 |
| `Uy` mean [m/s] | 0.2699 | 0.2703 |
| `Uy` std [m/s] | 0.2255 | 0.2248 |
| `Ux_max` lateral [m/s] | 0.0994 | **0.1573** |
| `Uz_max` vertical [m/s] | 0.0916 | **0.1371** |

---

## 4. Flow Maldistribution Metrics

> **Note**: Both cases have very similar overall distributions — the dominant driver of non-uniformity is the **boundary layer** (near-wall slow zones) and the **insert wake**, not geometric maldistribution *between channels* (this is a single-channel geometry). The metrics here reflect intra-channel flow non-uniformity.

| Metric | Formula | Chevron | Teardrop | Winner |
|---|---|---|---|---|
| **Velocity Uniformity Index (γ)** | 1 − Σ|u_i − ū| / (2ū·N) | 0.7263 | **0.7269** | Teardrop ▲ |
| **Coefficient of Variation (CoV)** | σ(Uy) / U_in | 0.4510 | **0.4496** | Teardrop ▼ |
| **Stagnation fraction** | %cells with Uy < 5% U_in | 7.55% | **5.39%** | Teardrop ▼ |
| **Lateral spreading (Ux_max)** | max\|Ux\| — redistribution | 0.0994 m/s | **0.1573 m/s** | Teardrop ▲ |
| **Vertical mixing (Uz_max)** | max\|Uz\| — cross-layer mixing | 0.0916 m/s | **0.1371 m/s** | Teardrop ▲ |
| **Δp total (hydraulic penalty)** | p_max − p_min × ρ | 0.1218 Pa | **0.1127 Pa** | Teardrop ▼ |
| **Uy std** | σ(Uy) | 0.2255 m/s | **0.2248 m/s** | Teardrop ▼ |

These single-mesh results do not establish a winner. The γ difference is 0.0006, and numerical uncertainty has not been quantified. The extrema-based Δp metric differs from the inlet-to-outlet pressure drop reported above.

---

## 5. Velocity Distribution Analysis

Both cases exhibit a **bimodal velocity distribution**:

```
Uy bin [m/s]     Chevron     Teardrop   Interpretation
──────────────────────────────────────────────────────────────
0.000 – 0.054      25.1%       24.6%    Near-wall / wake stagnation
0.054 – 0.270      31.8%       31.6%    Decelerated wake / channel transition
0.270 – 0.490      14.6%       14.3%    Mid-velocity transition zone
0.490 – 0.653      31.5%       33.7%    ← Core free-stream (near inlet U)
```

The **peak near 0.5 m/s** reflects the undisturbed free-stream away from the insert and walls.
The **peak near 0–0.054 m/s** reflects:
- No-slip boundary layers on all walls
- Insert wake recirculation (chevron creates a stronger, longer wake; teardrop wake is shorter/narrower)

> [!IMPORTANT]
> The reported stagnation fractions (7.55% and 5.39%) are cell-count-based indicators, not direct measurements of heat or mass transfer. Their sensitivity to mesh and threshold should be checked.

---

## 6. Physical Interpretation

### Chevron Insert
- **Sharp apex pointing upstream** creates a strong stagnation region at the leading edge
- Triangular shape forces flow **abruptly** to the sides (120 mm lateral deflection over 200 mm length)
- Generates a larger **separated wake** downstream of the trailing edge (back two corners of the triangle)
- Higher **pressure on windward face** (0.0268 Pa average on insert vs 0.0263 Pa for teardrop)
- Lateral spread limited by sharp geometry: Ux_max = 0.099 m/s

### Teardrop Insert
- **Streamlined biconvex lens** — no sharp leading edge, smooth flow attachment
- Intersection of two r=145 mm circles with ±105 mm offset creates a **symmetrical, aerodynamic profile**
- **Significantly more lateral spreading**: Ux_max = 0.157 m/s (+58% over chevron)
- **More vertical mixing**: Uz_max = 0.137 m/s (+50% over chevron)
- **Lower hydraulic penalty**: Δp = 0.113 Pa vs 0.122 Pa (−7.4%)
- **Smaller stagnation zone**: 5.4% vs 7.6% of domain
- The smooth curvature allows the flow to **reattach sooner** after the insert, reducing dead zones

### Why Teardrop Outperforms Chevron
The teardrop's aerodynamic shape avoids the **blunt-body separation** that the chevron's triangular trailing edge creates. The simulations assume laminar flow; the Reynolds number based on channel height is approximately 3,103. The physical regime and these proposed wake mechanisms require validation. The teardrop's smooth contours:
1. Maintain attached flow longer → less wake
2. Generate more lateral velocity (better redistribution across width)
3. Push more flow vertically (better cross-gap mixing)
4. Do so with **lower pressure cost**

---

## 7. Pressure Field Analysis

```
Metric              Chevron              Teardrop
────────────────────────────────────────────────────
p_min [m²/s²]      −0.0070             +0.0001
p_max [m²/s²]      +0.0924             +0.0921
p_mean [m²/s²]     +0.0273             +0.0268
p_std [m²/s²]       0.0204              0.0192
```

> [!NOTE]
> The chevron has a negative minimum gauge pressure (p_min = −0.007 m²/s²). Pressure extrema alone do not establish whether either flow is attached or separated.

The reported `p_std` is lower for teardrop (0.0192 vs 0.0204); this alone does not establish reduced flow maldistribution.

---

## 8. Conclusions & Recommendations

> [!TIP]
> **The teardrop has favorable values for several metrics in this single-mesh laminar-model comparison; a preferred geometry cannot yet be established.**

| Criterion | Chevron | Teardrop | Assessment |
|---|---|---|---|
| Flow uniformity (γ) | 0.726 | **0.727** | Marginal improvement (teardrop) |
| Stagnation control | 7.6% | **5.4%** | Significant improvement (teardrop) |
| Lateral redistribution | 0.099 m/s | **0.157 m/s** | +58% (teardrop) |
| Vertical mixing | 0.092 m/s | **0.137 m/s** | +50% (teardrop) |
| Pressure penalty | 0.122 Pa | **0.113 Pa** | −7.4% (teardrop) |

### Design Recommendations
1. **Treat the geometry ranking as preliminary** until mesh, time-step, model and experimental validation are available
2. **Stagger multiple inserts** along the channel length to progressively homogenize the velocity profile
3. **Consider increasing protrusion height** from 10 mm — assess its effect on the velocity field and wall resolution
4. **Explore periodic arrays** of teardrop inserts to generate cumulative lateral redistribution
5. The **near-wall stagnation zones** (25% of cells near Uy ≈ 0) are dominated by boundary layers on bottom/top/side walls, not just the insert wake — wall modifications (ribs, dimples) may address these more directly

### Next Steps
- Run with **T field active** (thermal BCs on insert surface) to assess heat transfer improvement
- Sweep protrusion heights: 5, 10, 15, 20 mm
- Compare multiple inserts in series
- Assess transition and turbulence-model sensitivity at the stated Reynolds number; compare against suitable validation data

---

*Generated by Antigravity CFD postprocessing | OpenFOAM 12 | 2026-06-26*

