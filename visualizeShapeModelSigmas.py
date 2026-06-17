import sys
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
from sklearn.cluster import DBSCAN
from scipy.spatial.distance import pdist, squareform

def main():
    if len(sys.argv) < 4:
        print("Usage: python script_name.py <filename> <threshold_pct> <cluster_eps>")
        sys.exit(1)

    filename = sys.argv[1]
    try:
        threshold_pct = float(sys.argv[2])
        cluster_eps = float(sys.argv[3])
    except ValueError:
        print("Error: Threshold and Sensitivity must be numbers.")
        sys.exit(1)

    param_suffix = f"p{str(threshold_pct).replace('.', 'pt')}_eps{str(cluster_eps).replace('.', 'pt')}"

    try:
        # 1. LOAD DATA
        df = pd.read_csv(filename, sep='\s+', skiprows=1, header=None)
        df.columns = ['X', 'Y', 'Z', 'Uncertainty']
        
        # 2. COORDINATE TRANSFORMATION (0-360 Longitude)
        r = np.sqrt(df['X']**2 + df['Y']**2 + df['Z']**2)
        df['Longitude'] = np.degrees(np.arctan2(df['Y'], df['X'])) % 360
        df['Latitude'] = np.degrees(np.arcsin(df['Z'] / r))

        # 3. GLOBAL STATISTICS
        u = df['Uncertainty']
        u_min, u_max = u.min(), u.max()
        u_mean, u_median, u_std = u.mean(), u.median(), u.std()
        u_rms = np.sqrt(np.mean(u**2))
        u_mode = u.mode().iloc[0] if not u.mode().empty else np.nan
        u_rsd = (u_std / u_mean) * 100 if u_mean != 0 else 0
        
        # 4. OUTLIER FILTERING & SORTING
        u_range = u_max - u_min
        threshold_val = u_max - (threshold_pct / 100.0 * u_range)
        outliers_df = df[df['Uncertainty'] >= threshold_val].copy()
        outliers_df = outliers_df.sort_values(by='Uncertainty', ascending=False)

        # --- CONSOLE REPORT ---
        print("=" * 65)
        print(f"STATISTICAL SUMMARY: {filename}")
        print("-" * 65)
        print(f"{'Min':<20} | {u_min:.6f}")
        print(f"{'Max':<20} | {u_max:.6f}")
        print(f"{'Mean':<20} | {u_mean:.6f}")
        print(f"{'Median':<20} | {u_median:.6f}")
        print(f"{'Mode':<20} | {u_mode:.6f}")
        print(f"{'RMS':<20} | {u_rms:.6f}")
        print(f"{'Std Deviation':<20} | {u_std:.6f}")
        print(f"{'RSD %':<20} | {u_rsd:.2f}%")
        print("-" * 65)
        print(f"Threshold ({threshold_pct}%): {threshold_val:.6f}")
        print(f"Outliers Found: {len(outliers_df)}")
        print("=" * 65)

        # 5. CLUSTERING (HAVERSINE)
        cluster_summary = []
        if not outliers_df.empty:
            rad_coords = np.radians(outliers_df[['Latitude', 'Longitude']].values)
            eps_rad = np.radians(cluster_eps)
            db = DBSCAN(eps=eps_rad, min_samples=2, metric='haversine').fit(rad_coords)
            outliers_df['Cluster_ID'] = db.labels_
            
            for k in [c for c in set(db.labels_) if c != -1]:
                cp = outliers_df[outliers_df['Cluster_ID'] == k]
                c_lon, c_lat = cp['Longitude'].mean(), cp['Latitude'].mean()
                radius = np.sqrt((cp['Longitude']-c_lon)**2 + (cp['Latitude']-c_lat)**2).max()
                cluster_summary.append({
                    'Cluster_ID': k, 'Centroid_Lon': c_lon, 'Centroid_Lat': c_lat,
                    'Radius_Deg': radius, 'Point_Count': len(cp), 
                    'Average_Uncertainty': cp['Uncertainty'].mean(),
                    'Max_Uncertainty': cp['Uncertainty'].max()
                })

        # --- VISUALIZATIONS ---
        
        # A. RAW CYLINDRICAL SCATTER (Requested Feature)
        plt.figure(figsize=(12, 6))
        plt.scatter(df['Longitude'], df['Latitude'], c=df['Uncertainty'], 
                    cmap='turbo', s=2, vmin=u_min, vmax=u_max, alpha=0.5)
        plt.xlim(0, 360); plt.ylim(-90, 90); plt.grid(True, alpha=0.2)
        plt.colorbar(label='Uncertainty')
        plt.title(f'Raw Cylindrical Projection: {filename}')
        plt.savefig(f"projection_raw_{param_suffix}.png", dpi=300)
        plt.close()

        # B. DENSE HEATMAP (gridsize=100)
        plt.figure(figsize=(12, 6))
        hb = plt.hexbin(df['Longitude'], df['Latitude'], C=df['Uncertainty'], 
                        gridsize=100, cmap='turbo', reduce_C_function=np.mean, 
                        vmin=u_min, vmax=u_max)
        plt.xlim(0, 360); plt.ylim(-90, 90); plt.colorbar(hb, label='Mean Uncertainty')
        plt.title(f'Dense Heatmap: {filename}')
        plt.savefig(f"heatmap_{param_suffix}.png", dpi=300)
        plt.close()

        # C. 2D OUTLIER CLUSTER PLOT
        if not outliers_df.empty:
            plt.figure(figsize=(12, 6))
            sc = plt.scatter(outliers_df['Longitude'], outliers_df['Latitude'], 
                            c=outliers_df['Uncertainty'], cmap='turbo', s=35, 
                            vmin=u_min, vmax=u_max, edgecolors='black', linewidths=0.2)
            for s in cluster_summary:
                plt.scatter(s['Centroid_Lon'], s['Centroid_Lat'], marker='+', s=150, color='white', linewidths=2)
                circle = plt.Circle((s['Centroid_Lon'], s['Centroid_Lat']), s['Radius_Deg'], 
                                   color='white', fill=False, ls='--', alpha=0.5)
                plt.gca().add_patch(circle)
            plt.xlim(0, 360); plt.ylim(-90, 90); plt.colorbar(sc, label='Uncertainty')
            plt.title(f'Outlier Clusters (eps={cluster_eps})')
            plt.savefig(f"clusters_2D_{param_suffix}.png", dpi=300)
            plt.close()

        # D. THE SIX PRINCIPAL 3D VIEWS (With Colorbars)
        views = {'+X': (0,0,'pos_x'), '-X': (0,180,'neg_x'), '+Y': (0,90,'pos_y'), 
                 '-Y': (0,270,'neg_y'), '+Z': (90,-90,'pos_z'), '-Z': (-90,-90,'neg_z')}
        for v_name, (el, az, suf) in views.items():
            fig = plt.figure(figsize=(10, 8))
            ax = fig.add_subplot(111, projection='3d')
            sc3 = ax.scatter(df['X'], df['Y'], df['Z'], c=df['Uncertainty'], 
                             cmap='turbo', vmin=u_min, vmax=u_max, s=1)
            ax.view_init(elev=el, azim=az)
            ax.set_title(f"3D View: {v_name}")
            fig.colorbar(sc3, ax=ax, shrink=0.6, label='Uncertainty')
            plt.savefig(f"3D_{suf}_{param_suffix}.png", dpi=200)
            plt.close(fig)

        # --- DATA EXPORT ---
        outliers_df.to_csv(f"upper_outliers_{param_suffix}.csv", index=False)
        if cluster_summary:
            pd.DataFrame(cluster_summary).to_csv(f"cluster_summary_{param_suffix}.csv", index=False)
        
        print(f"\nExecution Finished. All features saved with suffix: {param_suffix}")

    except Exception as e:
        print(f"An error occurred: {e}")

if __name__ == "__main__":
    main()