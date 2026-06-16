Evaporative Demand Drought Index (EDDI) Computation in MATLAB
Overview

This repository contains MATLAB code for computing the Evaporative Demand Drought Index (EDDI) using daily reference evapotranspiration (ETo) data derived from ERA5 reanalysis datasets.

EDDI is a standardized drought index based on atmospheric evaporative demand and is particularly effective for detecting flash droughts and rapidly developing drought conditions.

Data Source

The analysis uses daily reference evapotranspiration (ETo) derived from ERA5 or ERA5-Land reanalysis datasets.

ERA5 Dataset Characteristics
Data source: European Centre for Medium-Range Weather Forecasts (ECMWF)
Spatial resolution: approximately 0.1°–0.25° depending on dataset version
Temporal resolution: Daily
Variable: Reference Evapotranspiration (ETo)
Study area: Sicily, Italy (example application for Catania)
Data Processing

The workflow includes the following preprocessing steps:

1. Data Loading

Daily ETo data are imported from MATLAB data files.

2. Leap Day Removal

February 29 observations are removed to maintain a constant 365-day climatology.

todd = find(month(t)==2 & day(t)==29);
3. Temporal Aggregation

Daily ETo values are accumulated using moving windows to represent evaporative demand over different timescales.

Supported aggregation periods include:

EDDI-7
EDDI-14
EDDI-30
EDDI-60
EDDI-90
EDDI-180
EDDI-365

Example:

e0k = movsum(e0,[k-1 0]);

where k represents the aggregation window length.

EDDI Computation
Step 1: Calendar-Day Climatology

For each day of the year (1–365), aggregated ETo values are extracted from all years.

Step 2: Distribution Fitting

A log-logistic probability distribution is fitted to each calendar-day climatology.

pdlog(i) = fitdist(e0kday,"Loglogistic");

The log-logistic distribution has been shown to provide robust performance for EDDI estimation.

Step 3: Probability Estimation

Cumulative probabilities are computed from the fitted distributions.

cdf(pdlog(i),e0kday)
Step 4: Standardization

Probabilities are transformed into standard normal variates.

norminv(probability,0,1)

The resulting values represent EDDI.

Step 5: Drought Classification

EDDI values are classified according to NOAA EDDI categories.

Percentile	Category
≥98%	Exceptional Drought
95–98%	Extreme Drought
90–95%	Severe Drought
80–90%	Moderate Drought
70–80%	Abnormally Dry
30–70%	Near Normal
20–30%	Abnormally Wet
10–20%	Moderate Wet
5–10%	Severe Wet
2–5%	Extreme Wet
<2%	Exceptional Wet
Outputs

The script generates:

EDDI Percentiles
eddikprob
Standardized EDDI Values
eddiknquant
EDDI Severity Classes
eddiprobclass
Visualization

The script produces:

EDDI percentile time series
Standardized EDDI time series
Aggregated ETo time series
Applications

This workflow can be used for:

Flash drought monitoring
Agricultural drought assessment
Hydrological drought studies
Climate variability analysis
Early warning systems
Climate change impact assessments
Author

Dr. Tagele Mossie Aschale

License

This repository is provided for research and educational purposes.
