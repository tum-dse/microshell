import os
import csv
from collections import defaultdict

def parse_function_file():
    folder_funcs = defaultdict(set)
    file_counts = defaultdict(int)
    
    with open('file_functions.txt', 'r') as f:
        current_folder = None
        for line in f:
            line = line.strip()
            if line.startswith('Folder: '):
                current_folder = line[8:]
            elif line.startswith('xf::cv::'):
                func = line.split('::')[-1]
                if current_folder:
                    folder_funcs[current_folder].add(func)
                file_counts[func] += 1
                
    return {k: sorted(v) for k, v in folder_funcs.items()}, file_counts

def calculate_correlation_matrix(folder_funcs):
    folders = sorted(folder_funcs.keys())
    n = len(folders)
    matrix = [[0.0]*n for _ in range(n)]
    
    for i in range(n):
        set_i = set(folder_funcs[folders[i]])
        for j in range(i, n):
            set_j = set(folder_funcs[folders[j]])
            intersection = len(set_i & set_j)
            union = len(set_i | set_j) or 1
            matrix[i][j] = matrix[j][i] = round(intersection/union, 4)
    
    return folders, matrix

def main():
    folder_funcs, file_counts = parse_function_file()
    
    # Generate top 10 functions
    top_functions = sorted(file_counts.items(), key=lambda x: (-x[1], x[0]))[:10]
    with open('top_10_functions.txt', 'w') as f:
        f.write("Top 10 Most Used Functions Across All Files:\n")
        for func, count in top_functions:
            f.write(f"{func}: {count}\n")
    
    # Generate folder correlation matrix
    folders, matrix = calculate_correlation_matrix(folder_funcs)
    with open('correlation_matrix.csv', 'w', newline='') as csvfile:
        writer = csv.writer(csvfile)
        writer.writerow(['Folder'] + [os.path.basename(f) for f in folders])
        for i, folder in enumerate(folders):
            writer.writerow([os.path.basename(folder)] + matrix[i])

if __name__ == "__main__":
    main()

# python3 analyze_functions.py