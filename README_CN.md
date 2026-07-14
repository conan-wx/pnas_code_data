# 孔调控异质成核代码与源数据

本仓库为拟投稿 PNAS 论文整理了代码、源数据、代表性 MDS 快照、ESEM 源图和电影 metadata。目录结构覆盖正文和 SI Appendix 中的主要理论计算、MDS/ESEM 证据以及新增的 CNT 自由能计算。

## 目录说明

- `code/calculate_collision_rates_Fig3.m`：计算 Fig. 3B-D 的表面迁移碰撞速率、气相直撞速率及二者比值。
- `code/calculate_kelvin_constraints_Fig4.m`：计算 Fig. 4A 的广义 Kelvin 约束曲线。
- `code/plot_potential_energy_map_Fig2B.m`：从源图重新导出 Fig. 2B 的势能云图。
- `code/analyze_MD_clusters_Fig1_Fig2_Fig4.m`：索引代表性 MDS 快照和电影文件，并生成 MDS 快照总览图。
- `code/cnt3.m`：计算双颗粒孔隙与等面积单颗粒参考体系的 Kelvin 一致 CNT 自由能曲线，并识别关键点和极值点。
- `data/Fig3_collision_rates/`：Fig. 3 碰撞速率曲线的 CSV 源数据。
- `data/Fig4_kelvin_constraints/`：Fig. 4 Kelvin 曲线和交点表的 CSV 源数据。
- `data/Fig2_potential_energy_source_data/`：2-2 nm、2-4 nm、2-10 nm 三组模型的势能云图源文件。
- `data/Free_energy_CNT/`：自由能曲线、Kelvin 关键点、自由能映射关键点、自动识别极值点和汇总表。
- `data/representative_MD_snapshots/`：三组 MDS 体系的代表性快照、统计文件和源压缩包。
- `data/ESEM_movie_metadata/`：ESEM/SI 源图、当前找到的 MP4、电影说明、首帧/抽帧预览和 metadata 表。
- `figures/`：生成图和正文合成图参考文件，包括新增的 `CNT_FE_keypoints_free_energy_600dpi.png`。
- `source_file_manifest.csv`：仓库文件清单。
- `LICENSE`：当前使用权限说明。

## 运行方式

在 MATLAB 中从仓库根目录运行：

```matlab
run('code/calculate_collision_rates_Fig3.m')
run('code/calculate_kelvin_constraints_Fig4.m')
run('code/plot_potential_energy_map_Fig2B.m')
run('code/analyze_MD_clusters_Fig1_Fig2_Fig4.m')
run('code/cnt3.m')
```

自由能脚本采用双颗粒半径 2.0 nm、等面积单颗粒半径 2.828 nm、接触角 30° 和温度 273.15 K。仓库中的参考输出对应环境饱和比 1.29、1.39 和 1.59。脚本运行时会把结果写到脚本所在目录；整理后的参考 CSV 和 PNG 已分别放入 `data/Free_energy_CNT/` 和 `figures/`。

## 数据注意事项

SI 中的 MDS 系统包括 2--2 nm、2--4 nm、2--10 nm 三组模型。本仓库已纳入三组模型的代表性可视化源文件。2--2 nm 和 2--4 nm 包括时间序列 PNG 快照和小型源压缩包；2--10 nm 当前包括 SI 体系图、势能云图、统计图和 Origin/Excel 汇总文件，未找到完整轨迹目录。

ESEM 电影目录中纳入了桌面上找到的 3 个 MP4，并生成首帧和抽帧预览。其中 `source_movie_20260603_raw.mp4` 看起来像凹坑颗粒 ESEM 视频，可能对应 Movie S3；另外两个更像 OVITO/OBS 录屏。最终投稿前仍需人工确认 Movies S1-S3 的对应关系。
