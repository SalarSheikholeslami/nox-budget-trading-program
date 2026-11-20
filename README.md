
#  the Labor Market Effects of the NOx Budget Trading Program

**A Replication and Extension of Curtis (2018)**

**Author:** Salar Sheikholeslami  
**Institution:** Johannes Kepler University Linz (JKU), Austria  
**Project:** Seminar Research Project | Winter Semester 2025/26  
**Supervisor:** Prof. Ulrich Glogowsky  
**Software:** Stata

## Overview

This seminar project replicates and extends the empirical analysis in Curtis (2018), *Who Loses under Cap-and-Trade Programs? The Labor Market Effects of the NOx Budget Trading Program*.

It investigates the employment effects of the U.S. NOx Budget Trading Program (NBP), with a particular focus on manufacturing industries' energy intensity and the role of industrial electricity prices.

The analysis builds on a **triple-differences (DDD)** design, comparing employment outcomes across time, regulated and comparison states, and industries with different levels of energy intensity.

## Empirical Analyses

The project includes three complementary exercises:

### 1. Alternative Outcome: Employment Growth (MEA 1)

Re-estimates the DDD specifications using annual changes in log employment instead of employment levels to examine short-run employment growth.

### 2. Heterogeneity by Energy Intensity (MEA 2)

Tests whether employment effects are concentrated in the most energy-intensive manufacturing industries, comparing industries in the upper and lower quartiles of the energy-intensity distribution.

### 3. Electricity-Price Channel (TCA)

Incorporates additional state-year industrial electricity prices from the U.S. Energy Information Administration (EIA Form 861).

A price-weighted energy-intensity measure is constructed to investigate electricity costs as a potential mechanism underlying the policy's employment effects.

## Main Findings

- The replicated baseline results are consistent with the employment effects reported in Curtis (2018).
- Alternative employment-growth specifications do not show statistically significant short-run treatment effects.
- Employment-level effects are more pronounced among highly energy-intensive manufacturing industries.
- Results using electricity-price-weighted energy intensity are consistent with an electricity-cost channel, although they do not establish a separately identified causal mediation effect.

## Repository Contents

| File | Description |
|------|-------------|
| `MEA1 code.do` | Alternative outcome: employment growth |
| `MEA2 code.do` | Heterogeneity across high- and low-energy-intensity industries |
| `TCA code.do` | EIA electricity-price data preparation and price-channel analysis |

## Data and Reproducibility

The analysis uses:

- **County Business Patterns (CBP):** State-industry manufacturing employment data.
- **Industry energy intensity:** Industry-level energy-use information incorporated in the original empirical framework.
- **EIA Form 861:** State-year industrial electricity prices used in the project's extension.

The scripts reference supporting datasets including `cbp_st_table2.dta`, `stfueldata09_figureO4.dta`, and an EIA Form 861 Excel workbook.

**Reproducibility note:** The Stata scripts currently use local file paths and require external datasets. They have not yet been independently tested as a complete replication package.

Some scripts require user-written Stata commands, including `carryforward`, `eststo` (from `estout`), and `outreg2`.

## Original Study and Attribution

Curtis, E. M. (2018). *Who Loses under Cap-and-Trade Programs? The Labor Market Effects of the NOx Budget Trading Program.* **The Review of Economics and Statistics, 100**(1), 151–166.

This repository documents an **independent seminar replication and extension**, not the original author's research repository or an official replication package.

The baseline research design and original findings are credited to Curtis (2018). The alternative-outcome, heterogeneity, and additional electricity-price exercises were undertaken as part of this seminar project.

## Usage and Rights

No open-source licence has been assigned to the original materials in this repository. Third-party code, datasets, and other content remain subject to their respective terms.

Public availability does not grant unrestricted permission to reuse or redistribute these materials.

