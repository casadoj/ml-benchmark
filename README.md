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
      <th>Clim. Mean ↓</th>
      <th>TXx ↓</th>
      <th>RALSD ↓</th>
      <th>PSS ↑</th>
      <th>IAV ↓</th>
      <th>RMSE ↓</th>
      <th>Clim. Mean ↓</th>
      <th>TXx ↓</th>
      <th>RALSD ↓</th>
      <th>PSS ↑</th>
      <th>IAV ↓</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>ANN</td>
      <td align="right">1.94<br>2.83</td>
      <td align="right">0.157<br>0.336</td>
      <td align="right">1.7<br>11</td>
      <td align="right">4.28<br>4.65</td>
      <td align="right">0.966<br>0.951</td>
      <td align="right">0.153<br>0.111</td>
      <td align="right">1.69<br>1.74</td>
      <td align="right">0.175<br>0.248</td>
      <td align="right">1.1<br>1.07</td>
      <td align="right">5.8<br>5.38</td>
      <td align="right">0.967<br>0.967</td>
      <td align="right">0.155<br>0.107</td>
    </tr>
    <tr>
      <td>ANN-orog</td>
      <td align="right">1.62<br>1.76</td>
      <td align="right">0.137<br>0.348</td>
      <td align="right">0.824<br>1.03</td>
      <td align="right">3.61<br>2.62</td>
      <td align="right">0.973<br>0.969</td>
      <td align="right">0.149<br>0.118</td>
      <td align="right">1.52<br>1.58</td>
      <td align="right">0.189<br>0.226</td>
      <td align="right">0.96<br>0.954</td>
      <td align="right">4.67<br>4.18</td>
      <td align="right">0.972<br>0.973</td>
      <td align="right">0.145<br>0.109</td>
    </tr>
    <tr>
      <td>DeepESD-IFCAv1</td>
      <td align="right">1.52<br>1.81</td>
      <td align="right">0.178<br>0.61</td>
      <td align="right">0.681<br>1.09</td>
      <td align="right">6.41<br>7</td>
      <td align="right">0.976<br>0.952</td>
      <td align="right">0.126<br>0.128</td>
      <td align="right">1.4<br>1.44</td>
      <td align="right">0.176<br>0.208</td>
      <td align="right">0.579<br>0.606</td>
      <td align="right">4.73<br>4.63</td>
      <td align="right">0.976<br>0.976</td>
      <td align="right">0.118<br>0.0907</td>
    </tr>
    <tr>
      <td>DeepESD-IFCAv1-orog</td>
      <td align="right">1.39<br><b>1.5</b></td>
      <td align="right">0.156<br><b>0.304</b></td>
      <td align="right">0.601<br><b>0.693</b></td>
      <td align="right">3.6<br>2.83</td>
      <td align="right">0.981<br>0.975</td>
      <td align="right">0.116<br>0.09</td>
      <td align="right">1.36<br>1.38</td>
      <td align="right">0.212<br>0.196</td>
      <td align="right">0.61<br>0.581</td>
      <td align="right">4.01<br>3.69</td>
      <td align="right">0.973<br>0.974</td>
      <td align="right">0.115<br>0.0913</td>
    </tr>
    <tr>
      <td>DeepESD_IDL</td>
      <td align="right">8.94<br>8.59</td>
      <td align="right">2.1<br>2.22</td>
      <td align="right">6.78<br>5.35</td>
      <td align="right">10.1<br>10.7</td>
      <td align="right">0.82<br>0.847</td>
      <td align="right">0.356<br>0.191</td>
      <td align="right">6.9<br>7.56</td>
      <td align="right">1.22<br>1.51</td>
      <td align="right">4.8<br>4.47</td>
      <td align="right">9.9<br>10</td>
      <td align="right">0.858<br>0.86</td>
      <td align="right">0.248<br>0.189</td>
    </tr>
    <tr>
      <td>DeepESDcrps_IFCAv2</td>
      <td align="right">4.2<br>4.46</td>
      <td align="right">0.253<br>0.961</td>
      <td align="right">5.24<br>6</td>
      <td align="right">35.1<br>34.7</td>
      <td align="right">0.904<br>0.877</td>
      <td align="right"><b>0.0976</b><br>0.126</td>
      <td align="right">2.37<br>2.41</td>
      <td align="right">0.275<br>0.301</td>
      <td align="right">1.62<br>1.79</td>
      <td align="right">12.8<br>12.5</td>
      <td align="right">0.964<br>0.961</td>
      <td align="right">0.128<br>0.0904</td>
    </tr>
    <tr>
      <td>DeepESDcrps_IFCAv2-orog</td>
      <td align="right">2.19<br>2.32</td>
      <td align="right">0.216<br>0.434</td>
      <td align="right">0.978<br>1.42</td>
      <td align="right">2.28<br>1.72</td>
      <td align="right">0.976<br>0.963</td>
      <td align="right">0.141<br>0.096</td>
      <td align="right">2.12<br>2.12</td>
      <td align="right">0.281<br>0.229</td>
      <td align="right">1.26<br>1.2</td>
      <td align="right"><b>2.65</b><br><b>2.33</b></td>
      <td align="right">0.974<br>0.975</td>
      <td align="right">0.13<br>0.0899</td>
    </tr>
    <tr>
      <td>DeepSensor</td>
      <td align="right">2.27<br>2.33</td>
      <td align="right">0.67<br>0.723</td>
      <td align="right">1.88<br>1.99</td>
      <td align="right">157<br>159</td>
      <td align="right">0.958<br>0.958</td>
      <td align="right">0.0979<br><b>0.0829</b></td>
      <td align="right">2.06<br>2.12</td>
      <td align="right">0.58<br>0.62</td>
      <td align="right">1.43<br>1.55</td>
      <td align="right">146<br>149</td>
      <td align="right">0.958<br>0.959</td>
      <td align="right">0.121<br>0.0965</td>
    </tr>
    <tr>
      <td>DeepSensor-orog</td>
      <td align="right">1.5<br>1.67</td>
      <td align="right">0.333<br>0.349</td>
      <td align="right">0.844<br>0.871</td>
      <td align="right">94.3<br>96.9</td>
      <td align="right">0.969<br><b>0.979</b></td>
      <td align="right">0.0985<br>0.0888</td>
      <td align="right">1.52<br>1.71</td>
      <td align="right">0.35<br>0.363</td>
      <td align="right">0.712<br>0.788</td>
      <td align="right">109<br>113</td>
      <td align="right">0.967<br>0.976</td>
      <td align="right">0.109<br>0.0966</td>
    </tr>
    <tr>
      <td>DetUNet</td>
      <td align="right">1.31<br>1.74</td>
      <td align="right">–<br>–</td>
      <td align="right">–<br>–</td>
      <td align="right">5.49<br>4.43</td>
      <td align="right">0.978<br>0.926</td>
      <td align="right">–<br>–</td>
      <td align="right">1.56<br>–</td>
      <td align="right">–<br>–</td>
      <td align="right">–<br>–</td>
      <td align="right">7.03<br>–</td>
      <td align="right">0.92<br>–</td>
      <td align="right">–<br>–</td>
    </tr>
    <tr>
      <td>DetUNet-orog</td>
      <td align="right"><b>1.3</b><br>1.75</td>
      <td align="right">0.259<br>0.935</td>
      <td align="right">1.28<br>2.46</td>
      <td align="right">4.97<br>4.04</td>
      <td align="right">0.977<br>0.923</td>
      <td align="right">0.196<br>0.199</td>
      <td align="right">1.61<br>1.32</td>
      <td align="right">0.906<br>0.487</td>
      <td align="right">0.874<br><b>0.48</b></td>
      <td align="right">4.84<br>3.72</td>
      <td align="right">0.912<br>0.948</td>
      <td align="right">0.149<br>0.138</td>
    </tr>
    <tr>
      <td>DetUNet-v2</td>
      <td align="right">1.46<br>1.69</td>
      <td align="right">0.124<br>0.419</td>
      <td align="right">1.02<br>2.14</td>
      <td align="right">5.59<br>4.38</td>
      <td align="right">0.972<br>0.952</td>
      <td align="right">0.165<br>0.139</td>
      <td align="right">1.39<br>1.36</td>
      <td align="right">0.297<br>0.223</td>
      <td align="right">0.522<br>0.508</td>
      <td align="right">7.68<br>5.7</td>
      <td align="right">0.955<br>0.967</td>
      <td align="right">0.128<br>0.101</td>
    </tr>
    <tr>
      <td>DetUNet-v2-orog</td>
      <td align="right">1.37<br>1.61</td>
      <td align="right">0.136<br>0.399</td>
      <td align="right"><b>0.599</b><br>1.66</td>
      <td align="right">4.89<br>3.7</td>
      <td align="right">0.982<br>0.958</td>
      <td align="right">0.151<br>0.125</td>
      <td align="right">1.37<br>1.33</td>
      <td align="right">0.333<br>0.244</td>
      <td align="right"><b>0.499</b><br>0.501</td>
      <td align="right">7.25<br>5.48</td>
      <td align="right">0.955<br>0.968</td>
      <td align="right">0.123<br>0.0976</td>
    </tr>
    <tr>
      <td>GNN4CD-orog</td>
      <td align="right">1.49<br>1.68</td>
      <td align="right">0.224<br>0.417</td>
      <td align="right">0.918<br>1.59</td>
      <td align="right">8.63<br>7.89</td>
      <td align="right">–<br>–</td>
      <td align="right">0.102<br>0.103</td>
      <td align="right">1.44<br>1.48</td>
      <td align="right">0.287<br>0.261</td>
      <td align="right">0.695<br>0.726</td>
      <td align="right">8.04<br>7.7</td>
      <td align="right">–<br>–</td>
      <td align="right"><b>0.0887</b><br>0.0815</td>
    </tr>
    <tr>
      <td>ParamUNET</td>
      <td align="right">1.32<br>1.52</td>
      <td align="right">–<br>–</td>
      <td align="right">–<br>–</td>
      <td align="right">14.6<br>13.4</td>
      <td align="right"><b>0.986</b><br>0.971</td>
      <td align="right">–<br>–</td>
      <td align="right"><b>1.23</b><br><b>1.28</b></td>
      <td align="right">–<br>–</td>
      <td align="right">–<br>–</td>
      <td align="right">17.4<br>16.1</td>
      <td align="right">0.982<br>0.976</td>
      <td align="right">–<br>–</td>
    </tr>
    <tr>
      <td>Prithvi-UNet</td>
      <td align="right">1.61<br>1.75</td>
      <td align="right">0.402<br>0.447</td>
      <td align="right">0.701<br>1.48</td>
      <td align="right">5.09<br>3.77</td>
      <td align="right">0.967<br>0.965</td>
      <td align="right">0.125<br>0.137</td>
      <td align="right">1.53<br>1.54</td>
      <td align="right">0.309<br>0.244</td>
      <td align="right">0.702<br>0.678</td>
      <td align="right">7.89<br>5.99</td>
      <td align="right">0.97<br>0.977</td>
      <td align="right">0.103<br>0.0955</td>
    </tr>
    <tr>
      <td>Prithvi-UNet-orog<sup>†</sup></td>
      <td align="right">1.59<br>1.9</td>
      <td align="right">0.692<br>0.848</td>
      <td align="right">0.809<br>1.23</td>
      <td align="right">6.65<br>8.39</td>
      <td align="right">0.965<br>0.96</td>
      <td align="right">0.111<br>0.089</td>
      <td align="right">1.43<br>1.45</td>
      <td align="right">0.555<br>0.535</td>
      <td align="right">0.708<br>0.745</td>
      <td align="right">6.96<br>5.92</td>
      <td align="right">0.977<br>0.978</td>
      <td align="right">0.0966<br>0.0801</td>
    </tr>
    <tr>
      <td>Rossby-UNet</td>
      <td align="right">1.44<br>1.88</td>
      <td align="right">0.127<br>0.8</td>
      <td align="right">0.909<br>2.63</td>
      <td align="right">2.3<br>1.47</td>
      <td align="right">0.985<br>0.931</td>
      <td align="right">0.187<br>0.251</td>
      <td align="right">1.3<br>1.36</td>
      <td align="right">0.122<br><b>0.1</b></td>
      <td align="right">0.541<br>0.498</td>
      <td align="right">4.27<br>3.14</td>
      <td align="right"><b>0.986</b><br><b>0.988</b></td>
      <td align="right">0.139<br><b>0.0534</b></td>
    </tr>
    <tr>
      <td>Rossby-UNet-orog</td>
      <td align="right">1.4<br>1.8</td>
      <td align="right">0.137<br>0.683</td>
      <td align="right">0.765<br>2.04</td>
      <td align="right"><b>2.27</b><br><b>1.21</b></td>
      <td align="right">0.985<br>0.938</td>
      <td align="right">0.172<br>0.22</td>
      <td align="right">1.24<br>1.3</td>
      <td align="right">0.115<br>0.115</td>
      <td align="right">0.522<br>0.504</td>
      <td align="right">4.24<br>3.11</td>
      <td align="right">0.986<br>0.988</td>
      <td align="right">0.14<br>0.0569</td>
    </tr>
    <tr>
      <td>XGBoost_IDL</td>
      <td align="right">1.33<br>1.56</td>
      <td align="right"><b>0.111</b><br>0.353</td>
      <td align="right">1.04<br>2.67</td>
      <td align="right">12.2<br>14.9</td>
      <td align="right">0.979<br>0.953</td>
      <td align="right">0.151<br>0.133</td>
      <td align="right">1.27<br>1.3</td>
      <td align="right"><b>0.0842</b><br>0.111</td>
      <td align="right">0.55<br>0.56</td>
      <td align="right">12.3<br>12.6</td>
      <td align="right">0.979<br>0.979</td>
      <td align="right">0.138<br>0.0987</td>
    </tr>
  </tbody>
