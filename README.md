# CORDEX ML-Bench: A benchmark for Machine Learning-Based Regional Climate Downscaling

CORDEX ML-Bench is a benchmark designed to evaluate the performance of machine learning–based climate downscaling models across different regions covering both the standard (perfect prognosis ESD) and emulation climate downscaling approaches. It defines standardized training and test experiments assessing various downscaling challenges along with the corresponding datasets from Regional Climate Models (RCMs) driven by different Global Climate Models (GCMs). 

This repository contains all the materials, instructions, and datasets required to run the different experiments, as well as notebooks illustrating the process. It also includes instructions for registering and submitting contributions to participate in the online benchmarking, with results publicly reported on this page.

**Development Status Notice**  
*This repository is currently under active development. As a result, the structure, documentation, datasets and experimental protocols may change in the near future. Users should be aware that updates may require adjustments to existing workflows. We recommend regularly checking for updates.*

## Dataset Overview

The benchmark covers three geographic regions: New Zealand (NZ), Europe (ALPS), and South Africa (SA), with ~10 km target resolution. Training and test datasets (NetCDF files, approximately 5 GB per domain) are provided for each region, including common predictors (Z, U, V, T, Q at 850, 700, 500, and 300 hPa, as well as model orography) and predictands (daily temperature and precipitation). More information is available in [./data](/data).

<div align="center">
<img src="./images/CORDEX_ML-bench_domains.png" alt="NZ Domain" width="500"/>
</div>

## Experiments

The benchmark covers two experiments with different tests focusing on the standard (perfect prognosis ESD) and emulation climate downscaling approaches. For each region, data is obtained from a single RCM driven by two different GCMs, one used both for training and testing (denoted below as `same GCM`) and the other only used to test transferability (denoted as `different GCM`). 

For both experiments, training is based on perfect (upscaled) predictors from the RCM while test experiments explore both perfect and imperfect (from the driving GCM) predictors. Predictands (target for training) correspond to the RCM highres 10km temperature and precipitation output.

- **Experiment 1: _ESD Pseudo-Reality_**: A 20-year (1961–1980) training period in present climate conditions, designed to mimic the standard statistical climate downscaling approach and test extrapolation capabilities of the methods. 

| Test   | Test Period | Predictor type | Eval | 
|----------------|---------------|----------------|------|
| Test1: Perfect Cross-Validation | Historical (1981–2000) | Perfect (from RCM), same GCM | Error, Clim | 
| Test2: Imperfect Cross-Validation | Historical (1981–2000) | Imperfect (from GCM), same GCM | Error, Clim | 
| Test3: Perfect Extrapolation | 2041–2060 + 2080–2099 | Perfect (from RCM), same GCM | change signal for mid/final term | 
| Test4: Imperfect Extrapolation | 2041–2060 + 2080–2099 | Imperfect (from GCM), same GCM | change signal for mid/final term | 
| Test5: Perfect Extrapolation (GCM Transferability) | 2041–2060 + 2080–2099 | Perfect (from RCM), different GCM | change signal for mid/final term | 


- **Experiment 2: _Emulator Hist+Future_**: A 40-year (1961–1980 + 2080–2099) training period combining present and future climates, focused on testing interpolation and transferability of emulators.

| Test   | Test Period | Predictor type | Eval | 
|----------------|---------------|----------------|------|
| Test1: Perfect Cross-Validation | Historical (1981–2000) | Perfect (from RCM), same GCM | Error, Clim | 
| Test2: Imperfect Cross-Validation | Historical (1981–2000) | Imperfect (from GCM), same GCM | Error, Clim | 
| Test3: Perfect Interpolation  | 2041–2060  | Perfect (from RCM), same GCM | Change signal | 
| Test4: Imperfect Interpolation | 2041–2060  | Imperfect (from GCM), same GCM | Change signal | 
| Test5: Perfect Interpolation (GCM Transferability) | 2041–2060  | Perfect (from RCM), different GCM | Change signal | 
| Test6: Imperfect Interpolation (GCM Transferability) | 2041–2060  | Imperfect (from GCM), different GCM | Change signal | 


## Model Training and Evaluation

For each experiment, models must be trained for the two required target variables (temperature and precipitation), jointly (multivariate) or individually. If possible, please train the models both with and without model orography as a covariate (this will correspond to two separate submissions; for more details, see “Contributing to the benchmark”). This will allow us to assess the importance of including such covariates in the models. Some examples of model training can be found in [./training](./training).

A comprehensive set of evaluation diagnostics and accompanying code for assessing ML-based downscaling methods within the CORDEX ML-Bench framework is provided in this repository ([./evaluation](/evaluation)). Similar diagnostics will be used for online benchmarking, so users can use these as guidelines for developing their models.

