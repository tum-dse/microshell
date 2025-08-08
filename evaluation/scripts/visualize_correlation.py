import pandas as pd
import matplotlib.pyplot as plt
import numpy as np

def plot_half_correlation_matrix(csv_path, csv_path_2, output_file='correlation_heatmap_half.png'):
    # Read and process data
    df = pd.read_csv(csv_path, index_col=0)
    matrix = df.values.astype(float)
    folders = df.columns.tolist()
    n = len(folders)
    
    # Create mask for upper triangle
    mask = np.triu_indices(n, k=1)
    matrix[mask] = np.nan

    df_2 = pd.read_csv(csv_path_2, index_col=0)
    matrix_2 = df_2.values.astype(float)
    
    # Create mask for upper triangle
    matrix_2[mask] = np.nan
    
    # Create custom colormap
    cmap = plt.cm.Blues.copy()
    cmap.set_bad('white')  # Set NaN values to white
    
    # Create figure
    plt.figure(figsize=(12, 10))
    
    # Create heatmap with masked values
    heatmap = plt.imshow(matrix_2, cmap=cmap, vmin=0, vmax=1)
    
    # Add colorbar
    cbar = plt.colorbar(heatmap, fraction=0.046, pad=0.04)
    cbar.set_label('Correlation Strength', rotation=270, labelpad=20)
    
    # Add annotations only for non-NaN values
    for i in range(n):
        for j in range(n):
            if not np.isnan(matrix[i, j]):
                text = plt.text(j, i, f'{matrix[i, j]:.0f}',
                               ha="center", va="center", 
                               color="white" if matrix_2[i, j] > 0.5 else "black")
    
    # Customize plot
    plt.title('Folder Correlation Matrix (Lower Triangle)')
    plt.xticks(np.arange(n), folders, rotation=45, ha='right')
    plt.yticks(np.arange(n), folders)
    
    # Draw diagonal line
    plt.plot([-0.5, n-0.5], [-0.5, n-0.5], color='gray', linestyle='--')
    
    plt.tight_layout()
    plt.savefig(output_file, dpi=300, bbox_inches='tight')
    print(f"Saved half-matrix visualization to {output_file}")
    plt.show()

if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser(description='Visualize lower triangle correlation matrix')
    parser.add_argument('input_csv', help='Path to similarity_matrix.csv')
    parser.add_argument('input_csv_2', help='Path to overlap_matrix.csv')
    parser.add_argument('-o', '--output', help='Output filename', default='correlation_heatmap_half.png')
    args = parser.parse_args()
    
    plot_half_correlation_matrix(args.input_csv, args.input_csv_2, args.output)

# python visualize_correlation.py similarity_matrix.csv overlap_matrix.csv -o visualization.png