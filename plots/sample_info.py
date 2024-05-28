#!/usr/bin/env python

"""Shared variables and functions for plotting/statistics in nearby jupyter notebooks."""

from freyja_plot import FreyjaPlotter
from pathlib import Path # type: ignore
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
import scipy.stats as stats
from scipy.stats import tukey_hsd
import statistics

### File paths
plotting_dir = Path(__file__).absolute().resolve().parent
benchmark_dir = plotting_dir.parent
expected = benchmark_dir / "expected_abundances/control_only_no_nfw_agg.tsv"
tools_dir = benchmark_dir / "tools"
ont_dir = benchmark_dir / "ont"
artic_runs = {
    "Alcov": {
        "WB":   tools_dir / "alcov/agg/alcov-05-05-23-A41.tsv",
        "NWRB": tools_dir / "alcov/agg/alcov-05-16-23-A41.tsv",
        "PWRB": tools_dir / "alcov/agg/alcov-06-26-23-A41.tsv",
    },
    "Freyja": {
        "WB":   tools_dir / "freyja/agg/freyja-aggregated-05-05-23-A41.tsv",
        "NWRB": tools_dir / "freyja/agg/freyja-aggregated-05-16-23-A41.tsv",
        "PWRB": tools_dir / "freyja/agg/freyja-aggregated-06-26-23-A41.tsv",
    },
    "kallisto": {
        "WB":   tools_dir / "kallisto/agg/kallisto-05-05-23-A41.tsv",
        "NWRB": tools_dir / "kallisto/agg/kallisto-05-16-23-A41.tsv",
        "PWRB": tools_dir / "kallisto/agg/kallisto-06-26-23-A41.tsv",
    },
    "kallisto (C-WAP)": {
        "WB":   tools_dir / "kallisto-cwap/agg/05-05-23-A41.tsv",
        "NWRB": tools_dir / "kallisto-cwap/agg/05-16-23-A41.tsv",
        "PWRB": tools_dir / "kallisto-cwap/agg/06-26-23-A41.tsv",
    },
    "Kraken 2 (C-WAP)": {
        "WB":   tools_dir / "kraken2-cwap/agg/05-05-23-A41.tsv",
        "NWRB": tools_dir / "kraken2-cwap/agg/05-16-23-A41.tsv",
        "PWRB": tools_dir / "kraken2-cwap/agg/06-26-23-A41.tsv",
    },
    "LCS": {
        "WB":   tools_dir / "lcs/agg/lcs-05-05-23-A41.tsv",
        "NWRB": tools_dir / "lcs/agg/lcs-05-16-23-A41.tsv",
        "PWRB": tools_dir / "lcs/agg/lcs-06-26-23-A41.tsv",
    },
    "lineagespot": {
        "WB":   tools_dir / "lineagespot/agg/lineagespot-05-05-23-A41.tsv",
        "NWRB": tools_dir / "lineagespot/agg/lineagespot-05-16-23-A41.tsv",
        "PWRB": tools_dir / "lineagespot/agg/lineagespot-06-26-23-A41.tsv",
    },
    "LolliPop": {
        "WB":   tools_dir / "lollipop/agg/lollipop-05-05-23-A41.tsv",
        "NWRB": tools_dir / "lollipop/agg/lollipop-05-16-23-A41.tsv",
        "PWRB": tools_dir / "lollipop/agg/lollipop-06-26-23-A41.tsv",
    },
    "VaQuERo": {
        "WB":   tools_dir / "vaquero/agg/05-05-23-A41-aggregated.tsv",
        "NWRB": tools_dir / "vaquero/agg/05-16-23-A41-aggregated.tsv",
        "PWRB": tools_dir / "vaquero/agg/06-26-23-A41-aggregated.tsv",
    },
}

