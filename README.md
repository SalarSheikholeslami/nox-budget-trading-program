Revisiting the Labor Market Effects of the NOx Budget Trading Program
A Replication and Extension of Curtis (2018)
Author: Salar Sheikholeslami
Affiliation: Johannes Kepler University Linz
Project: Seminar research project, Winter Semester 2025/26
Supervisor: Prof. Ulrich Glogowsky
Software: Stata
Overview
This project replicates and extends the empirical analysis in Curtis (2018), Who Loses under Cap-and-Trade Programs? The Labor Market Effects of the NOx Budget Trading Program. It examines how the U.S. NOx Budget Trading Program affected manufacturing employment, with particular attention to differences across industries in energy intensity and to the potential role of industrial electricity prices.

The empirical framework uses triple differences (DDD), comparing employment outcomes across time, regulated and comparison states, and industries with different levels of energy intensity.
Analyses
1. Baseline replication and alternative outcome: Reproduces the main DDD framework and evaluates employment growth (annual changes in log employment) as an alternative to employment levels.
2. Heterogeneity by energy intensity: Examines whether estimated employment effects are concentrated in high-energy-intensity manufacturing industries, using indicators for the top and bottom energy-intensity quartiles.
3. Electricity-price channel: Incorporates additional state-year industrial electricity-price data from the U.S. Energy Information Administration (EIA-861) and constructs a price-weighted energy-intensity measure to explore the role of electricity costs.
Main findings
The baseline replication is consistent with Curtis (2018). In the extensions, employment-growth specifications do not show statistically significant short-run effects, while estimated employment-level reductions are more pronounced in the most energy-intensive industries. The electricity-price-weighted specifications also show a negative association between policy exposure and employment in several model specifications. These results are consistent with an electricity-cost mechanism, but the channel analysis should not be interpreted as definitive identification of a causal mediation effect.
Code
The current analysis is organised into three Stata scripts:
- MEA1 code.do — alternative employment-growth outcome.
- MEA2 code.do — heterogeneity by industrial energy intensity.
- TCA code.do — industrial electricity-price analysis using EIA data.
Before sharing the code as a reproducible research package, the scripts need to be standardised to use relative file paths and documented input-data locations.
Data and reproducibility
The research uses state-industry manufacturing employment data based on the County Business Patterns (CBP), industry energy-intensity measures, and additional state-year industrial electricity-price information from EIA Form 861. The supplied scripts also refer to supporting data files, including cbp_st_table2.dta, stfueldata09_figureO4.dta, and a source Excel workbook used to prepare the EIA electricity-price series.

Reproducibility status: The supplied scripts are research code, not yet a standalone, one-click replication package. They currently contain local computer paths and require input data that are not included in this repository. Please consult the cited sources and confirm data redistribution permissions before adding any underlying datasets.

Some scripts use community-contributed Stata commands including carryforward, eststo (from estout), and outreg2. The Stata version and package versions have not yet been pinned or independently tested in a clean environment.
Reference and attribution
Curtis, E. M. (2018). Who Loses under Cap-and-Trade Programs? The Labor Market Effects of the NOx Budget Trading Program. The Review of Economics and Statistics, 100(1), 151–166.

This is an independent seminar replication and extension, not the original Curtis (2018) article or an official replication archive. Original methods and findings should be attributed to Curtis (2018); the alternative outcome, energy-intensity heterogeneity exercise, and EIA-based electricity-price analysis are extensions undertaken for this seminar project.
Usage and rights
No open-source license is currently granted for the original materials in this repository. Third-party datasets, code, and other materials remain subject to their respective rights and terms. Public visibility does not by itself grant permission for unrestricted reuse.
