import pandas as pd
import matplotlib.pyplot as plt

# Read the CSV file into a DataFrame with headers
df = pd.read_csv('processing_log.csv', header=None, names=['PSD Filename', 'Size of File', 'Start Time', 'End Time', 'Time Taken'])

# Sort the DataFrame by the 'End Time' column
df_sorted = df.sort_values(by='End Time')

# Save the sorted DataFrame to a new CSV file
df_sorted.to_csv('sorted_processing_log.csv', index=False)

# Read the sorted CSV file into a new DataFrame
df = pd.read_csv('sorted_processing_log.csv')

# Calculate mean, mode, and median of the 'Time Taken' column
mean_time_taken = df['Time Taken'].mean()
mode_time_taken = df['Time Taken'].mode()[0]  # Mode might have multiple values, so we take the first one
median_time_taken = df['Time Taken'].median()

# Calculate the average of (Time Taken / Size of File)
df['Time per Size'] = df['Time Taken'] / (df['Size of File']/(1024 * 1024))
average_time_per_size = df['Time per Size'].mean()

# Calculate mean file size in MB
mean_file_size_mb = df['Size of File'].mean() / (1024 * 1024)

# Calculate parallel_mean_time
last_end_time = df_sorted.iloc[-1]['End Time']
first_start_time = df_sorted.iloc[0]['Start Time']
num_entries = len(df_sorted)
parallel_mean_time = (last_end_time - first_start_time) / num_entries

# Calculate parallel_mean_time_per_size
parallel_mean_time_per_size = parallel_mean_time / mean_file_size_mb

# Print the results
print('Serial Analysis....')
print("Mean Time Taken per PSD:", mean_time_taken)
print("Mode Time Taken per PSD:", mode_time_taken)
print("Median Time Taken per PSD:", median_time_taken)
print("Average Time per Size (Seconds/MB):", average_time_per_size)

print("\nParallel Analysis....")
print("Time span: ", (last_end_time - first_start_time) )
print("Total files processed: ", num_entries)
print("Mean File Size (MB):", mean_file_size_mb)
print("Mean Time Taken per PSD:", parallel_mean_time)
print("Mean Time Taken per PSD per MB:", parallel_mean_time_per_size)