varskip_runs = {
    "Alcov": {
        "WB":   tools_dir / "alcov/agg/alcov-05-05-23-V2.tsv",
        "NWRB": tools_dir / "alcov/agg/alcov-06-16-23-V2.tsv",
        "PWRB": tools_dir / "alcov/agg/alcov-07-12-23-V2A.tsv",
    },
    "Freyja": {
        "WB":   tools_dir / "freyja/agg/freyja-aggregated-05-05-23-V2.tsv",
        "NWRB": tools_dir / "freyja/agg/freyja-aggregated-06-16-23-V2.tsv",
        "PWRB": tools_dir / "freyja/agg/freyja-aggregated-07-12-23-V2A.tsv",
    },
    "kallisto": {
        "WB":   tools_dir / "kallisto/agg/kallisto-05-05-23-V2.tsv",
        "NWRB": tools_dir / "kallisto/agg/kallisto-06-16-23-V2.tsv",
        "PWRB": tools_dir / "kallisto/agg/kallisto-07-12-23-V2A.tsv",
    },
    "kallisto (C-WAP)": {
        "WB":   tools_dir / "kallisto-cwap/agg/05-05-23-V2.tsv",
        "NWRB": tools_dir / "kallisto-cwap/agg/06-16-23-V2.tsv",
        "PWRB": tools_dir / "kallisto-cwap/agg/07-12-23-V2A.tsv",
    },
    "Kraken 2 (C-WAP)": {
        "WB":   tools_dir / "kraken2-cwap/agg/05-05-23-V2.tsv",
        "NWRB": tools_dir / "kraken2-cwap/agg/06-16-23-V2.tsv",
        "PWRB": tools_dir / "kraken2-cwap/agg/07-12-23-V2A.tsv",
    },
    "LCS": {
        "WB":   tools_dir / "lcs/agg/lcs-05-05-23-V2.tsv",
        "NWRB": tools_dir / "lcs/agg/lcs-06-16-23-V2.tsv",
        "PWRB": tools_dir / "lcs/agg/lcs-07-12-23-V2A.tsv",
    },
    "lineagespot": {
        "WB":   tools_dir / "lineagespot/agg/lineagespot-05-05-23-V2.tsv",
        "NWRB": tools_dir / "lineagespot/agg/lineagespot-06-16-23-V2.tsv",
        "PWRB": tools_dir / "lineagespot/agg/lineagespot-07-12-23-V2A.tsv",
    },
    "LolliPop": {
        "WB":   tools_dir / "lollipop/agg/lollipop-05-05-23-V2.tsv",
        "NWRB": tools_dir / "lollipop/agg/lollipop-06-16-23-V2.tsv",
        "PWRB": tools_dir / "lollipop/agg/lollipop-07-12-23-V2A.tsv",
    },
    "VaQuERo": {
        "WB":   tools_dir / "vaquero/agg/05-05-23-V2-aggregated.tsv",
        "NWRB": tools_dir / "vaquero/agg/06-16-23-V2-aggregated.tsv",
        "PWRB": tools_dir / "vaquero/agg/07-12-23-V2A-aggregated.tsv",
    },
}

### Plotting variables & data-prep functions
# our colormap for consistency across major lineages:
colormap = {
    "BQ.1* [Omicron (BQ.1.X)]":"lightgreen",
    "Omicron":"pink",
    "XBB.1.5* [Omicron (XBB.1.5.X)]":"orange",
    "Other":"Grey",
    "BA.5* [Omicron (BA.5.X)]":"purple",
    "BA.2.75* [Omicron (BA.2.75.X)]":"green",
    "Error":"red",
    "Undetermined":"blue",
}

plate_dict = {
    "05-05-23-A41": ("WB","artic"), 
    "05-16-23-A41": ("NWRB","artic"), 
    "06-26-23-A41": ("PWRB","artic"),
    "05-05-23-V2": ("WB","varskip"), 
    "06-16-23-V2": ("NWRB","varskip"), 
    "07-12-23-V2A": ("PWRB","varskip"),
}

