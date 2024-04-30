#!/usr/bin/env python

"""Shared variables and functions for plotting/statistics in nearby jupyter notebooks."""

from freyja_plot import FreyjaPlotter
from pathlib import Path # type: ignore
import plotly.express as px

plotting_dir = Path(__file__).absolute().resolve().parent
benchmark_dir = plotting_dir.parent
expected = benchmark_dir / "expected_abundances/control_only_no_nfw_agg.tsv"
tools_dir = benchmark_dir / "tools"
ont_dir = benchmark_dir / "ont"

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
        "NWRB": tools_dir / "alcov/agg/alcov-05-16-23-V2.tsv",
        "PWRB": tools_dir / "alcov/agg/alcov-07-12-23-V2A.tsv",
    },
    "Freyja": {
        "WB":   tools_dir / "freyja/agg/freyja-aggregated-05-05-23-V2.tsv",
        "NWRB": tools_dir / "freyja/agg/freyja-aggregated-05-16-23-V2.tsv",
        "PWRB": tools_dir / "freyja/agg/freyja-aggregated-07-12-23-V2A.tsv",
    },
    "kallisto": {
        "WB":   tools_dir / "kallisto/agg/kallisto-05-05-23-V2.tsv",
        "NWRB": tools_dir / "kallisto/agg/kallisto-05-16-23-V2.tsv",
        "PWRB": tools_dir / "kallisto/agg/kallisto-07-12-23-V2A.tsv",
    },
    "kallisto (C-WAP)": {
        "WB":   tools_dir / "kallisto-cwap/agg/05-05-23-V2.tsv",
        "NWRB": tools_dir / "kallisto-cwap/agg/05-16-23-V2.tsv",
        "PWRB": tools_dir / "kallisto-cwap/agg/07-12-23-V2A.tsv",
    },
    "Kraken 2 (C-WAP)": {
        "WB":   tools_dir / "kraken2-cwap/agg/05-05-23-V2.tsv",
        "NWRB": tools_dir / "kraken2-cwap/agg/05-16-23-V2.tsv",
        "PWRB": tools_dir / "kraken2-cwap/agg/07-12-23-V2A.tsv",
    },
    "LCS": {
        "WB":   tools_dir / "lcs/agg/lcs-05-05-23-V2.tsv",
        "NWRB": tools_dir / "lcs/agg/lcs-05-16-23-V2.tsv",
        "PWRB": tools_dir / "lcs/agg/lcs-07-12-23-V2A.tsv",
    },
    "lineagespot": {
        "WB":   tools_dir / "lineagespot/agg/lineagespot-05-05-23-V2.tsv",
        "NWRB": tools_dir / "lineagespot/agg/lineagespot-05-16-23-V2.tsv",
        "PWRB": tools_dir / "lineagespot/agg/lineagespot-07-12-23-V2A.tsv",
    },
    "LolliPop": {
        "WB":   tools_dir / "lollipop/agg/lollipop-05-05-23-V2.tsv",
        "NWRB": tools_dir / "lollipop/agg/lollipop-05-16-23-V2.tsv",
        "PWRB": tools_dir / "lollipop/agg/lollipop-07-12-23-V2A.tsv",
    },
    "VaQuERo": {
        "WB":   tools_dir / "vaquero/agg/05-05-23-V2-aggregated.tsv",
        "NWRB": tools_dir / "vaquero/agg/05-16-23-V2-aggregated.tsv",
        "PWRB": tools_dir / "vaquero/agg/07-12-23-V2A-aggregated.tsv",
    },
}

# primer scheme amplicon counts for normalization
num_amps = {"Varskip":74,"Artic":99}


# for heatmaps
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
