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

<!-- MODELS:START -->

<table>
  <thead>
    <tr>
      <th>Model</th>
      <th>Description</th>
      <th>Reference</th>
      <th>Implementation</th>
    </tr>
  </thead>
  <tbody>
    <tr><th colspan="4" align="left">Deterministic</th></tr>
    <tr>
      <td>ANN</td>
      <td>Multi-layer perceptron (2 layers)</td>
      <td><a href="https://doi.org/10.1002/joc.7303">Olmo and Bettolli, 2021</a></td>
      <td><a href="https://gitlab.earth.bsc.es/molmo/ann_cordex_ml">GitLab</a></td>
    </tr>
    <tr>
      <td>CNRM-UNeT</td>
      <td>Asymmetric U-Net + 1D bottleneck</td>
      <td><a href="https://link.springer.com/article/10.1007/s00382-022-06343-9">Doury et al., 2022</a>; <a href="https://link.springer.com/article/10.1007/s00382-024-07350-8">Doury et al., 2024</a></td>
      <td><a href="https://github.com/antoinedoury/RCM-Emulator">GitHub</a></td>
    </tr>
    <tr>
      <td>DeepESD-IFCAv1</td>
      <td>Deep CNN (3 conv + 1 dense)</td>
      <td><a href="https://journals.ametsoc.org/view/journals/aies/4/4/AIES-D-24-0121.1.xml">González-Abad et al., 2025</a></td>
      <td><a href="https://github.com/jgonzalezab/deepESD_CORDEX-ML-Bench">GitHub</a></td>
    </tr>
    <tr>
      <td>DeepESD_IDL</td>
      <td>Deep CNN (3 conv + 1 dense)</td>
      <td><a href="https://doi.org/10.5194/gmd-17-229-2024">Soares et al., 2024</a></td>
      <td><a href="https://github.com/rtomeidl/CordexML_DeepESD">GitHub</a></td>
    </tr>
    <tr>
      <td>DeepSensor</td>
      <td>Neural Process (parameterized GP)</td>
      <td><a href="https://alan-turing-institute.github.io/deepsensor/">DeepSensor's Documentation</a></td>
      <td><a href="https://github.com/alan-turing-institute/deepsensor">GitHub</a></td>
    </tr>
    <tr>
      <td>DetUNet</td>
      <td>U-Net + self-attention + FiLM (~3M params)</td>
      <td><a href="https://agupubs.onlinelibrary.wiley.com/doi/full/10.1029/2024MS004668">Rampal et al., 2025</a></td>
      <td><a href="https://github.com/nram812/Generative-CORDEX-ML-Bench/tree/main/models">GitHub</a></td>
    </tr>
    <tr>
      <td>DetUNet-v2</td>
      <td>U-Net + self-attention + FiLM (~3M params)</td>
      <td><a href="https://agupubs.onlinelibrary.wiley.com/doi/full/10.1029/2024MS004668">Rampal et al., 2025</a></td>
      <td><a href="https://github.com/nram812/Generative-CORDEX-ML-Bench/tree/main/models">GitHub</a></td>
    </tr>
    <tr>
      <td>GNN4CD</td>
      <td>Graph Neural Network (GATv2Conv, 10 layers)</td>
      <td><a href="https://doi.org/10.1017/eds.2025.10022">Blasone et al., 2025</a></td>
      <td><a href="https://github.com/valebl/GNN4CD">GitHub</a></td>
    </tr>
    <tr>
      <td>ParamUNET</td>
      <td>U-Net outputting distribution parameters</td>
      <td>In preparation</td>
      <td>In preparation</td>
    </tr>
    <tr>
      <td>Prithvi-UNet</td>
      <td>Foundation model (Prithvi-WxC) + UNet decoder</td>
      <td><a href="https://arxiv.org/abs/2409.13598">Schmude et al., 2024</a></td>
      <td><a href="https://github.com/midatm1234/granite-wxc/tree/CORDEX_ML">GitHub</a></td>
    </tr>
    <tr>
      <td>Rossby-UNet</td>
      <td>U-Net + CBAM (5 enc/dec layers)</td>
      <td>In preparation</td>
      <td>In preparation</td>
    </tr>
    <tr>
      <td>XGBoost_IDL</td>
      <td>Gradient boosted decision trees</td>
      <td><a href="https://doi.org/10.1016/j.uclim.2024.101982">Bushenkova et al., 2021</a></td>
      <td><a href="https://github.com/rtomeidl/CordexML_XGBoost">GitHub</a></td>
    </tr>
    <tr><th colspan="4" align="left">Generative</th></tr>
    <tr>
      <td>CorrDiff-TW1_NTNU-CWA</td>
      <td>Physics-inspired UNet regression + EDM diffusion</td>
      <td><a href="https://www.nature.com/articles/s43247-025-02042-5">Marani et al., 2025</a></td>
      <td><a href="https://github.com/NVIDIA/physicsnemo/tree/main/examples/weather/corrdiff">GitHub</a></td>
    </tr>
    <tr>
      <td>DeepESDcrps_IFCAv2</td>
      <td>Deep CNN (3 conv + 1 dense)</td>
      <td>In preparation</td>
      <td>In preparation</td>
    </tr>
    <tr>
      <td>EnScale</td>
      <td>Multi-step sparse localised downscaling</td>
      <td><a href="https://arxiv.org/abs/2509.26258v2">Schillinger et al., 2025</a></td>
      <td><a href="https://github.com/m-schillinger/cordexbench">GitHub</a></td>
    </tr>
    <tr>
      <td>EnScale-linex</td>
      <td>EnScale + linear residual model</td>
      <td><a href="https://arxiv.org/abs/2509.26258v2">Schillinger et al., 2025</a></td>
      <td><a href="https://github.com/m-schillinger/cordexbench">GitHub</a></td>
    </tr>
    <tr>
      <td>FlowMatching-v1</td>
      <td>Flow matching + ADM U-Net</td>
      <td><a href="https://arxiv.org/abs/2606.00281">Wetherell 2026</a></td>
      <td><a href="https://github.com/mo-tomaswetherell/mo-flow-cordexbench">GitHub</a></td>
    </tr>
    <tr>
      <td>ParamDiffusion</td>
      <td>Diffusion on ParamUNET background</td>
      <td>In preparation</td>
      <td>In preparation</td>
    </tr>
    <tr>
      <td>RCMFlow</td>
      <td></td>
      <td><a href="https://arxiv.org/abs/2512.13987">Link</a></td>
      <td><a href="https://github.com/nram812/Generative-CORDEX-ML-Bench/tree/non_linear_activation_dev_branch/models">GitHub</a></td>
    </tr>
    <tr>
      <td>RCMGEM-mv</td>
      <td>NCSN++ diffusion (sub-VP SDE)</td>
      <td><a href="https://agupubs.onlinelibrary.wiley.com/doi/10.1029/2025MS005140">Addison et al., 2026</a></td>
      <td><a href="https://zenodo.org/records/18481925">Zenodo</a></td>
    </tr>
    <tr>
      <td>ResGAN</td>
      <td>Residual WGAN (U-Net mean + GAN residual)</td>
      <td><a href="https://agupubs.onlinelibrary.wiley.com/doi/full/10.1029/2024MS004668">Rampal et al., 2025</a></td>
      <td><a href="https://github.com/nram812/Generative-CORDEX-ML-Bench/tree/main/models">GitHub</a></td>
    </tr>
    <tr>
      <td>SpaGAN</td>
      <td>UNet2D GAN + convolutional discriminator</td>
      <td><a href="https://www.nature.com/articles/s41612-025-01103-y">Glawion et al., 2025</a></td>
      <td><a href="https://github.com/jpolz/ml-benchmark-spategan">GitHub</a></td>
    </tr>
    <tr>
      <td>UiBCorrDiff</td>
      <td>Corrective diffusion (regression U-Net + EDM diffusion)</td>
      <td><a href="https://www.nature.com/articles/s43247-025-02042-5">Marani et al., 2025</a></td>
      <td><a href="https://github.com/joshdorrington/UiBcorrdiff">GitHub</a></td>
    </tr>
    <tr>
      <td>ViT-IFCAv1</td>
      <td>Vision Transformer (ViT)</td>
      <td>In preparation</td>
      <td><a href="https://github.com/jgonzalezab/ViT_CORDEX-ML-Bench">GitHub</a></td>
    </tr>
  </tbody>
