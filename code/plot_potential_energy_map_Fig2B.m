% plot_potential_energy_map_Fig2B
% Re-export the particle surface potential-energy cloud map used in Fig. 2B.
%
% The source images in data/Fig2_potential_energy_source_data were copied
% from the manuscript preparation folder. The combined panel preserves the
% labels, color bar, and annotated neck-pore potential-energy values used in
% the submitted figure.

clear; clc; close all;

repoRoot = fileparts(fileparts(mfilename('fullpath')));
dataDir = fullfile(repoRoot, 'data', 'Fig2_potential_energy_source_data');
outDir = fullfile(repoRoot, 'figures');
if ~exist(outDir, 'dir')
    mkdir(outDir);
end

combinedFile = fullfile(dataDir, 'Combined_U_Map_SCI.png');
if ~exist(combinedFile, 'file')
    error('Missing source file: %s', combinedFile);
end

img = imread(combinedFile);
fig = figure('Color', 'w', 'Units', 'pixels', ...
    'Position', [100 100 size(img, 2) size(img, 1)], ...
    'Visible', 'off');
ax = axes('Parent', fig, 'Units', 'normalized', 'Position', [0 0 1 1]);
image(ax, img);
axis(ax, 'image');
axis(ax, 'off');

outFile = fullfile(outDir, 'generated_Fig2B.png');
print(fig, outFile, '-dpng', '-r600');
close(fig);

fprintf('Fig. 2B potential-energy map exported to: %s\n', outFile);

