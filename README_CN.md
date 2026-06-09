# 孔调控异质成核代码与源数据

本仓库为拟投稿 PNAS 论文整理了代码、源数据、代表性 MDS 快照、ESEM 源图和电影 metadata。目录结构已按正文和 SI Appendix 中涉及的 Fig. 1-4、Fig. S1-S5 以及 Movies S1-S3 线索重新补齐。

## 目录说明

- `code/calculate_collision_rates_Fig3.m`：计算 Fig. 3B-D 的表面迁移碰撞速率、气相直撞速率及二者比值。
- `code/calculate_kelvin_constraints_Fig4.m`：计算 Fig. 4A 的广义 Kelvin 约束曲线。
- `code/plot_potential_energy_map_Fig2B.m`：从源图重新导出 Fig. 2B 的势能云图。
- `code/analyze_MD_clusters_Fig1_Fig2_Fig4.m`：索引代表性 MDS 快照和电影文件，并生成 MDS 快照总览图。
- `data/Fig3_collision_rates/`：Fig. 3 碰撞速率曲线的 CSV 源数据。
- `data/Fig4_kelvin_constraints/`：Fig. 4 Kelvin 曲线和交点表的 CSV 源数据。
- `data/Fig2_potential_energy_source_data/`：2-2 nm、2-4 nm、2-10 nm 三组模型的势能云图源文件。
- `data/representative_MD_snapshots/`：SI Fig. S1 三组 MDS 体系图、2-2 nm 和 2-4 nm 时间序列快照、2-10 nm 模型和统计图、Origin/Excel 汇总文件，以及 2-2 nm/2-4 nm 的小型源压缩包。
- `data/ESEM_movie_metadata/`：ESEM/SI 源图、当前找到的 MP4、电影说明、首帧/抽帧预览和 metadata 表。
- `figures/`：生成图和正文合成图参考文件，包括 `generated_Fig3B.png`、`generated_Fig3C.png`、`generated_Fig3D.png`、`generated_Fig4A.png`。
- `source_file_manifest.csv`：本次整理后的全仓库文件清单。
- `LICENSE`：当前使用权限说明。

## 运行方式

在 MATLAB 中从仓库根目录运行：

```matlab
run('code/calculate_collision_rates_Fig3.m')
run('code/calculate_kelvin_constraints_Fig4.m')
run('code/plot_potential_energy_map_Fig2B.m')
run('code/analyze_MD_clusters_Fig1_Fig2_Fig4.m')
```

前两个理论脚本会把输出写到当前 MATLAB 工作目录；仓库中已经放入了对应的参考输出和源数据。

## 数据注意事项

SI 中明确写了 MDS 系统包括 2--2 nm、2--4 nm、2--10 nm 三组模型。本仓库已纳入三组模型的代表性可视化源文件。2--2 nm 和 2--4 nm 找到了时间序列 PNG 快照和小型源压缩包；2--10 nm 目前在桌面上找到的是 SI 体系图、势能云图、统计图和 Origin/Excel 汇总文件，未找到对应的完整轨迹或完整时间序列快照目录。

ESEM 电影目录中纳入了桌面上找到的全部 3 个 MP4，并生成了首帧和抽帧预览。根据预览，其中 `source_movie_20260603_raw.mp4` 看起来像凹坑颗粒 ESEM 原始视频，可能对应 Movie S3；另外两个更像 OVITO/OBS 录屏。最终投稿前仍建议人工确认 Movies S1-S3 的对应关系，如有其他位置保存的正式 ESEM Movie S1/S2，需要再补进该目录。