</table>

<!-- MODELS:END -->


## Scoreboard

Performance of the submitted models in the four perfect-predictor tests, one table per variable.

<!-- SCOREBOARD:START -->

Metrics are computed per domain by `ml-eval benchmark` and aggregated across
domains (quadratic mean for RMSE and LHD, arithmetic mean otherwise). Biases are
spatial means of the absolute bias, in the units of the variable. ↓ lower is
better, ↑ higher is better. Each cell shows the two tests of a training
experiment, in the order given in the column header; the best value of each test
is in bold, and – marks results not available. Models using orography as a predictor are in italics.

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
    <tr><th colspan="13" align="left">Deterministic</th></tr>
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
      <td><i>ANN-orog</i></td>
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
      <td>CNRM-UNeT</td>
      <td align="right">1.36<br>1.64</td>
      <td align="right">0.207<br>0.743</td>
      <td align="right">0.729<br>1.75</td>
      <td align="right">15.7<br>17.4</td>
      <td align="right">0.98<br>0.935</td>
      <td align="right">0.179<br>0.167</td>
      <td align="right">1.26<br>1.31</td>
      <td align="right">0.172<br>0.189</td>
      <td align="right">0.477<br>0.461</td>
      <td align="right">11.1<br>12</td>
      <td align="right">0.978<br>0.98</td>
      <td align="right">0.144<br>0.0957</td>
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
      <td><i>DeepESD-IFCAv1-orog</i></td>
      <td align="right">1.39<br>1.5</td>
      <td align="right">0.156<br>0.304</td>
      <td align="right">0.601<br>0.693</td>
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
      <td><i>DeepSensor-orog</i></td>
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
      <td align="right">0.239<br>0.888</td>
      <td align="right">0.793<br>1.97</td>
      <td align="right">5.49<br>4.43</td>
      <td align="right">0.978<br>0.926</td>
      <td align="right">0.188<br>0.19</td>
      <td align="right">1.56<br>1.33</td>
      <td align="right">0.833<br>0.437</td>
      <td align="right">0.881<br>0.54</td>
      <td align="right">7.03<br>5.52</td>
      <td align="right">0.92<br>0.953</td>
      <td align="right">0.159<br>0.136</td>
    </tr>
    <tr>
      <td><i>DetUNet-orog</i></td>
      <td align="right"><b>1.3</b><br>1.75</td>
      <td align="right">0.259<br>0.935</td>
      <td align="right">1.28<br>2.46</td>
      <td align="right">4.97<br>4.04</td>
      <td align="right">0.977<br>0.923</td>
      <td align="right">0.196<br>0.199</td>
      <td align="right">1.61<br>1.32</td>
      <td align="right">0.906<br>0.487</td>
      <td align="right">0.874<br>0.48</td>
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
      <td><i>DetUNet-v2-orog</i></td>
      <td align="right">1.37<br>1.61</td>
      <td align="right">0.136<br>0.399</td>
      <td align="right">0.599<br>1.66</td>
      <td align="right">4.89<br>3.7</td>
      <td align="right">0.982<br>0.958</td>
      <td align="right">0.151<br>0.125</td>
      <td align="right">1.37<br>1.33</td>
      <td align="right">0.333<br>0.244</td>
      <td align="right">0.499<br>0.501</td>
      <td align="right">7.25<br>5.48</td>
      <td align="right">0.955<br>0.968</td>
      <td align="right">0.123<br>0.0976</td>
    </tr>
    <tr>
      <td><i>GNN4CD-orog</i></td>
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
      <td align="right">0.0887<br>0.0815</td>
    </tr>
    <tr>
      <td>ParamUNET</td>
      <td align="right">1.32<br>1.52</td>
      <td align="right">0.265<br>0.429</td>
      <td align="right">0.709<br>1.26</td>
      <td align="right">14.6<br>13.4</td>
      <td align="right">0.986<br>0.971</td>
      <td align="right">0.119<br>0.1</td>
      <td align="right"><b>1.23</b><br><b>1.28</b></td>
      <td align="right">0.21<br>0.215</td>
      <td align="right">0.643<br>0.762</td>
      <td align="right">17.4<br>16.1</td>
      <td align="right">0.982<br>0.976</td>
      <td align="right">0.118<br>0.0849</td>
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
      <td><i>Prithvi-UNet-orog</i><sup>†</sup></td>
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
      <td align="right">0.122<br>0.1</td>
      <td align="right">0.541<br>0.498</td>
      <td align="right">4.27<br>3.14</td>
      <td align="right">0.986<br>0.988</td>
      <td align="right">0.139<br><b>0.0534</b></td>
    </tr>
    <tr>
      <td><i>Rossby-UNet-orog</i></td>
      <td align="right">1.4<br>1.8</td>
      <td align="right">0.137<br>0.683</td>
      <td align="right">0.765<br>2.04</td>
      <td align="right">2.27<br>1.21</td>
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
      <td align="right">0.111<br>0.353</td>
      <td align="right">1.04<br>2.67</td>
      <td align="right">12.2<br>14.9</td>
      <td align="right">0.979<br>0.953</td>
      <td align="right">0.151<br>0.133</td>
      <td align="right">1.27<br>1.3</td>
      <td align="right">0.0842<br>0.111</td>
      <td align="right">0.55<br>0.56</td>
      <td align="right">12.3<br>12.6</td>
      <td align="right">0.979<br>0.979</td>
      <td align="right">0.138<br>0.0987</td>
    </tr>
    <tr><th colspan="13" align="left">Generative</th></tr>
    <tr>
      <td>CorrDiff-TW1_NTNU-CWA</td>
      <td align="right">2.51<br>2.75</td>
      <td align="right">2.04<br>2.35</td>
      <td align="right">3.04<br>3.48</td>
      <td align="right">0.599<br>0.648</td>
      <td align="right">0.85<br>0.83</td>
      <td align="right">0.146<br>0.132</td>
      <td align="right">1.28<br>1.32</td>
      <td align="right">0.342<br>0.355</td>
      <td align="right">0.466<br>0.521</td>
      <td align="right">0.66<br>0.632</td>
      <td align="right">0.983<br>0.981</td>
      <td align="right">0.0866<br>0.0692</td>
    </tr>
    <tr>
      <td><i>CorrDiff-TW1_NTNU-CWA-orog</i></td>
      <td align="right">2.56<br>2.79</td>
      <td align="right">2.08<br>2.37</td>
      <td align="right">3<br>3.41</td>
      <td align="right">0.578<br>0.649</td>
      <td align="right">0.849<br>0.828</td>
      <td align="right">0.142<br>0.132</td>
      <td align="right">1.31<br>1.35</td>
      <td align="right">0.352<br>0.363</td>
      <td align="right">0.473<br>0.517</td>
      <td align="right">0.579<br>0.564</td>
      <td align="right">0.982<br>0.979</td>
      <td align="right"><b>0.0853</b><br>0.0675</td>
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
      <td><i>DeepESDcrps_IFCAv2-orog</i></td>
      <td align="right">2.19<br>2.32</td>
      <td align="right">0.216<br>0.434</td>
      <td align="right">0.978<br>1.42</td>
      <td align="right">2.28<br>1.72</td>
      <td align="right">0.976<br>0.963</td>
      <td align="right">0.141<br>0.096</td>
      <td align="right">2.12<br>2.12</td>
      <td align="right">0.281<br>0.229</td>
      <td align="right">1.26<br>1.2</td>
      <td align="right">2.65<br>2.33</td>
      <td align="right">0.974<br>0.975</td>
      <td align="right">0.13<br>0.0899</td>
    </tr>
    <tr>
      <td>EnScale</td>
      <td align="right">1.77<br>2</td>
      <td align="right">0.123<br>0.585</td>
      <td align="right">0.676<br>0.865</td>
      <td align="right">1.46<br>2.15</td>
      <td align="right">0.985<br>0.951</td>
      <td align="right">0.152<br>0.132</td>
      <td align="right">1.73<br>1.77</td>
      <td align="right">0.134<br>0.132</td>
      <td align="right">0.756<br>0.831</td>
      <td align="right">1.44<br>1.6</td>
      <td align="right">0.985<br>0.985</td>
      <td align="right">0.13<br>0.0916</td>
    </tr>
    <tr>
      <td>EnScale-linex</td>
      <td align="right">1.63<br>1.74</td>
      <td align="right">0.16<br>0.332</td>
      <td align="right">0.62<br>0.757</td>
      <td align="right">1.72<br>1.66</td>
      <td align="right">0.982<br>0.974</td>
      <td align="right">0.128<br>0.109</td>
      <td align="right">1.61<br>1.65</td>
      <td align="right">0.104<br>0.113</td>
      <td align="right">0.739<br>0.776</td>
      <td align="right">2.45<br>2.19</td>
      <td align="right">0.984<br>0.987</td>
      <td align="right">0.121<br>0.0944</td>
    </tr>
    <tr>
      <td><i>EnScale-orog</i></td>
      <td align="right">1.78<br>2</td>
      <td align="right">0.122<br>0.582</td>
      <td align="right">0.627<br>0.801</td>
      <td align="right">2.15<br>2.83</td>
      <td align="right">0.985<br>0.951</td>
      <td align="right">0.152<br>0.133</td>
      <td align="right">1.73<br>1.78</td>
      <td align="right">0.136<br>0.134</td>
      <td align="right">0.767<br>0.794</td>
      <td align="right">2.22<br>2.36</td>
      <td align="right">0.985<br>0.985</td>
      <td align="right">0.131<br>0.0916</td>
    </tr>
    <tr>
      <td>FlowMatching-v1</td>
      <td align="right">1.53<br>1.69</td>
      <td align="right">0.282<br>0.487</td>
      <td align="right">0.548<br>1.19</td>
      <td align="right">0.528<br>0.513</td>
      <td align="right">0.975<br>0.96</td>
      <td align="right">0.125<br>0.111</td>
      <td align="right">1.5<br>1.55</td>
      <td align="right">0.252<br>0.289</td>
      <td align="right">0.544<br>0.555</td>
      <td align="right">0.234<br>0.271</td>
      <td align="right">0.976<br>0.978</td>
      <td align="right">0.0991<br>0.0779</td>
    </tr>
    <tr>
      <td><i>FlowMatching-v1-orog</i></td>
      <td align="right">1.59<br>1.73</td>
      <td align="right">0.35<br>0.427</td>
      <td align="right">0.68<br>0.955</td>
      <td align="right">0.34<br>0.353</td>
      <td align="right">0.964<br>0.954</td>
      <td align="right">0.136<br>0.109</td>
      <td align="right">1.54<br>1.56</td>
      <td align="right">0.28<br>0.266</td>
      <td align="right">0.52<br>0.543</td>
      <td align="right">0.347<br>0.326</td>
      <td align="right">0.981<br>0.984</td>
      <td align="right">0.114<br>0.0826</td>
    </tr>
    <tr>
      <td><i>ParamDiffusion-orog</i></td>
      <td align="right">1.59<br>1.82</td>
      <td align="right">0.26<br>0.519</td>
      <td align="right">0.841<br>1.49</td>
      <td align="right">1.89<br>4.17</td>
      <td align="right">0.972<br>0.96</td>
      <td align="right">0.12<br>0.107</td>
      <td align="right">1.4<br>1.45</td>
      <td align="right">0.0793<br><b>0.0806</b></td>
      <td align="right"><b>0.298</b><br><b>0.344</b></td>
      <td align="right">0.752<br>0.663</td>
      <td align="right"><b>0.99</b><br>0.986</td>
      <td align="right">0.109<br>0.0806</td>
    </tr>
    <tr>
      <td><i>RCMFlow-orog</i></td>
      <td align="right">1.46<br>1.85</td>
      <td align="right">0.144<br>0.806</td>
      <td align="right">0.511<br>1.5</td>
      <td align="right">0.347<br>0.57</td>
      <td align="right">0.981<br>0.929</td>
      <td align="right">0.18<br>0.2</td>
      <td align="right">1.87<br>1.63</td>
      <td align="right">1.02<br>0.647</td>
      <td align="right">1.58<br>1.18</td>
      <td align="right">0.576<br>0.552</td>
      <td align="right">0.911<br>0.943</td>
      <td align="right">0.13<br>0.129</td>
    </tr>
    <tr>
      <td><i>RCMGEM-mv-orog</i></td>
      <td align="right">1.3<br><b>1.43</b></td>
      <td align="right"><b>0.103</b><br><b>0.27</b></td>
      <td align="right"><b>0.282</b><br><b>0.423</b></td>
      <td align="right"><b>0.049</b><br><b>0.136</b></td>
      <td align="right"><b>0.99</b><br>0.973</td>
      <td align="right">0.122<br>0.0969</td>
      <td align="right">1.37<br>1.38</td>
      <td align="right"><b>0.0751</b><br>0.0946</td>
      <td align="right">0.595<br>0.581</td>
      <td align="right"><b>0.0732</b><br><b>0.0742</b></td>
      <td align="right">0.989<br><b>0.99</b></td>
      <td align="right">0.0996<br>0.0791</td>
    </tr>
    <tr>
      <td>ResGAN</td>
      <td align="right">1.47<br>1.88</td>
      <td align="right">0.227<br>0.885</td>
      <td align="right">0.538<br>1.55</td>
      <td align="right">2.44<br>1.84</td>
      <td align="right">0.978<br>0.926</td>
      <td align="right">0.188<br>0.188</td>
      <td align="right">1.74<br>1.54</td>
      <td align="right">0.846<br>0.45</td>
      <td align="right">1.19<br>0.755</td>
      <td align="right">0.668<br>0.316</td>
      <td align="right">0.921<br>0.954</td>
      <td align="right">0.157<br>0.133</td>
    </tr>
    <tr>
      <td><i>ResGAN-orog</i></td>
      <td align="right">1.47<br>1.89</td>
      <td align="right">0.25<br>0.927</td>
      <td align="right">0.948<br>2.09</td>
      <td align="right">0.846<br>0.564</td>
      <td align="right">0.978<br>0.924</td>
      <td align="right">0.194<br>0.193</td>
      <td align="right">1.77<br>1.53</td>
      <td align="right">0.891<br>0.466</td>
      <td align="right">1.15<br>0.702</td>
      <td align="right">0.742<br>0.592</td>
      <td align="right">0.914<br>0.952</td>
      <td align="right">0.146<br>0.135</td>
    </tr>
    <tr>
      <td>SpaGAN</td>
      <td align="right">4.11<br>4.16</td>
      <td align="right">1.77<br>1.95</td>
      <td align="right">2.03<br>3.06</td>
      <td align="right">3.46<br>4.2</td>
      <td align="right">0.97<br>0.952</td>
      <td align="right">0.171<br>0.162</td>
      <td align="right">4.06<br>3.96</td>
      <td align="right">1.81<br>1.73</td>
      <td align="right">1.9<br>2.01</td>
      <td align="right">2.98<br>3.46</td>
      <td align="right">0.973<br>0.971</td>
      <td align="right">0.156<br>0.112</td>
    </tr>
    <tr>
      <td><i>SpaGAN-orog</i></td>
      <td align="right">4.13<br>4.17</td>
      <td align="right">1.76<br>2.01</td>
      <td align="right">1.94<br>2.91</td>
      <td align="right">3.39<br>4.13</td>
      <td align="right">0.973<br>0.949</td>
      <td align="right">0.173<br>0.167</td>
      <td align="right">4<br>3.91</td>
      <td align="right">1.69<br>1.6</td>
      <td align="right">1.68<br>1.95</td>
      <td align="right">3.23<br>3.6</td>
      <td align="right">0.973<br>0.975</td>
      <td align="right">0.146<br>0.089</td>
    </tr>
    <tr>
      <td><i>UiBCorrDiff-orog</i></td>
      <td align="right">1.36<br>1.55</td>
      <td align="right">0.489<br>0.64</td>
      <td align="right">0.616<br>1.24</td>
      <td align="right">1.95<br>2.64</td>
      <td align="right">0.976<br>0.959</td>
      <td align="right">0.118<br>0.101</td>
      <td align="right">1.48<br>1.52</td>
      <td align="right">0.688<br>0.699</td>
      <td align="right">0.856<br>0.89</td>
      <td align="right">1.04<br>1.52</td>
      <td align="right">0.969<br>0.966</td>
      <td align="right">0.111<br>0.0822</td>
    </tr>
    <tr>
      <td>ViT-IFCAv1<sup>†</sup></td>
      <td align="right">1.47<br>1.74</td>
      <td align="right">0.132<br>0.326</td>
      <td align="right">0.494<br>0.997</td>
      <td align="right">8.26<br>8.79</td>
      <td align="right">0.988<br>0.972</td>
      <td align="right">0.129<br>0.131</td>
      <td align="right">1.42<br>1.5</td>
      <td align="right">0.222<br>0.276</td>
      <td align="right">0.634<br>0.818</td>
      <td align="right">6.94<br>6.69</td>
      <td align="right">0.982<br>0.979</td>
      <td align="right">0.112<br>0.0861</td>
    </tr>
    <tr>
      <td><i>ViT-IFCAv1-orog</i><sup>†</sup></td>
      <td align="right">1.49<br>1.76</td>
      <td align="right">0.145<br>0.37</td>
      <td align="right">0.508<br>0.897</td>
      <td align="right">8.41<br>9.18</td>
      <td align="right">0.986<br>0.968</td>
      <td align="right">0.127<br>0.143</td>
      <td align="right">1.43<br>1.51</td>
      <td align="right">0.171<br>0.193</td>
      <td align="right">0.64<br>0.732</td>
      <td align="right">7.83<br>7.38</td>
      <td align="right">0.985<br>0.984</td>
      <td align="right">0.117<br>0.0901</td>
    </tr>
  </tbody>
