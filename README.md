# Epigenetic Age Prediction from Breast Cancer DNA Methylation

## Project overview

This project builds an **epigenetic age‑prediction model** using DNA methylation (CpG beta values) and clinical metadata from TCGA breast cancer samples. The main idea is to learn how methylation at specific CpG sites relates to patients’ age at diagnosis and to reduce very high‑dimensional omics data to a smaller, predictive subset using regularized regression.

In simple terms: given thousands of CpG methylation measurements for each patient, we train a model to predict their age at diagnosis.
## Real‑world motivation

DNA methylation patterns change with age and can be used as an “epigenetic clock”. Models like this are relevant for:

- **Health and aging research** – estimating “biological age” and studying whether some patients age faster or slower than their chronological age.
- **Disease and cancer research** – relating accelerated epigenetic aging to cancer onset and progression.
- **Forensics** – inferring approximate age from DNA when only tissue/blood is available.
- **Future personalized medicine** – using methylation‑based age measures as potential biomarkers for risk or intervention.

This project is a small, research‑style example using TCGA breast cancer data.
## Data
Main data files:
- `transposed_beta_values.csv`  
  DNA methylation beta matrix with **rows = samples (patients)** and **columns = CpG probes**.

- `breast_cancer_metadata.csv`  
  Clinical and demographic metadata for the same samples, including age‑related fields and cancer diagnosis information.

Typical shapes in the notebook:

- `betta` (beta matrix): shape **(308, 25,979)**  
  - 308 samples  
  - 25,979 CpG features

- `meta` (metadata): shape **(308, 14)**  
  - 308 samples  
  - 14 clinical/demographic columns

These shapes illustrate a classic **“many features, few samples”** setting where regularized models like Elastic Net are appropriate.

Additional intermediate files:

- `Breast_cancer_Betta.csv`, `Breast_cancer_Betta_Cleaned.csv`, `Filtered_Breast_Cancer_Data.csv`, `cancerCOEF.csv` – intermediate methylation matrices and coefficient tables used during cleaning and feature selection.
- `Data_Cleaning_with_R.R` – R script used earlier in the project to clean and filter large methylation matrices; not required to rerun the main notebook.
- `Ageprediction.ipynb` – main Python notebook containing the age prediction and feature‑selection workflow.

Each sample ultimately has:

- **Input:** tens of thousands of CpG beta values.  
- **Target:** age at diagnosis (in years), derived from clinical metadata.

## Methodology (high level)

The main analysis is implemented in `Ageprediction.ipynb` using Python.

### 1. Data loading and alignment

- Load `transposed_beta_values.csv` and `breast_cancer_metadata.csv` with pandas.
- Use a shared sample identifier (`ID`) to align beta values and metadata so every patient has both methylation features and clinical information.
- Keep only samples present in both datasets.

### 2. Target definition: age at diagnosis

- Compute **age at diagnosis in years** from clinical metadata (e.g., `age_at_diagnosis` in days divided by 365).
- Create a numeric target vector `y` where each entry is the age at diagnosis for one sample.
- Align `y` with the rows of the methylation matrix.

### 3. High‑dimensional feature matrix

- From the methylation table, set `ID` as index and drop it as a feature; keep only CpG beta value columns.
- Construct a feature matrix `X` with shape roughly `(308, 25,978)`, where each column is a CpG probe.
- This is a **p ≫ n** scenario (many more features than samples), typical in omics data.

### 4. Age prediction with Elastic Net

- Split the data into training and test sets using `train_test_split`.
- Train an **Elastic Net regression** model (combining L1/LASSO and L2/Ridge penalties) to predict age from CpG features.
- Evaluate on the test set using:
  - **Mean Squared Error (MSE)**,
  - **Coefficient of determination (R²)**.
- Elastic Net is chosen because it:
  - handles correlated, high‑dimensional features,
  - naturally performs **embedded feature selection** by shrinking many coefficients to exactly zero.

### 5. Coefficient‑based feature selection (iterative)

To reduce the number of CpG features and focus on informative sites, the notebook:

1. Fits Elastic Net on a high‑dimensional CpG matrix and age.
2. Extracts the coefficient vector from the trained model.
3. Identifies CpG sites with **non‑zero coefficients** (interpreted as informative).
4. Builds a reduced CpG matrix (e.g., `df_clear`, `df_clear4`, `df_clear5`, …) containing only those non‑zero‑coefficient features.
5. Repeats the process: refits Elastic Net on the reduced matrix, extracts coefficients again, and further shrinks to CpGs that remain non‑zero.
6. Continues this iterative filtering until reaching a compact set of CpGs and good predictive performance.

In later iterations of this pipeline, the notebook reports values around:

- **MSE:** approximately 5–6 (years²)  
- **R²:** approximately 0.89  

on its chosen train/test split, indicating that the final CpG subset explains a large proportion of the variance in age at diagnosis.

> Important: Because feature selection and evaluation are intertwined and repeated on overlapping data, these metrics are **optimistic**. For strict generalization estimates, a fixed held‑out test set or cross‑validation would be recommended.
## Algorithms and techniques

Key techniques used:

- **Elastic Net regression**
  - Linear regression with combined L1 (LASSO) and L2 (Ridge) regularization.
  - Suitable for high‑dimensional, correlated features such as CpG methylation.
  - Provides embedded feature selection via non‑zero coefficients.

- **Embedded feature selection**
  - Use Elastic Net’s non‑zero coefficients to identify informative CpG sites.
  - Iteratively refine the feature set, shrinking from tens of thousands of CpGs to a smaller, more interpretable subset.

- **Supervised regression evaluation**
  - Train/test split to estimate performance on unseen data.
  - Metrics: Mean Squared Error (MSE) and R².
## About variability of results

The performance numbers mentioned above (e.g., MSE ≈ 5–6 and R² ≈ 0.89) are **example results** from one particular run and one choice of:

- train/test split (controlled by `random_state`), and  
- Elastic Net hyperparameters (`alpha`, `l1_ratio`, `max_iter`, etc.).

Because:

- the train/test split is random (unless you always use the same `random_state`), and  
- Elastic Net has tunable hyperparameters,

**your results will likely be different** when you:

- change `alpha` or `l1_ratio`,
- change `random_state` in `train_test_split` or Elastic Net,
- or rerun the iterative coefficient‑based selection steps.

For **better or more stable performance**, users are encouraged to:

- run the notebook multiple times with different parameter settings,
- experiment with hyperparameter tuning (e.g., small grid search over `alpha` and `l1_ratio`),
- and/or use cross‑validation instead of a single train/test split.

This project is meant as a **template and exploration** of Elastic Net on high‑dimensional methylation data, not as a single fixed‑output script.

## How to run
1. Clone the repository:
         git clone https://github.com/Islam-DS/Genotype_Data_Analysis.git
         cd Genotype_Data_Analysis
2. (Optional) Create and activate a virtual environment.
3. Install dependencies 
4. Launch Jupyter Notebook
5. Open `Ageprediction.ipynb` and run the cells in order.

## Project summary

In this project, I built an **epigenetic age‑prediction model** from high‑dimensional DNA methylation data of TCGA breast cancer patients. I aligned methylation beta values with clinical metadata, defined age at diagnosis as the target, and applied **Elastic Net regression** with iterative coefficient‑based feature selection to reduce tens of thousands of CpG features to a smaller predictive subset, achieving strong R² on the notebook’s test split. Results are illustrative and depend on the chosen train/test split and hyperparameters, encouraging further experimentation and tuning.
