import argparse
import pandas as pd
from datetime import datetime, timedelta
from typing import Literal

def calculate_period(date_str, period:Literal["day","week","month"]):
    """Converts date to date of given period type"""
    date = datetime.strptime(date_str, '%Y-%m-%d')
    if period == 'day':
        return date.strftime('%Y-%m-%d')
    elif period == 'week':
        return date.strftime('%Y-%U')
    elif period == 'month':
        return date.strftime('%Y-%m')
    else:
        raise ValueError("Invalid period. Choose 'day', 'week', or 'month'.")

def checkLocations(location_list, allowed_locations):
    """Raises AttributeError if any locations are missing from `allowed_locations`"""

    extras = set(location_list) - set(allowed_locations)
    if extras:
        raise AttributeError("Invalid location(s):",extras)

def findThresholdLineages(
    csv_file, location_list=[], threshold_percent=50, period='week', start_date=None, end_date=None
):
    """
    Calculate Pango lineages that comprise more than a specified percentage of all samples for the given date range and locations.

    Args:
        csv_file (str): Path to the CSV file containing the data.
        location_list (list): List of location names to filter samples. If empty, all locations are considered.
        threshold_percent (float): The threshold percentage for Pango lineages (default is 50%).
        period (str): The period for grouping data ('day', 'week', or 'month').
        start_date (str or None): Start date for filtering samples (YYYY-MM-DD). If None, set to the minimum date in the dataset.
        end_date (str or None): End date for filtering samples (YYYY-MM-DD). If None, set to the maximum date in the dataset.

    Returns:
        set: A set of lineages meeting the threshold for each period.
    """
    # Load the CSV file into a Pandas DataFrame
    df = pd.read_csv(csv_file)
    df['Location'] = df['Sample #'].apply(lambda x: x.split('/',1)[1].split('-')[0])
    # print(df.head())

    # # Use dataset range to set default dates
    # if start_date is None:
    #     start_date = min(df['Collection date'])
    # if end_date is None:
    #     end_date = max(df['Collection date'])

    # If location_list is [], 
    if type(location_list) == str:
        location_list = [location_list]
    elif location_list:
        checkLocations(location_list, df["Location"].unique())

    # Filter the data based on date range and location
    if start_date: df = df[df['Collection date'] >= start_date]
    if end_date: df = df[df['Collection date'] <= end_date]
    if location_list: df = df[df['Location'].isin(location_list)]
    # df = df[(df['Collection date'] >= start_date) &
    #                   (df['Collection date'] <= end_date) &
    #                   (df['Location'].isin(location_list))]

    # Apply the period calculation function to create a new 'Period' column
    df['Period'] = df['Collection date'].apply(lambda x: calculate_period(x, period))
    # print("Filt:")
    # print(df)

    # Initialize a set to store lineages meeting the threshold
    lineages = set()

    # Iterate over unique periods
    unique_periods = df['Period'].unique()
    for period in unique_periods:
        period_df = df[df['Period'] == period]
        period_total_samples = len(period_df)
        # print(period_df)
        # print("pts:",period_total_samples)
        # print("period:",period, period_total_samples)

        # Calculate the percentage of each Pango lineage within the period
        lineage_counts = period_df['Pango lineage'].value_counts()
        lineage_percentages = (lineage_counts / period_total_samples) * 100
        # print("lineage_percentages",lineage_percentages)

        # Add lineages that meet the threshold for this period to the set
        for lineage, percentage in lineage_percentages.items():
            if percentage > threshold_percent:
                # print("Adding", lineage, percentage)
                lineages.add(lineage)

    return lineages

# Example usage:
# csv_file = 'your_data.csv'
# location_list = ['USA/NC', 'USA/SC']
# threshold_percent = 50  # Default threshold is 50%
# period = 'day'  # Change period as needed
# start_date = None  # Default to minimum date in the dataset
# end_date = None  # Default to maximum date in the dataset

# result = findThresholdLineages(csv_file, location_list, threshold_percent, period, start_date, end_date)
# print("Lineages meeting the threshold:")
# for lineage in result:
#     print(lineage)

def parse_args():
    parser = argparse.ArgumentParser(description="Calculate Pango lineages found above a threshold percentage for a desired time or locations.")
    parser.add_argument("csv_file", type=str, help="Path to the CSV file containing the data.")
    parser.add_argument("--location_list", "-l", nargs="+", type=str, help="List of location names to filter samples.")
    parser.add_argument("--threshold_percent", "-p", type=float, default=50, help="Threshold percentage for Pango lineages (default is 50%).")
    parser.add_argument("--period", "-T", type=str, default="day", choices=["day", "week", "month"], help="The period for grouping data ('day', 'week', or 'month').")
    parser.add_argument("--start_date", "-s", type=str, default=None, help="Start date for filtering samples (YYYY-MM-DD). If not provided, set to the minimum date in the dataset.")
    parser.add_argument("--end_date", "-e", type=str, default=None, help="End date for filtering samples (YYYY-MM-DD). If not provided, set to the maximum date in the dataset.")
    return parser.parse_args()
    

def main():
    args = parse_args()
    lineages = findThresholdLineages(csv_file=args.csv_file, location_list=args.location_list, threshold_percent=args.threshold_percent, period=args.period, start_date=args.start_date, end_date=args.end_date)
    for lineage in lineages:
        print(lineage)

if __name__ == '__main__':
    main()