summary_dict = {
    "B": "Wuhan-hu-1",
    "BA.1.*": "BA.1.X",
    "BA.2.*": "BA.2.X",
    "BA.2.12.1.*": "BG.X",
    "BG.*": "BG.X",
    "BA.4.*": "BA.4.X",
    "BA.5.*": "BA.5.X",
    "BF.*": "BA.5.X",
}

lineage_counts = {
    '0ADGIO1O2O3O4O5': 10,
    '0ADGIO1': 6,
    'O2O3O4O5': 4,
    '0AGIO1O2': 6,
    '0O5O3O4': 4,
    'ADGIO1O2O3': 7,
    'AGIO3O4O5': 6,
    'O1O2O3O4O5': 5,
    '0': 1,
    'O1O2': 2,
    'O3': 1,
    'O5': 1,
    'O4': 1,
    '0-2': 1,
    'A': 1,
    'G': 1,
    'I': 1,
    'D': 1,
    'O1': 1,
    'O2': 1,
    '0-3': 1,
    'O3-2': 1,
    'O3-3': 1,
    'O5-2': 1,
    'O5-3': 1,
    'O4-2': 1,
    'O4-3': 1,
    'O2-2': 1,
    'O2O3O4O5-2': 4,
    'O2O3O4O5-3': 4,
    '0ADGIO1-2': 6,
    '0AIO1O2O3O4O5': 8,
    '0-4': 1,
    'A-2': 1,
    'G-2': 1,
    'I-2': 1,
    'D-2': 1,
    'O1-2': 1,
    'O2-3': 1,
    'O3-4': 1,
    'O5-4': 1,
    'O4-4': 1,
}

mixture_renames = {
    'Mixture01': '0ADGIO1O2O3O4O5', 'Mixture02': '0ADGIO1', 'Mixture03': 'O2O3O4O5',
    'Mixture04': '0AGIO1O2', 'Mixture05': '0O5O3O4', 'Mixture06': 'ADGIO1O2O3',
    'Mixture07': 'AGIO3O4O5', 'Mixture08': 'O1O2O3O4O5', 'Mixture09': '0',
    'Mixture10': 'O1O2', 'Mixture11': 'O3', 'Mixture12': 'O5','Mixture13': 'O4', 
    'Mixture14': '0-2', 'Mixture15': 'A', 'Mixture16': 'G', 'Mixture17': 'I', 
    'Mixture18': 'D', 'Mixture19': 'O1', 'Mixture20': 'O2', 'Mixture21': '0-3',
    'Mixture22': 'O3-2', 'Mixture23': 'O3-3', 'Mixture24': 'O5-2', 'Mixture25': 'O5-3', 
    'Mixture26': 'O4-2', 'Mixture27': 'O4-3', 'Mixture28': 'O2-2', 'Mixture29': 'O2O3O4O5-2', 
    'Mixture30': 'O2O3O4O5-3', 'Mixture31': '0ADGIO1-2', 'Mixture32': '0AIO1O2O3O4O5', 
    'Mixture33': '0-4', 'Mixture34': 'A-2','Mixture35': 'G-2', 'Mixture36': 'I-2', 
    'Mixture37': 'D-2', 'Mixture38': 'O1-2', 'Mixture39': 'O2-3', 'Mixture40': 'O3-4',
    'Mixture41': 'O5-4', 'Mixture42': 'O4-4', 'NFWC': 'NFWC', 'NFWA': 'NFWA'
}
mixture_renames = {m:n.lower() if not n.startswith("NFW") else n for m,n in mixture_renames.items()}

mixtures2drop = ["Mixture19", "Mixture20","Mixture41", "Mixture42", "NFWC", "NFWA"]
mixtures2drop_samplesonly = ["Mixture19", "Mixture20","Mixture41", "Mixture42"]