</table>

† Aggregated over a subset of domains only (Prithvi-UNet-orog, ESD, Perfect extrapolation: ALPS, SA; ViT-IFCAv1, ESD, Perfect cross-validation: SA, NZ; ViT-IFCAv1, ESD, Perfect extrapolation: SA, NZ; ViT-IFCAv1, Emulator, Perfect cross-validation: SA, NZ; ViT-IFCAv1, Emulator, Perfect interpolation: SA, NZ; ViT-IFCAv1-orog, ESD, Perfect cross-validation: SA, NZ; ViT-IFCAv1-orog, ESD, Perfect extrapolation: SA, NZ; ViT-IFCAv1-orog, Emulator, Perfect cross-validation: SA, NZ; ViT-IFCAv1-orog, Emulator, Perfect interpolation: SA, NZ).

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
    <tr><th colspan="13" align="left">Deterministic</th></tr>
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
      <td><i>ANN-orog</i></td>
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
      <td>CNRM-UNeT</td>
      <td align="right">6.76<br>7.6</td>
      <td align="right">0.506<br>0.596</td>
      <td align="right">1.5<br>1.99</td>
      <td align="right">28.7<br>39.1</td>
      <td align="right">145<br>169</td>
      <td align="right">8.02<br>9.9</td>
      <td align="right">6.66<br>7.47</td>
      <td align="right">0.485<br>0.548</td>
      <td align="right">1<br>1.32</td>
      <td align="right">24.3<br>33.4</td>
      <td align="right">164<br>189</td>
      <td align="right">7.82<br>8.93</td>
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
      <td><i>DeepESD-IFCAv1-orog</i></td>
      <td align="right">6.37<br>7.23</td>
      <td align="right">0.311<br>0.352</td>
      <td align="right">1.62<br>2.01</td>
      <td align="right">33<br>41.8</td>
      <td align="right">83.2<br>99</td>
      <td align="right">9.41<br>10.2</td>
      <td align="right">6.16<br><b>6.98</b></td>
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
      <td align="right">0.496<br>0.633</td>
      <td align="right">19.2<br>20.2</td>
      <td align="right">211<br>199</td>
      <td align="right">6.63<br>6.89</td>
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
      <td><i>DeepSensor-orog</i></td>
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
      <td>DetUNet</td>
      <td align="right">6.99<br>8.03</td>
      <td align="right">0.603<br>0.728</td>
      <td align="right">2.08<br>2.67</td>
      <td align="right">24.9<br>33.9</td>
      <td align="right">123<br>135</td>
      <td align="right">5.13<br>6.04</td>
      <td align="right">7.1<br>7.88</td>
      <td align="right">0.399<br>0.505</td>
      <td align="right">1.38<br>1.74</td>
      <td align="right">14.8<br>21.1</td>
      <td align="right">101<br>117</td>
      <td align="right">2.76<br>3.68</td>
    </tr>
    <tr>
      <td><i>DetUNet-orog</i></td>
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
      <td align="right">2.5<br>3.16</td>
    </tr>
    <tr>
      <td>DetUNet-v2</td>
      <td align="right">7.47<br>8.7</td>
      <td align="right">0.575<br>0.648</td>
      <td align="right">1.78<br>2.12</td>
      <td align="right">16.3<br>21.9</td>
      <td align="right">199<br>199</td>
      <td align="right">2.93<br>3.17</td>
      <td align="right">7.2<br>8.02</td>
      <td align="right">0.576<br>0.649</td>
      <td align="right">1.71<br>2.02</td>
      <td align="right">17.4<br>21.9</td>
      <td align="right">159<br>179</td>
      <td align="right">3.12<br>3.25</td>
    </tr>
    <tr>
      <td><i>DetUNet-v2-orog</i></td>
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
      <td><i>GNN4CD-orog</i></td>
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
      <td align="right">6.56<br>7.48</td>
      <td align="right">0.453<br>0.508</td>
      <td align="right">1.36<br>1.55</td>
      <td align="right">26.4<br>33.5</td>
      <td align="right">335<br>363</td>
      <td align="right">6.1<br>5.38</td>
      <td align="right">6.22<br>7.07</td>
      <td align="right">0.378<br>0.397</td>
      <td align="right">1.65<br>1.87</td>
      <td align="right">29.9<br>36</td>
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
      <td><i>Prithvi-UNet-orog</i><sup>†</sup></td>
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
      <td><i>Rossby-UNet-orog</i></td>
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
      <td align="right">0.134<br><b>0.109</b></td>
      <td align="right">2.97<br>3.38</td>
      <td align="right">39.5<br>48</td>
      <td align="right">49.3<br>46.1</td>
      <td align="right">10.1<br>10.7</td>
    </tr>
    <tr><th colspan="13" align="left">Generative</th></tr>
    <tr>
      <td>CorrDiff-TW1_NTNU-CWA</td>
      <td align="right"><b>6.3</b><br><b>7.17</b></td>
      <td align="right">0.849<br>0.935</td>
      <td align="right">2.45<br>2.93</td>
      <td align="right">34.5<br>42.7</td>
      <td align="right">29.4<br>36.2</td>
      <td align="right">9.36<br>10.5</td>
      <td align="right"><b>6.13</b><br>6.99</td>
      <td align="right">0.697<br>0.779</td>
      <td align="right">1.82<br>2.17</td>
      <td align="right">28.5<br>34.9</td>
      <td align="right">16.3<br>23.3</td>
      <td align="right">7.66<br>7.79</td>
    </tr>
    <tr>
      <td><i>CorrDiff-TW1_NTNU-CWA-orog</i></td>
      <td align="right">6.31<br>7.17</td>
      <td align="right">0.805<br>0.873</td>
      <td align="right">2.48<br>2.96</td>
      <td align="right">34.4<br>42.4</td>
      <td align="right">30.2<br>36.7</td>
      <td align="right">9.26<br>9.85</td>
      <td align="right">6.16<br>7.02</td>
      <td align="right">0.698<br>0.785</td>
      <td align="right">1.81<br>2.16</td>
      <td align="right">28.1<br>34.7</td>
      <td align="right">16.8<br>24.4</td>
      <td align="right">7.15<br>7.13</td>
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
      <td align="right">12.4<br>18.1</td>
      <td align="right">41.1<br>46.2</td>
      <td align="right">4.9<br>5.3</td>
    </tr>
    <tr>
      <td><i>DeepESDcrps_IFCAv2-orog</i></td>
      <td align="right">8<br>8.8</td>
      <td align="right">0.334<br>0.374</td>
      <td align="right">0.856<br><b>0.832</b></td>
      <td align="right">30.8<br>40.7</td>
      <td align="right">30.6<br>34.7</td>
      <td align="right">9.35<br>9.83</td>
      <td align="right">8.05<br>8.83</td>
      <td align="right">0.579<br>0.587</td>
      <td align="right">1.18<br>1.02</td>
      <td align="right">27.7<br>36.4</td>
      <td align="right">28<br>28.8</td>
      <td align="right">8.76<br>9.38</td>
    </tr>
    <tr>
      <td>EnScale</td>
      <td align="right">8.74<br>9.44</td>
      <td align="right">0.226<br>0.342</td>
      <td align="right">0.757<br>1.16</td>
      <td align="right">16.1<br>24.7</td>
      <td align="right">12.5<br>8.88</td>
      <td align="right">1.63<br>2.98</td>
      <td align="right">9.4<br>10</td>
      <td align="right">0.245<br>0.224</td>
      <td align="right">0.693<br>0.797</td>
      <td align="right">15.3<br>17.4</td>
      <td align="right">24.3<br>16</td>
      <td align="right">3.37<br>2.71</td>
    </tr>
    <tr>
      <td>EnScale-linex</td>
      <td align="right">8.44<br>9.27</td>
      <td align="right">0.193<br>0.287</td>
      <td align="right">2.41<br>2.84</td>
      <td align="right">19.1<br>24.3</td>
      <td align="right">13.8<br>9.59</td>
      <td align="right">2.96<br>2.75</td>
      <td align="right">9.22<br>9.89</td>
      <td align="right">0.206<br>0.226</td>
      <td align="right">2.05<br>2.54</td>
      <td align="right">20.7<br>24.2</td>
      <td align="right">36.3<br>26.2</td>
      <td align="right">4.88<br>4.03</td>
    </tr>
    <tr>
      <td><i>EnScale-orog</i></td>
      <td align="right">7.97<br>8.75</td>
      <td align="right">0.239<br>0.383</td>
      <td align="right">0.859<br>1.39</td>
      <td align="right">22.7<br>32.8</td>
      <td align="right">19.5<br>21</td>
      <td align="right">5.83<br>7.33</td>
      <td align="right">8.19<br>8.89</td>
      <td align="right">0.216<br>0.225</td>
      <td align="right">0.652<br>0.897</td>
      <td align="right">16.8<br>25</td>
      <td align="right">19.4<br>18.8</td>
      <td align="right">4.23<br>5.54</td>
    </tr>
    <tr>
      <td>FlowMatching-v1</td>
      <td align="right">8.38<br>9.33</td>
      <td align="right">0.462<br>0.543</td>
      <td align="right">1.22<br>1.71</td>
      <td align="right">13.9<br>18.8</td>
      <td align="right">1.38<br>2.77</td>
      <td align="right">3.16<br>3.48</td>
      <td align="right">8.95<br>10.1</td>
      <td align="right">0.523<br>0.534</td>
      <td align="right">0.992<br>1.1</td>
      <td align="right">14.1<br>16.4</td>
      <td align="right">1.51<br>1.31</td>
      <td align="right">2.43<br>2.58</td>
    </tr>
    <tr>
      <td><i>FlowMatching-v1-orog</i></td>
      <td align="right">8.37<br>9.44</td>
      <td align="right">0.437<br>0.547</td>
      <td align="right">0.811<br>1.03</td>
      <td align="right">11<br><b>15.5</b></td>
      <td align="right"><b>0.795</b><br><b>2.11</b></td>
      <td align="right">2.96<br>3.63</td>
      <td align="right">8.06<br>9.18</td>
      <td align="right">0.418<br>0.466</td>
      <td align="right">0.926<br>1.11</td>
      <td align="right">13.9<br>16.9</td>
      <td align="right">3.82<br>5.02</td>
      <td align="right">3.11<br>2.96</td>
    </tr>
    <tr>
      <td><i>ParamDiffusion-orog</i></td>
      <td align="right">8.68<br>9.67</td>
      <td align="right">0.469<br>0.518</td>
      <td align="right">0.96<br>1.11</td>
      <td align="right">14.9<br>18.4</td>
      <td align="right">4.51<br>6.99</td>
      <td align="right">4.47<br>4.44</td>
      <td align="right">8.24<br>9.27</td>
      <td align="right"><b>0.122</b><br>0.128</td>
      <td align="right">0.345<br>0.408</td>
      <td align="right">7.56<br>9.81</td>
      <td align="right">0.801<br>1.79</td>
      <td align="right"><b>0.789</b><br>1.1</td>
    </tr>
    <tr>
      <td><i>RCMFlow-orog</i></td>
      <td align="right">7.81<br>8.66</td>
      <td align="right">0.322<br>0.503</td>
      <td align="right">0.878<br>1.46</td>
      <td align="right"><b>10.9</b><br>17.7</td>
      <td align="right">2.4<br>5.04</td>
      <td align="right"><b>1.58</b><br><b>2.13</b></td>
      <td align="right">8.3<br>9.23</td>
      <td align="right">0.204<br>0.155</td>
      <td align="right">0.393<br>0.465</td>
      <td align="right">9.43<br>10.1</td>
      <td align="right">4.1<br>2.68</td>
      <td align="right">2.05<br>1.86</td>
    </tr>
    <tr>
      <td><i>RCMGEM-mv-orog</i></td>
      <td align="right">7.22<br>8.18</td>
      <td align="right">0.187<br>0.256</td>
      <td align="right">0.79<br>1.19</td>
      <td align="right">12.7<br>18.1</td>
      <td align="right">1.46<br>2.31</td>
      <td align="right">3.9<br>4.73</td>
      <td align="right">7.56<br>8.61</td>
      <td align="right">0.137<br>0.134</td>
      <td align="right"><b>0.316</b><br><b>0.386</b></td>
      <td align="right"><b>6.65</b><br><b>8.13</b></td>
      <td align="right"><b>0.0667</b><br><b>0.188</b></td>
      <td align="right">1.15<br><b>0.961</b></td>
    </tr>
    <tr>
      <td>ResGAN</td>
      <td align="right">7.76<br>8.82</td>
      <td align="right">0.353<br>0.497</td>
      <td align="right">1.26<br>1.81</td>
      <td align="right">14.1<br>21.6</td>
      <td align="right">7.44<br>6.28</td>
      <td align="right">2.13<br>3.12</td>
      <td align="right">8.26<br>9.07</td>
      <td align="right">0.249<br>0.225</td>
      <td align="right">0.509<br>0.653</td>
      <td align="right">9.54<br>10.7</td>
      <td align="right">6.49<br>4.36</td>
      <td align="right">2<br>1.35</td>
    </tr>
    <tr>
      <td><i>ResGAN-orog</i></td>
      <td align="right">7.62<br>8.69</td>
      <td align="right">0.329<br>0.441</td>
      <td align="right">1.35<br>1.81</td>
      <td align="right">14.5<br>21</td>
      <td align="right">6.71<br>5.28</td>
      <td align="right">2.87<br>3.33</td>
      <td align="right">8.29<br>9.08</td>
      <td align="right">0.238<br>0.167</td>
      <td align="right">0.472<br>0.56</td>
      <td align="right">8.9<br>10.2</td>
      <td align="right">8.63<br>5.84</td>
      <td align="right">2.1<br>1.16</td>
    </tr>
    <tr>
      <td>SpaGAN</td>
      <td align="right">11.4<br>11.6</td>
      <td align="right">0.692<br>0.761</td>
      <td align="right">1.67<br>2.03</td>
      <td align="right">27.2<br>32.1</td>
      <td align="right">66.6<br>47.1</td>
      <td align="right">6.61<br>5.67</td>
      <td align="right">8.09<br>9.01</td>
      <td align="right">0.782<br>0.782</td>
      <td align="right">1.85<br>1.98</td>
      <td align="right">21.4<br>24.8</td>
      <td align="right">33.1<br>23.8</td>
      <td align="right">4.46<br>3.95</td>
    </tr>
    <tr>
      <td><i>SpaGAN-orog</i></td>
      <td align="right">8.02<br>9.12</td>
      <td align="right">0.785<br>0.841</td>
      <td align="right">1.96<br>2.38</td>
      <td align="right">25.5<br>33</td>
      <td align="right">11<br>8.32</td>
      <td align="right">2.21<br>3.01</td>
      <td align="right">7.64<br>8.53</td>
      <td align="right">0.626<br>0.65</td>
      <td align="right">1.53<br>1.77</td>
      <td align="right">19.9<br>25.2</td>
      <td align="right">12.1<br>9.11</td>
      <td align="right">1.91<br>1.75</td>
    </tr>
    <tr>
      <td><i>UiBCorrDiff-orog</i></td>
      <td align="right">7.41<br>8.38</td>
      <td align="right">1.47<br>1.51</td>
      <td align="right">2.2<br>2.57</td>
      <td align="right">23.8<br>30.4</td>
      <td align="right">20.7<br>18.8</td>
      <td align="right">2.53<br>3.61</td>
      <td align="right">8.17<br>9.26</td>
      <td align="right">1.96<br>2.08</td>
      <td align="right">2.9<br>3.25</td>
      <td align="right">30.6<br>36.9</td>
      <td align="right">13.8<br>12.4</td>
      <td align="right">2.19<br>2.5</td>
    </tr>
    <tr>
      <td>ViT-IFCAv1<sup>†</sup></td>
      <td align="right">9.79<br>10.9</td>
      <td align="right">0.311<br>0.387</td>
      <td align="right">1.14<br>1.21</td>
      <td align="right">14.8<br>22.5</td>
      <td align="right">18.5<br>14.5</td>
      <td align="right">3.87<br>5.88</td>
      <td align="right">9.78<br>11.2</td>
      <td align="right">0.235<br>0.277</td>
      <td align="right">1.08<br>1.41</td>
      <td align="right">14.2<br>17.3</td>
      <td align="right">25.6<br>22.3</td>
      <td align="right">2.19<br>3.55</td>
    </tr>
    <tr>
      <td><i>ViT-IFCAv1-orog</i><sup>†</sup></td>
      <td align="right">9.76<br>10.8</td>
      <td align="right">0.272<br>0.419</td>
      <td align="right">1.03<br>1.28</td>
      <td align="right">17.9<br>26.8</td>
      <td align="right">22.5<br>17.5</td>
      <td align="right">3.2<br>5.16</td>
      <td align="right">9.59<br>10.9</td>
      <td align="right">0.239<br>0.249</td>
      <td align="right">0.852<br>0.996</td>
      <td align="right">14.7<br>18.6</td>
      <td align="right">15.1<br>12.1</td>
      <td align="right">2.14<br>3.15</td>
    </tr>
  </tbody>