</table>

† Aggregated over a subset of domains only (Prithvi-UNet-orog, ESD, Perfect extrapolation: ALPS, SA).

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
      <th>Clim. Mean ↓</th>
      <th>SDII ↓</th>
      <th>Rx1day ↓</th>
      <th>RALSD ↓</th>
      <th>LHD ↓</th>
      <th>RMSE ↓</th>
      <th>Clim. Mean ↓</th>
      <th>SDII ↓</th>
      <th>Rx1day ↓</th>
      <th>RALSD ↓</th>
      <th>LHD ↓</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>ANN</td>
      <td align="right">6.89<br>7.8</td>
      <td align="right">0.213<br>0.251</td>
      <td align="right">2.6<br>2.89</td>
      <td align="right">46.2<br>55.1</td>
      <td align="right">90.8<br>99.5</td>
      <td align="right">13<br>14.5</td>
      <td align="right">6.76<br>7.64</td>
      <td align="right">0.181<br>0.23</td>
      <td align="right">2.53<br>2.93</td>
      <td align="right">45.1<br>54.1</td>
      <td align="right">96.5<br>112</td>
      <td align="right">12.2<br>12.6</td>
    </tr>
    <tr>
      <td>ANN-orog</td>
      <td align="right">6.89<br>7.82</td>
      <td align="right">0.236<br>0.302</td>
      <td align="right">2.6<br>2.85</td>
      <td align="right">45.8<br>54.7</td>
      <td align="right">96.2<br>101</td>
      <td align="right">13<br>12.2</td>
      <td align="right">6.77<br>7.66</td>
      <td align="right">0.223<br>0.288</td>
      <td align="right">2.63<br>3.03</td>
      <td align="right">45.7<br>55</td>
      <td align="right">105<br>120</td>
      <td align="right">11<br>13.9</td>
    </tr>
    <tr>
      <td>DeepESD-IFCAv1</td>
      <td align="right">6.38<br>7.28</td>
      <td align="right">0.369<br>0.46</td>
      <td align="right">1.93<br>2.37</td>
      <td align="right">32.7<br>41.5</td>
      <td align="right">84.4<br>104</td>
      <td align="right">10.6<br>10.7</td>
      <td align="right">6.16<br>6.98</td>
      <td align="right">0.308<br>0.33</td>
      <td align="right">1.3<br>1.52</td>
      <td align="right">26.1<br>32.1</td>
      <td align="right">82.9<br>91.8</td>
      <td align="right">8.25<br>7.9</td>
    </tr>
    <tr>
      <td>DeepESD-IFCAv1-orog</td>
      <td align="right">6.37<br>7.23</td>
      <td align="right">0.311<br>0.352</td>
      <td align="right">1.62<br>2.01</td>
      <td align="right">33<br>41.8</td>
      <td align="right">83.2<br>99</td>
      <td align="right">9.41<br>10.2</td>
      <td align="right">6.16<br>6.98</td>
      <td align="right">0.307<br>0.35</td>
      <td align="right">1.29<br>1.52</td>
      <td align="right">27.1<br>33.7</td>
      <td align="right">82.2<br>92.6</td>
      <td align="right">7.99<br>8.02</td>
    </tr>
    <tr>
      <td>DeepESD_IDL</td>
      <td align="right">9.04<br>10.2</td>
      <td align="right"><b>0.156</b><br><b>0.222</b></td>
      <td align="right"><b>0.577</b><br>0.902</td>
      <td align="right">18.4<br>24.4</td>
      <td align="right">207<br>194</td>
      <td align="right">6.12<br>6.79</td>
      <td align="right">9.13<br>10.2</td>
      <td align="right">0.152<br>0.152</td>
      <td align="right"><b>0.496</b><br><b>0.633</b></td>
      <td align="right">19.2<br>20.2</td>
      <td align="right">211<br>199</td>
      <td align="right">6.63<br>6.89</td>
    </tr>
    <tr>
      <td>DeepESDcrps_IFCAv2</td>
      <td align="right">8.02<br>8.83</td>
      <td align="right">0.236<br>0.38</td>
      <td align="right">0.692<br>1.02</td>
      <td align="right">28.8<br>38.1</td>
      <td align="right">51.9<br>58.5</td>
      <td align="right">8.8<br>9.74</td>
      <td align="right">8.36<br>9.25</td>
      <td align="right">0.156<br>0.174</td>
      <td align="right">0.745<br>0.778</td>
      <td align="right"><b>12.4</b><br><b>18.1</b></td>
      <td align="right">41.1<br>46.2</td>
      <td align="right">4.9<br>5.3</td>
    </tr>
    <tr>
      <td>DeepESDcrps_IFCAv2-orog</td>
      <td align="right">8<br>8.8</td>
      <td align="right">0.334<br>0.374</td>
      <td align="right">0.856<br><b>0.832</b></td>
      <td align="right">30.8<br>40.7</td>
      <td align="right"><b>30.6</b><br><b>34.7</b></td>
      <td align="right">9.35<br>9.83</td>
      <td align="right">8.05<br>8.83</td>
      <td align="right">0.579<br>0.587</td>
      <td align="right">1.18<br>1.02</td>
      <td align="right">27.7<br>36.4</td>
      <td align="right"><b>28</b><br><b>28.8</b></td>
      <td align="right">8.76<br>9.38</td>
    </tr>
    <tr>
      <td>DeepSensor</td>
      <td align="right">7.86<br>8.76</td>
      <td align="right">1.55<br>1.61</td>
      <td align="right">4.14<br>4.58</td>
      <td align="right">53.9<br>63.6</td>
      <td align="right">1018<br>1045</td>
      <td align="right">11.6<br>12.3</td>
      <td align="right">7.26<br>8.03</td>
      <td align="right">0.715<br>0.775</td>
      <td align="right">2.3<br>2.44</td>
      <td align="right">48.1<br>57.1</td>
      <td align="right">295<br>405</td>
      <td align="right">17.9<br>18.8</td>
    </tr>
    <tr>
      <td>DeepSensor-orog</td>
      <td align="right">6.76<br>7.71</td>
      <td align="right">0.481<br>0.604</td>
      <td align="right">2.52<br>2.49</td>
      <td align="right">45.2<br>53.3</td>
      <td align="right">328<br>335</td>
      <td align="right">13.2<br>13</td>
      <td align="right">6.83<br>7.74</td>
      <td align="right">0.61<br>0.666</td>
      <td align="right">3.09<br>3.46</td>
      <td align="right">47.6<br>56.8</td>
      <td align="right">327<br>356</td>
      <td align="right">13.1<br>13.7</td>
    </tr>
    <tr>
      <td>DetUNet<sup>†</sup></td>
      <td align="right">5.54<br>5.14</td>
      <td align="right">–<br>–</td>
      <td align="right">–<br>–</td>
      <td align="right">–<br>–</td>
      <td align="right">45<br>135</td>
      <td align="right"><b>2.06</b><br>6.04</td>
      <td align="right">4.59<br><b>0.000121</b></td>
      <td align="right">–<br>–</td>
      <td align="right">–<br>–</td>
      <td align="right">–<br>–</td>
      <td align="right">101<br>311</td>
      <td align="right">2.76<br>5.65</td>
    </tr>
    <tr>
      <td>DetUNet-orog</td>
      <td align="right">6.91<br>7.91</td>
      <td align="right">0.582<br>0.707</td>
      <td align="right">2.16<br>2.7</td>
      <td align="right">25.3<br>34.3</td>
      <td align="right">99<br>111</td>
      <td align="right">5.54<br>6.46</td>
      <td align="right">7.21<br>7.98</td>
      <td align="right">0.29<br>0.379</td>
      <td align="right">1.15<br>1.51</td>
      <td align="right">13.3<br>19.9</td>
      <td align="right">75.7<br>89.9</td>
      <td align="right"><b>2.5</b><br><b>3.16</b></td>
    </tr>
    <tr>
      <td>DetUNet-v2</td>
      <td align="right">7.47<br>8.7</td>
      <td align="right">0.575<br>0.648</td>
      <td align="right">1.78<br>2.12</td>
      <td align="right"><b>16.3</b><br><b>21.9</b></td>
      <td align="right">199<br>199</td>
      <td align="right">2.93<br><b>3.17</b></td>
      <td align="right">7.2<br>8.02</td>
      <td align="right">0.576<br>0.649</td>
      <td align="right">1.71<br>2.02</td>
      <td align="right">17.4<br>21.9</td>
      <td align="right">159<br>179</td>
      <td align="right">3.12<br>3.25</td>
    </tr>
    <tr>
      <td>DetUNet-v2-orog</td>
      <td align="right">7.23<br>8.39</td>
      <td align="right">0.59<br>0.668</td>
      <td align="right">1.84<br>2.2</td>
      <td align="right">19.8<br>24.4</td>
      <td align="right">113<br>117</td>
      <td align="right">2.92<br>3.18</td>
      <td align="right">7.07<br>7.98</td>
      <td align="right">0.501<br>0.571</td>
      <td align="right">1.55<br>1.83</td>
      <td align="right">18.1<br>22.3</td>
      <td align="right">110<br>129</td>
      <td align="right">2.96<br>3.76</td>
    </tr>
    <tr>
      <td>GNN4CD-orog</td>
      <td align="right">6.99<br>8.07</td>
      <td align="right">0.471<br>0.6</td>
      <td align="right">2.45<br>2.54</td>
      <td align="right">27.7<br>32.6</td>
      <td align="right">77.7<br>82.4</td>
      <td align="right">–<br>–</td>
      <td align="right">6.81<br>7.75</td>
      <td align="right">0.438<br>0.425</td>
      <td align="right">2.47<br>2.56</td>
      <td align="right">28.3<br>33</td>
      <td align="right">86.9<br>89.3</td>
      <td align="right">–<br>–</td>
    </tr>
    <tr>
      <td>ParamUNET</td>
      <td align="right"><b>4.23</b><br><b>4.79</b></td>
      <td align="right">–<br>–</td>
      <td align="right">–<br>–</td>
      <td align="right">–<br>–</td>
      <td align="right">335<br>363</td>
      <td align="right">6.1<br>5.38</td>
      <td align="right"><b>3.97</b><br>4.49</td>
      <td align="right">–<br>–</td>
      <td align="right">–<br>–</td>
      <td align="right">–<br>–</td>
      <td align="right">298<br>318</td>
      <td align="right">8.58<br>7.94</td>
    </tr>
    <tr>
      <td>Prithvi-UNet</td>
      <td align="right">7.05<br>8.07</td>
      <td align="right">0.839<br>1.04</td>
      <td align="right">3.41<br>4.09</td>
      <td align="right">42.2<br>53.4</td>
      <td align="right">325<br>376</td>
      <td align="right">12.6<br>11.9</td>
      <td align="right">6.84<br>7.73</td>
      <td align="right">0.723<br>0.817</td>
      <td align="right">3.03<br>3.5</td>
      <td align="right">38.7<br>47.2</td>
      <td align="right">315<br>344</td>
      <td align="right">10.9<br>12.8</td>
    </tr>
    <tr>
      <td>Prithvi-UNet-orog<sup>†</sup></td>
      <td align="right">6.81<br>8.07</td>
      <td align="right">0.774<br>0.924</td>
      <td align="right">3.64<br>4.56</td>
      <td align="right">43.8<br>58.3</td>
      <td align="right">284<br>415</td>
      <td align="right">13<br>13.2</td>
      <td align="right">6.6<br>7.51</td>
      <td align="right">0.619<br>0.709</td>
      <td align="right">3.2<br>3.72</td>
      <td align="right">39.1<br>48.6</td>
      <td align="right">264<br>291</td>
      <td align="right">10.9<br>11.7</td>
    </tr>
    <tr>
      <td>Rossby-UNet</td>
      <td align="right">6.87<br>7.77</td>
      <td align="right">0.17<br>0.317</td>
      <td align="right">2.84<br>3.61</td>
      <td align="right">32.7<br>44.6</td>
      <td align="right">77.8<br>108</td>
      <td align="right">9.78<br>12.1</td>
      <td align="right">6.53<br>7.36</td>
      <td align="right">0.178<br>0.157</td>
      <td align="right">2.55<br>2.83</td>
      <td align="right">27.3<br>34</td>
      <td align="right">80.6<br>89.7</td>
      <td align="right">7.59<br>7.95</td>
    </tr>
    <tr>
      <td>Rossby-UNet-orog</td>
      <td align="right">6.79<br>7.71</td>
      <td align="right">0.177<br>0.358</td>
      <td align="right">2.79<br>3.6</td>
      <td align="right">32.8<br>45.6</td>
      <td align="right">74.8<br>109</td>
      <td align="right">9.21<br>11.1</td>
      <td align="right">6.42<br>7.27</td>
      <td align="right">0.16<br>0.142</td>
      <td align="right">2.54<br>2.83</td>
      <td align="right">27.7<br>35.1</td>
      <td align="right">79.3<br>89.2</td>
      <td align="right">6.95<br>7.54</td>
    </tr>
    <tr>
      <td>XGBoost_IDL</td>
      <td align="right">6.94<br>9.19</td>
      <td align="right">0.241<br>1.67</td>
      <td align="right">2.87<br>2.64</td>
      <td align="right">39.4<br>44.6</td>
      <td align="right">45.9<br>42.5</td>
      <td align="right">8.99<br>7.56</td>
      <td align="right">6.72<br>7.64</td>
      <td align="right"><b>0.134</b><br><b>0.109</b></td>
      <td align="right">2.97<br>3.38</td>
      <td align="right">39.5<br>48</td>
      <td align="right">49.3<br>46.1</td>
      <td align="right">10.1<br>10.7</td>
    </tr>
  </tbody>
</table>

† Aggregated over a subset of domains only (DetUNet, ESD, Perfect cross-validation: ALPS, NZ; DetUNet, Emulator, Perfect interpolation: SA; Prithvi-UNet-orog, ESD, Perfect extrapolation: ALPS, SA).

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