def rename_mixtures(df):
    """Renames mixtures in column 'mixture' using the dict `mixture_renames`"""
    df["mixture"] = df["mixture"].apply(lambda x: mixture_renames.get(x,x))
    return df

def renameSamples(plotter:FreyjaPlotter):
    """Renames samples and drops excluded samples including NFWs"""
    # for samples like MixtureXX_barcodeYY, only keep the mixture number
    plotter.freyja_df["Sample name"] = plotter.freyja_df["Sample name"].apply(lambda x: x.split("_")[0])
    plotter.summarized_freyja_df["Sample name"] = plotter.summarized_freyja_df["Sample name"].apply(lambda x: x.split("_")[0])
    # drop NFWs and samples that we think had issues
    plotter.freyja_df= plotter.freyja_df[~plotter.freyja_df["Sample name"].isin(mixtures2drop)]
    plotter.summarized_freyja_df= plotter.summarized_freyja_df[~plotter.summarized_freyja_df["Sample name"].isin(mixtures2drop)]
    # rename samples to lineage-related naming scheme
    plotter.freyja_df["Sample name"] = plotter.freyja_df["Sample name"].apply(lambda x: mixture_renames[x])
    plotter.freyja_df = plotter.freyja_df.sort_values(by="Sample name")
    plotter.summarized_freyja_df["Sample name"] = plotter.summarized_freyja_df["Sample name"].apply(lambda x: mixture_renames[x])
    plotter.summarized_freyja_df = plotter.summarized_freyja_df.sort_values(by="Sample name")
    return plotter

# primer scheme amplicon counts for normalization
num_amps = {"Varskip":74,"Artic":99}


### Heatmaps

def sort_by_name(cols):
    sample_cols = []
    nfw_cols = []
    for col in cols:
        if col.startswith("NFW"):
            nfw_cols.append(col)
        else:
            sample_cols.append(col)
    return sorted(sample_cols) + nfw_cols
def getHeatmap(df,field,title=None,labels=None,title_y=0.7):
    fig_df = df[["batch","mixture",field]].pivot(index="batch",columns="mixture",values=field)
    fig_df = fig_df[sort_by_name(fig_df.columns)]
    fig = px.imshow(fig_df, title=title, labels=labels)
    fig.update_layout(title_y=title_y)
    return fig


### Statistics

def tukey2df(batch_res, batch_details, p_min):
    combo_res_str = str(batch_res).replace("0.000-", "0.000 -").split("\n")[2:]
    combo_column_names = list(batch_details.keys())
    combo_array = [[pd.NA]*len(combo_column_names) for c in combo_column_names]
    for line in combo_res_str:
        if line.strip():
            contents = line.split()
            col = int(contents[0].lstrip("("))
            row = int(contents[2].rstrip(")"))
            p = float(contents[4])
            combo_array[col][row] = p
    combo_array
    combo_p_vals = pd.DataFrame(combo_array, columns=combo_column_names, index=combo_column_names)
    combo_p_vals[combo_p_vals < 0.05]
    return combo_p_vals

def get_mean(df, col, value_col, batch_col="batch"):
    return df[df[batch_col]==col][value_col].mean()

def get_std_dev(df, col, value_col, batch_col="batch"):
    return df[df[batch_col]==col][value_col].std()

def get_mean_and_dev(df, row_name, value_col, batch_col="batch"):
    return f'{row_name} (mean={get_mean(df, row_name, value_col, batch_col)}, std. dev.={get_std_dev(df, row_name, value_col, batch_col)})'
    
def get_mean_and_dev_from_values(batch, values):
    return f'{batch} (mean={values.mean()}, std. dev.={values.std()}, n={len(values)})'
   