## Contributing to the benchmark

Benchmarking allows users to benchmark the performance of their own models against well-established reference approaches. Contributing to the online benchmarking (with automatic evaluation and publicly available results in the benchmark table) requires model registration and uploading the test results for the different experiments. For more details on the registration and submission process, see [./submission](/submission).

The table below summarizes the contributing models and provides links to their respective implementation repositories when available (this table is automatically updated with new submissions).

## Models contributing to the benchmark

| Model | Description | Reference | Implementation |
|-------|-------------|-----------|----------------|
| ViT-IFCAv1 | Vision Transformer (ViT) | [In preparation]() | [GitHub](https://github.com/jgonzalezab/ViT_CORDEX-ML-Bench) |
| Rossby-UNet | U-Net + CBAM (5 enc/dec layers) | [In preparation]() | [In preparation]() |
| DetUNet | U-Net + self-attention + FiLM (~3M params) | [Rampal et al., 2025](https://agupubs.onlinelibrary.wiley.com/doi/full/10.1029/2024MS004668) | [GitHub](https://github.com/nram812/Generative-CORDEX-ML-Bench/tree/main/models) |
| CNRM-UNeT | Asymmetric U-Net + 1D bottleneck | [Doury et al., 2022](https://link.springer.com/article/10.1007/s00382-022-06343-9); [Doury et al., 2024](https://link.springer.com/article/10.1007/s00382-024-07350-8) | [GitHub](https://github.com/antoinedoury/RCM-Emulator) |
| Prithvi-UNet | Foundation model (Prithvi-WxC) + UNet decoder | [Schmude et al., 2024](https://arxiv.org/abs/2409.13598) | [GitHub](https://github.com/midatm1234/granite-wxc/tree/CORDEX_ML) |
| GNN4CD_Rall | Graph Neural Network (GATv2Conv, 10 layers) | [In Blasone et al., 2025](https://www.cambridge.org/core/journals/environmental-data-science/article/graph-neural-networks-for-hourly-precipitation-projections-at-the-convection-permitting-scale-with-a-novel-hybrid-imperfect-framework/97EEB267EA2AE5F9D87D50A9492264A7) | [GitHub](https://github.com/valebl/GNN4CD) |
| ParamUNET | U-Net outputting distribution parameters | [In preparation]() | [In preparation]() |
| DeepESD-IFCAv1 | Deep CNN (3 conv + 1 dense) | [González-Abad et al., 2025](https://journals.ametsoc.org/view/journals/aies/4/4/AIES-D-24-0121.1.xml) | [GitHub](https://github.com/jgonzalezab/deepESD_CORDEX-ML-Bench) |
| DeepESD-IDL | Deep CNN (3 conv + 1 dense) | [Soares et al., 2024](https://gmd.copernicus.org/articles/17/229/2024/) | [GitHub](https://github.com/rtomeidl/CordexML_DeepESD) |
| DeepSensor | Neural Process (parameterized GP) | [DeepSensor's Documentation](https://alan-turing-institute.github.io/deepsensor/) | [GitHub](https://github.com/alan-turing-institute/deepsensor) |
| ANN | Multi-layer perceptron (2 layers) | [Olmo and Bettolli, 2021](https://rmets.onlinelibrary.wiley.com/doi/10.1002/joc.7303) | [GitLab](https://gitlab.earth.bsc.es/molmo/ann_cordex_ml) |
| XGBoost | Gradient boosted decision trees | [Bushenkova et al., 2021](https://www.sciencedirect.com/science/article/pii/S2212095524001780) | [GitHub](https://github.com/rtomeidl/CordexML_XGBoost) |
| FlowMatching-v1 | Flow matching + ADM U-Net | [Wetherell 2026](https://arxiv.org/abs/2606.00281) | [GitHub](https://github.com/mo-tomaswetherell/mo-flow-cordexbench) |
| ResGAN | Residual WGAN (U-Net mean + GAN residual) | [Rampal et al., 2025](https://agupubs.onlinelibrary.wiley.com/doi/full/10.1029/2024MS004668) | [GitHub](https://github.com/nram812/Generative-CORDEX-ML-Bench/tree/main/models) |
| SpaGAN | UNet2D GAN + convolutional discriminator | [Glawion et al., 2025](https://www.nature.com/articles/s41612-025-01103-y) | [GitHub](https://github.com/jpolz/ml-benchmark-spategan) |
| EnScale | Multi-step sparse localised downscaling | [Schillinger et al., 2025](https://arxiv.org/abs/2509.26258v2) | [GitHub](https://github.com/m-schillinger/cordexbench) |
| EnScale-linex | EnScale + linear residual model | [Schillinger et al., 2025](https://arxiv.org/abs/2509.26258v2) | [GitHub](https://github.com/m-schillinger/cordexbench) |
| UiBCorrDiff | Corrective diffusion (regression U-Net + EDM diffusion) | [Marani et al., 2025](https://www.nature.com/articles/s43247-025-02042-5) | [GitHub](https://github.com/joshdorrington/UiBcorrdiff) |
| CorrDiff-TW1 | Physics-inspired UNet regression + EDM diffusion | [Marani et al., 2025](https://www.nature.com/articles/s43247-025-02042-5) | [GitHub](https://github.com/NVIDIA/physicsnemo/tree/main/examples/weather/corrdiff) |
| ParamDiffusion | Diffusion on ParamUNET background | [In preparation]() | [In preparation]() |
| RCMGEM | NCSN++ diffusion (sub-VP SDE) | [Addison et al., 2026](https://agupubs.onlinelibrary.wiley.com/doi/10.1029/2025MS005140) | [Zenodo](https://zenodo.org/records/18481925) |


## Scoreboard

Performance of the submitted models in the four perfect-predictor tests, one table per variable. The tables are generated automatically from the evaluation results in `data/<MODEL>/evaluation/` by [`evaluation/scoreboard.py`](./evaluation/scoreboard.py); do not edit them by hand.

<!-- SCOREBOARD:START -->

Metrics are computed per domain by `ml-eval benchmark` and aggregated across
domains (quadratic mean for RMSE and LHD, arithmetic mean otherwise). Biases are
spatial means of the absolute bias, in the units of the variable. ↓ lower is
better, ↑ higher is better. Each cell shows the two tests of a training
experiment, in the order given in the column header; the best value of each test
is in bold, and – marks results not available.

### Daily maximum temperature

<table>
  <thead>
    <tr>
      <th rowspan="2">Model</th>
      <th colspan="6">ESD<br><sub>Perfect cross-validation / Perfect extrapolation</sub></th>
      <th colspan="6">Emulator<br><sub>Perfect cross-validation / Perfect interpolation</sub></th>
    </tr>
    <tr>
      <th>RMSE ↓</th>
      <th>Clim Mean ↓</th>
      <th>TXx ↓</th>
      <th>RALSD ↓</th>
      <th>PSS ↑</th>
      <th>IAV ↓</th>
      <th>RMSE ↓</th>
      <th>Clim Mean ↓</th>
      <th>TXx ↓</th>
      <th>RALSD ↓</th>
      <th>PSS ↑</th>
      <th>IAV ↓</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>DeepESD-IFCAv1</td>
      <td align="right">1.52<br>1.81</td>
      <td align="right">0.178<br>0.61</td>
      <td align="right">0.681<br>1.09</td>
      <td align="right">6.41<br>7</td>
      <td align="right">0.976<br>0.952</td>
      <td align="right">0.126<br>0.128</td>
      <td align="right">–<br><b>1.44</b></td>
      <td align="right">–<br><b>0.208</b></td>
      <td align="right">–<br><b>0.606</b></td>
      <td align="right">–<br><b>4.63</b></td>
      <td align="right">–<br><b>0.976</b></td>
      <td align="right">–<br><b>0.0907</b></td>
    </tr>
    <tr>
      <td>DeepESD-IFCAv1-orog</td>
      <td align="right">1.39<br><b>1.5</b></td>
      <td align="right"><b>0.156</b><br><b>0.304</b></td>
      <td align="right"><b>0.601</b><br><b>0.693</b></td>
      <td align="right"><b>3.6</b><br><b>2.83</b></td>
      <td align="right"><b>0.981</b><br><b>0.975</b></td>
      <td align="right"><b>0.116</b><br><b>0.09</b></td>
      <td align="right">–<br>–</td>
      <td align="right">–<br>–</td>
      <td align="right">–<br>–</td>
      <td align="right">–<br>–</td>
      <td align="right">–<br>–</td>
      <td align="right">–<br>–</td>
    </tr>
    <tr>
      <td>DetUNet</td>
      <td align="right"><b>1.31</b><br>1.74</td>
      <td align="right">0.239<br>0.888</td>
      <td align="right">0.793<br>1.97</td>
      <td align="right">5.49<br>4.43</td>
      <td align="right">0.978<br>0.926</td>
      <td align="right">0.188<br>0.19</td>
      <td align="right">–<br>–</td>
      <td align="right">–<br>–</td>
      <td align="right">–<br>–</td>
      <td align="right">–<br>–</td>
      <td align="right">–<br>–</td>
      <td align="right">–<br>–</td>
    </tr>
  </tbody>
</table>

### Daily precipitation

<table>
  <thead>
    <tr>
      <th rowspan="2">Model</th>
      <th colspan="6">ESD<br><sub>Perfect cross-validation / Perfect extrapolation</sub></th>
      <th colspan="6">Emulator<br><sub>Perfect cross-validation / Perfect interpolation</sub></th>
    </tr>
    <tr>
      <th>RMSE ↓</th>
      <th>Clim Mean ↓</th>
      <th>SDII ↓</th>
      <th>Rx1day ↓</th>
      <th>RALSD ↓</th>
      <th>LHD ↓</th>
      <th>RMSE ↓</th>
      <th>Clim Mean ↓</th>
      <th>SDII ↓</th>
      <th>Rx1day ↓</th>
      <th>RALSD ↓</th>
      <th>LHD ↓</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>DeepESD-IFCAv1</td>
      <td align="right"><b>4.1</b><br><b>4.64</b></td>
      <td align="right">0.145<br>0.185</td>
      <td align="right">0.918<br>1.08</td>
      <td align="right"><b>13.3</b><br>16.9</td>
      <td align="right">84.4<br>104</td>
      <td align="right">10.6<br>10.7</td>
      <td align="right">–<br><b>4.42</b></td>
      <td align="right">–<br><b>0.129</b></td>
      <td align="right">–<br><b>0.588</b></td>
      <td align="right">–<br><b>12.1</b></td>
      <td align="right">–<br><b>91.8</b></td>
      <td align="right">–<br><b>7.9</b></td>
    </tr>
    <tr>
      <td>DeepESD-IFCAv1-orog</td>
      <td align="right">4.13<br>4.67</td>
      <td align="right"><b>0.11</b><br><b>0.134</b></td>
      <td align="right"><b>0.681</b><br><b>0.82</b></td>
      <td align="right">13.8<br>17.7</td>
      <td align="right">83.2<br><b>99</b></td>
      <td align="right">9.41<br>10.2</td>
      <td align="right">–<br>–</td>
      <td align="right">–<br>–</td>
      <td align="right">–<br>–</td>
      <td align="right">–<br>–</td>
      <td align="right">–<br>–</td>
      <td align="right">–<br>–</td>
    </tr>
    <tr>
      <td>DetUNet<sup>†</sup></td>
      <td align="right">5.54<br>5.14</td>
      <td align="right">0.496<br>0.46</td>
      <td align="right">1.57<br>1.38</td>
      <td align="right">14.7<br><b>14.9</b></td>
      <td align="right"><b>45</b><br>135</td>
      <td align="right"><b>2.06</b><br><b>6.04</b></td>
      <td align="right">–<br>–</td>
      <td align="right">–<br>–</td>
      <td align="right">–<br>–</td>
      <td align="right">–<br>–</td>
      <td align="right">–<br>–</td>
      <td align="right">–<br>–</td>
    </tr>
  </tbody>
</table>

† Aggregated over a subset of domains only (DetUNet, ESD, Perfect cross-validation: ALPS, NZ).

<!-- SCOREBOARD:END -->

## Requirements

The [./requirements](./requirements) directory contains an `environment.yaml` file that allows users to easily recreate the Conda environment required to run all scripts in this repository. To create the environment, run the following command:

```bash
conda env create -f environment.yaml
```
Alternatively, the basic requirements to run these scripts are:

```
os
requests
zipfile
xarray
netcdf4
matplotlib
cartopy
numpy
torch
```
These packages can be installed using any package management tool.

## Citation

> Rampal, N., González-Abad, J., Addison, H., Baño-Medina, J., Bettolli, M. L., Blasone, V., Booth, B., Coppola, E., Di Gioia, S., Oldham-Dorrington, J., Doury, A., Engelbrecht, F., Fuentes-Franco, R., Gibson, P. B., Glawion, L., Hardy, C., Ivanov, M., Lee, H. K., Legasa, M. N., Olmo, M., Orr, A., Polz, J., Rogers, M. S. J., Schillinger, M., Sharma, S., Soares, P. M. M., Sobolowski, S., Steinkopf, J., Tang, W., Tian, J.-B., Tomé, R., Wang, K.-C., Wang, Y.-C., Watson, P. A. G., Wetherell, T., Widmann, M., & Gutiérrez, J. M. (2026). *CORDEX-ML-Bench: A Benchmark for Data-Driven Regional Climate Downscaling — Experiment Design and Overview*. arXiv:2606.29172. https://arxiv.org/abs/2606.29172

## Contact

Include an issue in this repository
