% analyze_MD_clusters_Fig1_Fig2_Fig4
% Create file-level indexes and a visual overview of representative MDS data.
%
% This repository contains representative snapshots, source visualization
% files, and summary workbooks rather than full MD trajectories. This script
% indexes the included images for the 2-2 nm, 2-4 nm, and 2-10 nm systems and
% exports a compact contact sheet for audit and repository review.

clear; clc; close all;

repoRoot = fileparts(fileparts(mfilename('fullpath')));
snapshotRoot = fullfile(repoRoot, 'data', 'representative_MD_snapshots');
movieRoot = fullfile(repoRoot, 'data', 'ESEM_movie_metadata', 'movies');
outDir = fullfile(repoRoot, 'figures');
if ~exist(outDir, 'dir')
    mkdir(outDir);
end

imageExts = {'.png', '.jpg', '.jpeg', '.tif', '.tiff'};
imageFiles = collectFiles(snapshotRoot, imageExts);

systems = cell(numel(imageFiles), 1);
relPaths = cell(numel(imageFiles), 1);
fileNames = cell(numel(imageFiles), 1);
bytes = zeros(numel(imageFiles), 1);
widthPx = zeros(numel(imageFiles), 1);
heightPx = zeros(numel(imageFiles), 1);

for k = 1:numel(imageFiles)
    f = imageFiles{k};
    relPaths{k} = relativePath(f, repoRoot);
    fileNames{k} = getFileName(f);
    bytes(k) = getFileBytes(f);
    systems{k} = inferSystem(relPaths{k});

    try
        info = imfinfo(f);
        widthPx(k) = info(1).Width;
        heightPx(k) = info(1).Height;
    catch
        widthPx(k) = NaN;
        heightPx(k) = NaN;
    end
end

T = table(systems, relPaths, fileNames, bytes, widthPx, heightPx, ...
    'VariableNames', {'system', 'relative_path', 'file_name', ...
    'size_bytes', 'width_px', 'height_px'});
writetable(T, fullfile(snapshotRoot, 'MD_snapshot_index_from_matlab.csv'));

movieFiles = collectFiles(movieRoot, {'.mp4', '.mov', '.avi'});
movieRelPaths = cell(numel(movieFiles), 1);
movieNames = cell(numel(movieFiles), 1);
movieBytes = zeros(numel(movieFiles), 1);
for k = 1:numel(movieFiles)
    movieRelPaths{k} = relativePath(movieFiles{k}, repoRoot);
    movieNames{k} = getFileName(movieFiles{k});
    movieBytes(k) = getFileBytes(movieFiles{k});
end
Tmovie = table(movieRelPaths, movieNames, movieBytes, ...
    'VariableNames', {'relative_path', 'file_name', 'size_bytes'});
writetable(Tmovie, fullfile(repoRoot, 'data', 'ESEM_movie_metadata', ...
    'movie_file_index_from_matlab.csv'));

makeContactSheet(imageFiles, systems, outDir);

fprintf('Indexed %d MDS image files and %d movie files.\n', ...
    numel(imageFiles), numel(movieFiles));

function files = collectFiles(rootDir, exts)
    files = {};
    if ~exist(rootDir, 'dir')
        return;
    end
    listing = dir(rootDir);
    for i = 1:numel(listing)
        name = listing(i).name;
        if strcmp(name, '.') || strcmp(name, '..')
            continue;
        end
        fullName = fullfile(rootDir, name);
        if listing(i).isdir
            files = [files; collectFiles(fullName, exts)]; %#ok<AGROW>
        else
            [~, ~, ext] = fileparts(name);
            if any(strcmpi(ext, exts))
                files{end + 1, 1} = fullName; %#ok<AGROW>
            end
        end
    end
end

function rel = relativePath(pathName, rootDir)
    rel = strrep(pathName, [rootDir filesep], '');
    rel = strrep(rel, filesep, '/');
end

function name = getFileName(pathName)
    [~, base, ext] = fileparts(pathName);
    name = [base ext];
end

function n = getFileBytes(pathName)
    d = dir(pathName);
    if isempty(d)
        n = NaN;
    else
        n = d(1).bytes;
    end
end

function system = inferSystem(relPath)
    if contains(relPath, '2-2nm')
        system = '2-2nm';
    elseif contains(relPath, '2-4nm')
        system = '2-4nm';
    elseif contains(relPath, '2-10nm')
        system = '2-10nm';
    else
        system = 'summary_or_SI';
    end
end

function makeContactSheet(imageFiles, systems, outDir)
    wantedSystems = {'2-2nm', '2-4nm', '2-10nm'};
    selected = {};
    labels = {};

    for s = 1:numel(wantedSystems)
        idx = find(strcmp(systems, wantedSystems{s}));
        idx = preferSimpleSnapshots(idx, imageFiles);
        idx = idx(1:min(numel(idx), 4));
        for j = 1:numel(idx)
            selected{end + 1} = imageFiles{idx(j)}; %#ok<AGROW>
            labels{end + 1} = wantedSystems{s}; %#ok<AGROW>
        end
    end

    if isempty(selected)
        warning('No representative MDS images found for contact sheet.');
        return;
    end

    nCols = 4;
    nRows = ceil(numel(selected) / nCols);
    fig = figure('Color', 'w', 'Units', 'centimeters', ...
        'Position', [2 2 22 5.5 * nRows], 'Visible', 'off');
    for k = 1:numel(selected)
        subplot(nRows, nCols, k);
        img = imread(selected{k});
        image(img);
        axis image off;
        title({labels{k}, getFileName(selected{k})}, ...
            'Interpreter', 'none', 'FontSize', 8);
    end
    print(fig, fullfile(outDir, 'generated_MD_snapshot_overview.png'), ...
        '-dpng', '-r300');
    close(fig);
end

function idxOut = preferSimpleSnapshots(idx, imageFiles)
    simple = false(numel(idx), 1);
    for k = 1:numel(idx)
        name = lower(getFileName(imageFiles{idx(k)}));
        hasTime = ~isempty(regexp(name, '(^|[^0-9])([0-9]+)(ps|ns)', 'once'));
        isComposite = contains(name, 'sequence') || contains(name, 'ym_');
        simple(k) = hasTime && ~isComposite;
    end
    idxOut = [idx(simple); idx(~simple)];
end