def results_as_text(tukeydf, comparison_category, p_min, replace_str=None):
    for i, row in tukeydf.iterrows():
        row_name = row.name
        for col_name, p_val in row.items():
            if replace_str:
                row_name = row_name.replace(replace_str, "")
                col_name = col_name.replace(replace_str, "")
            if col_name > i:
                if p_val <= p_min:
                    yield f"The {comparison_category} for {row_name} differed significantly from {col_name} with p-value {p_val}."
                else:
                    yield f"No significant difference in {comparison_category} (p-value={p_val}>{p_min}) was found between {row_name} and {col_name}."

def get_stats(df, scheme:str=None, value_col:str=None, p_min=0.01, replace_str=None, batch_col="batch", return_tuple=False, simple_tukey=False):
    """Calculate statistical tests (anova or t-test) and provide results based on the input parameters and data.
    
    Parameters:
    - df: DataFrame containing the data
    - scheme: A string used to filter batches using `pandas.Series.str.contains`, if provided
    - value_col: Name of the column containing the values to be analyzed, required
    - p_min: A float representing the minimum p-value threshold for significance, defaults to 0.01
    - replace_str: Optional, a string to be replaced in the output
    - batch_col: Name of the categorical column containing the names of batches to be compared, defaults to "batch"
    - return_tuple: If True, returns a tuple of (p-value, test-statistic, mean-details, tukey_results)
    - simple_tukey: If True, prints Tukey's HSD results as they come from sklearn.stats.tukey_hsd
    
    Returns:
    - Prints the results of the statistical tests
    - If significant differences are found, returns a DataFrame with Tukey's HSD results
    """

    if batch_col not in df.columns:
        raise ValueError(f"`batch_col` {batch_col} not found in dataframe")
    comparison_category = value_col.replace('_',' ')
    # reduce df to scheme only
    if scheme is not None:
        df = df[df[batch_col].str.contains(scheme)]
        # print(f"Reduced dataframe to {scheme} samples only")
        # print(df)
    num_comparison_batches = len(df[batch_col].unique())
    # print("batches:",df[batch_col].unique())
    if num_comparison_batches < 2:
        print(f"Can't compare {comparison_category} across only {num_comparison_batches} batches")
        return (None, None, None, None)
    elif num_comparison_batches == 2:
        batches = list(df[batch_col].unique())
        batch_values_dict = {batches[0]:df[df[batch_col]==batches[0]][value_col], batches[1]:df[df[batch_col]==batches[1]][value_col]}
        # batch_groupings = df[df[batch_col]==batches[0]][value_col], df[df[batch_col]==batches[1]][value_col]
        # print(batch_groupings)
        # test for normality
        for batch_name, batch_values in batch_values_dict.items():
            # print(f"Running Shapiro-Wilk test for normality of {comparison_category} for {batch_name} batch:\n", batch_values)
            normality_check = stats.shapiro(batch_values)
            if normality_check.pvalue >= p_min:
                print(f"Shapiro-Wilk test for normality of {comparison_category} for {batch_name} batch")
                print(f"p-value: {normality_check.pvalue}\tW = {normality_check.statistic}")
                print(f"The {comparison_category} was{' not' if normality_check.pvalue >= p_min else ''} normally distributed across ", end="")
        # run t-test
        t = stats.ttest_ind(*batch_values_dict.values())
        if not return_tuple:
            print(f"T-test for {scheme} samples comparing {comparison_category} across two batches")
            print(f"p-value: {t.pvalue}\tt({int(t.df)}): {t.statistic}")
            print(f"The {comparison_category} was{' not' if t.pvalue >= p_min else ''} significantly different across ", end="")
        # gather mean/std dev details for each batch
        mean_info = []
        for batch_name, batch_values in batch_values_dict.items():
            mean_info.append(get_mean_and_dev_from_values(batch_name, batch_values))
        # for batch in df[batch_col].unique():
            # mean_info.append(get_mean_and_dev(df, batch, value_col, batch_col))

        mean_info[-1] = "and " + mean_info[-1]
        mean_info.append(f"as determined by t-test (t({int(t.df)})={t.statistic}, p={t.pvalue}<{p_min}).")
        mean_info = ", ".join(mean_info)
        if replace_str:
            mean_info = mean_info.replace(replace_str, "")
        if return_tuple:
            return (t.pvalue, t.statistic ,mean_info, None)
        else:
            print(mean_info)

    else:
        # check f/p-values
        batch_values_dict = {batch:df.loc[df[batch_col]==batch, value_col].dropna() for batch in df[batch_col].unique()}
        # batch_groupings = [df.loc[df[batch_col]==batch, value_col].dropna() for batch in df[batch_col].unique()]
        
        # run anova and report results, if needed
        fvalue, pvalue = stats.f_oneway(*batch_values_dict.values())
        if not return_tuple:
            print(f"ANOVA for {scheme} samples comparing {comparison_category} across batches")
            print(f"p-value: {pvalue}\tf-value: {fvalue}")
            print(f"The {comparison_category} was{' not' if pvalue >= p_min else ''} significantly different across ", end="")
        else:
            output = [pvalue, fvalue]

        # gather mean/std dev details for each batch
        mean_info = []
        # for batch in df[batch_col].unique():
        #     mean_info.append(get_mean_and_dev(df, batch, value_col, batch_col))
        for batch_name, batch_values in batch_values_dict.items():
            mean_info.append(get_mean_and_dev_from_values(batch_name, batch_values))

        mean_info[-1] = "and " + mean_info[-1]
        mean_info.append(f"as determined by one-way ANOVA (F={fvalue}, p={pvalue}<{p_min}).")
        mean_info = ", ".join(mean_info)
        if replace_str:
            mean_info = mean_info.replace(replace_str, "")
        if return_tuple:
            output.append(mean_info)
        else:
            print(mean_info)

        if pvalue < p_min:

            # perform Tukey's HSD
            batch_details = {batch:list(df.loc[df[batch_col]==batch, value_col].dropna()) for batch in df[batch_col].unique()}
            batch_res = tukey_hsd(*batch_details.values())
            if simple_tukey:
                print("i\tbatch\tmean\tstdev")
                for i,(batch,coverage_lst) in enumerate(batch_details.items()):
                    print(f"{i}\t{batch}\t{statistics.mean(coverage_lst)}\t{statistics.stdev(coverage_lst)}")
                print()
                print(str(batch_res).replace("0.000-","0.000 -"))
                return
            tukey_df = tukey2df(batch_res, batch_details, p_min)
            written_results = results_as_text(tukey_df, comparison_category, p_min, replace_str=replace_str)
            if return_tuple:
                output.append(tukey_df)
                print(len(output))
                print(output)
                return output
            else:
                for res in written_results:
                    print(res)
                print("\nTukey's HSD results:")
                return tukey_df
        elif return_tuple:
            output.append(None)
            return output

def p_value_table(tukey_df, width=1200, height=550):
    fill_color = [['white']*len(tukey_df.columns)]
    fill_color.extend([["black" if pd.isna(x) else "white" if x<=0.01 else "lightgrey" for x in tukey_df[col]] for col in tukey_df.columns])
    fig = go.Figure(
        data=go.Table(
            header=dict(
                # values=[f"<b>{col}</b>" for col in tukey_df.columns],
                values=[""] + tukey_df.columns.to_list(),
                fill_color='white', line_color='black',
                align='center', font=dict(color='black', size=14)
            ),
            cells=dict(
                values=[tukey_df.index] + [tukey_df[col] for col in tukey_df.columns],
                # fill_color=[["black" if pd.isna(x) else "white" if x<=0.01 else "lightgrey" for x in tukey_df[col]] for col in tukey_df.columns],
                fill_color=fill_color, line_color='black',
                align='center', font=dict(color='black', size=14),
                height=30,
            )
        )
    )
    fig.update_layout(width=width, height=height)
    fig
    return fig