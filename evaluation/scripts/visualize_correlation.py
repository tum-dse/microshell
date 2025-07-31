import pandas as pd
import matplotlib.pyplot as plt
import numpy as np

def plot_half_correlation_matrix(csv_path, output_file='correlation_heatmap_half.png'):
    # Read and process data
    df = pd.read_csv(csv_path, index_col=0)
    matrix = df.values.astype(float)
    folders = df.columns.tolist()
    n = len(folders)
    
    # Create mask for upper triangle
    mask = np.triu_indices(n, k=1)
    matrix[mask] = np.nan
    
    # Create custom colormap
    cmap = plt.cm.Blues.copy()
    cmap.set_bad('white')  # Set NaN values to white
    
    # Create figure
    plt.figure(figsize=(12, 10))
    
    # Create heatmap with masked values
    heatmap = plt.imshow(matrix, cmap=cmap, vmin=0, vmax=1)
    
    # Add colorbar
    cbar = plt.colorbar(heatmap, fraction=0.046, pad=0.04)
    cbar.set_label('Correlation Strength', rotation=270, labelpad=20)
    
    # Add annotations only for non-NaN values
    for i in range(n):
        for j in range(n):
            if not np.isnan(matrix[i, j]):
                text = plt.text(j, i, f'{matrix[i, j]:.2f}',
                               ha="center", va="center", 
                               color="white" if matrix[i, j] > 0.5 else "black")
    
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
    parser.add_argument('input_csv', help='Path to correlation_matrix.csv')
    parser.add_argument('-o', '--output', help='Output filename', default='correlation_heatmap_half.png')
    args = parser.parse_args()
    
    plot_half_correlation_matrix(args.input_csv, args.output)

`python visualize_correlation.py correlation_matrix.csv -o visualization.png`