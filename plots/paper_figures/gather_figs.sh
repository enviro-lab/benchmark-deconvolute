#!/usr/bin/env bash
set -eu

figure_dir=plots/paper_figures

copy_fig() {
    num=$1
    fig_path="$2"
    b_name=$(basename "$fig_path")
    copy_path="${figure_dir}/fig_${num}_$(basename $fig_path)"
    cp "$fig_path" "$copy_path"
}
copy_supp_fig() {
    num=$1
    fig_path="$2"
    copy_path="${figure_dir}/supp_fig_${num}_$(basename $fig_path)"
    cp "$fig_path" "$copy_path"
}

# Figure 1 - Formerly Figure 2
copy_fig 1 plots/linear_regression/L2_matrix_artic.tiff

# Figure 2 - Formerly Figure 3
copy_fig 2 plots/percent_of_expected/tool_box_plots/overall-combined-percent-expected-box-summary.jpg


# Figure 3 - Formerly Figure 4
copy_fig 3 plots/percent_of_expected/observed_vs_expected_combined/O-E-boxplot.jpg

# Figure 4 - Formerly Figure 5
copy_fig 4a plots/detection_plots/detection_plots/detection_box_plot.jpg
copy_fig 4b plots/detection_plots/detection_plots/detection-w-false-pos-freyja-only.jpg

# Figure 5 - Formerly Figure 6
copy_fig 5 plots/ncdhhs_wastewater_trends/lowess_unclassified_below_threshold.jpg

# Supplementary Figure 2 - Formerly Figure 1
copy_supp_fig 2a plots/coverage_depth_plots/depth_heatmap_out/whole-genome-depth-of-coverage.jpg
copy_supp_fig 2b plots/coverage_depth_plots/depth_heatmap_out/S-depth-of-coverage.jpg
copy_supp_fig 2c plots/coverage_depth_plots/coverage_breadth_plots/whole-genome-100X-breadth-of-coverage.jpg
copy_supp_fig 2d plots/coverage_depth_plots/coverage_breadth_plots/S-100X-breadth-of-coverage.jpg

# Supplementary Figure 3 - Formerly Supplementary Figure 5
# copy_supp_fig 3 plots/percent_of_expected/observed_vs_expected/overall-abundance-summary.jpg
copy_supp_fig 3 plots/percent_of_expected/observed_vs_expected_combined/overall-abundance-summary.jpg

# Supplementary Figure 4 - Formerly Supplementary Figure 2
copy_supp_fig 4 plots/linear_regression/L2_matrix_varskip.tiff

# Supplementary Figure 5 - Formerly Supplementary Figure 4
copy_supp_fig 5 plots/percent_of_expected/tool_box_plots/overall-combined-percent-expected-box-summary-varskip.jpg

# Supplementary Figure 6 - Formerly Supplementary Figure 7
copy_supp_fig 6a plots/percent_of_expected/lineage_box_plots/WB-percent-expected-box-summary.png
copy_supp_fig 6b plots/percent_of_expected/lineage_box_plots/NWRB-percent-expected-box-summary.png
copy_supp_fig 6c plots/percent_of_expected/lineage_box_plots/PWRB-percent-expected-box-summary.png

# Supplementary Figure 7 - Formerly Supplementary Figure 3
copy_supp_fig 7 plots/detection_plots/detection_plots_varskip/detection_box_plot.jpg

# Supplementary Figure 8 - Formerly Supplementary Figure 6
copy_supp_fig 8a plots/detection_plots/detection_plots/detection-with-false-pos-Alcov-only.jpg
copy_supp_fig 8b plots/detection_plots/detection_plots/detection-with-false-pos-kallisto-only.jpg
copy_supp_fig 8c plots/detection_plots/detection_plots/detection-with-false-pos-kallisto-C-WAP-only.jpg
copy_supp_fig 8d plots/detection_plots/detection_plots/detection-with-false-pos-Kraken-2-C-WAP-only.jpg
copy_supp_fig 8e plots/detection_plots/detection_plots/detection-with-false-pos-LCS-only.jpg
copy_supp_fig 8f plots/detection_plots/detection_plots/detection-with-false-pos-lineagespot-only.jpg
copy_supp_fig 8g plots/detection_plots/detection_plots/detection-with-false-pos-LolliPop-only.jpg
copy_supp_fig 8h plots/detection_plots/detection_plots/detection-with-false-pos-VaQuERo-only.jpg

# Supplementary Figure 9
copy_supp_fig 9 plots/percent_of_expected/observed_vs_expected_extra_combined/O-E-num-lineages-boxplot.jpg

# Supplementary Figure 10
copy_supp_fig 10 plots/percent_of_expected/observed_vs_expected_extra_combined/O-E-frational-abundance-boxplot.jpg

# Supplementary Figure 11
copy_supp_fig 11 plots/coverage_depth_plots/depth_heatmap_out/mean_depth_distribution_by_gene.jpg