</table>

† Aggregated over a subset of domains only (Prithvi-UNet-orog, ESD, Perfect extrapolation: ALPS, SA; ViT-IFCAv1, ESD, Perfect cross-validation: SA, NZ; ViT-IFCAv1, ESD, Perfect extrapolation: SA, NZ; ViT-IFCAv1, Emulator, Perfect cross-validation: SA, NZ; ViT-IFCAv1, Emulator, Perfect interpolation: SA, NZ; ViT-IFCAv1-orog, ESD, Perfect cross-validation: SA, NZ; ViT-IFCAv1-orog, ESD, Perfect extrapolation: SA, NZ; ViT-IFCAv1-orog, Emulator, Perfect cross-validation: SA, NZ; ViT-IFCAv1-orog, Emulator, Perfect interpolation: SA, NZ).

<!-- SCOREBOARD:END -->

## Requirements

The scripts in this repository, including the evaluation with [`ml-evaluation`](https://github.com/c3s-cordex-ml/ml-evaluation), run in a Python environment that can be created in two ways.

**Option 1: Pixi.** [Pixi](https://pixi.sh) creates the environment inside the repository (in `.pixi/`) from `pixi.toml`, with the exact versions pinned in `pixi.lock`. Install Pixi once (on Windows, see the [installation guide](https://pixi.sh/latest/installation/)), then create the environment from the root of the repository:

```bash
curl -fsSL https://pixi.sh/install.sh | sh   # install Pixi (Linux/macOS), only once
pixi install                                 # create the environment
```

Commands are then run with `pixi run`, e.g. `pixi run evaluate-model ...` (see [evaluation](./evaluation/README.md)).

**Option 2: Conda.** The [./requirements](./requirements) directory contains an `environment.yaml` file to create the Conda environment `ml-benchmark`:

```bash
conda env create -f requirements/environment.yaml
conda activate ml-benchmark
```

## Citation

> Rampal, N., González-Abad, J., Addison, H., Baño-Medina, J., Bettolli, M. L., Blasone, V., Booth, B., Coppola, E., Di Gioia, S., Oldham-Dorrington, J., Doury, A., Engelbrecht, F., Fuentes-Franco, R., Gibson, P. B., Glawion, L., Hardy, C., Ivanov, M., Lee, H. K., Legasa, M. N., Olmo, M., Orr, A., Polz, J., Rogers, M. S. J., Schillinger, M., Sharma, S., Soares, P. M. M., Sobolowski, S., Steinkopf, J., Tang, W., Tian, J.-B., Tomé, R., Wang, K.-C., Wang, Y.-C., Watson, P. A. G., Wetherell, T., Widmann, M., & Gutiérrez, J. M. (2026). *CORDEX-ML-Bench: A Benchmark for Data-Driven Regional Climate Downscaling — Experiment Design and Overview*. arXiv:2606.29172. https://arxiv.org/abs/2606.29172

## Contact

Include an issue in this repository
