clear; clc; close all;

%% =================== 0. USER SETTINGS: modify only this block for most figures ===================

%% Geometry parameters
% R_nm: radius of each particle in the dual-particle pore model.
% R_single_nm: radius of the equivalent single particle.
% theta_deg: water contact angle on the particle surface.
R_nm      = 2.0;
R_single_nm = 2.828;
theta_deg = 30.0;
tau_line  = 0;

%% Thermodynamic parameters
T       = 273.15;
gamma   = 0.0715;
rho_l   = 997.0;
M       = 18.01528e-3;
Rg      = 8.314462618;
NA      = 6.02214076e23;
kB      = 1.380649e-23;
eV      = 1.602176634e-19;

%% Saturation ratios to be compared in the same figure
% Change only this line if you want different ambient saturation ratios.
% Example: S_list = [1.20 1.39 1.50 1.70];
% The figure automatically draws two curves for each S:
%   solid line  = dual-particle pore
%   dashed line = single-particle reference
S_list = [1.29 1.39 1.59];

% Sort saturation ratios from low to high for both the legend and the
% left-panel feature summary. Keep this true for a clean SCI-style order:
% S=1.29 group first, then S=1.39, then S=1.47.
sort_S_list_for_display = true;

%% Numerical resolution for dual-particle pore geometry
omega_min_deg = 0.5;
omega_max_deg = 179.0;
gap_deg       = 0.02;
n_conc        = 12000;
n_conv        = 24000;

%% Numerical resolution for single-particle reference
single_r_min_nm = 0.01;
single_r_max_nm = 200.0;
single_scan_N   = 25000;

%% Axis range and data range
% x_lim_manual controls the visible x-axis range.
% free_energy_y_mode = 'manual' uses y_lim_manual.
% free_energy_y_mode = 'auto' lets MATLAB choose the y-axis range from data.
i_min_keep = 1.0;
i_max_keep = 32000.0;
x_lim_manual = [1 32000];

%% Free-energy display settings
% free_energy_mode: 'relative' or 'absolute'
% free_energy_unit: 'kBT', 'eV', or 'J'
% relative_zero_mode: 'first' means every curve starts from zero near i_min_keep.
free_energy_mode = 'relative';
free_energy_unit = 'kBT';
relative_zero_mode = 'first';

%% Figure style settings
font_name        = 'Times New Roman';
font_size_axis   = 12.0;
font_size_label  = 14.5;
font_size_legend = 9.8;
font_size_text   = 12.0;
font_size_title  = 12.0;
line_width       = 2.8;
single_line_width = 2.35;
marker_size      = 7.5;
marker_line_width = 1.35;
axis_line_width  = 1.35;

%% What to show in the exported figure
show_kelvin_check_figure = false;       % true: also export a Kelvin-check figure
show_single_reference_in_free_energy = true;
show_grid = false;
show_title = false;                    % SCI figures usually do not need an internal title
show_key_point_box = false;             % false keeps the figure clean; exact values are exported to CSV
show_key_vertical_lines = true;
show_key_markers_on_curves = true;
show_key_large_labels = true;
key_point_box_position = [0.055 0.640];  % normalized [x y], only used when show_key_point_box = true

% The full curve has a very negative tail at large i. A focused y-range makes
% the barrier and the single-particle reference readable.
free_energy_y_mode = 'manual';  % change to 'auto' if you want MATLAB to choose y-axis automatically
y_lim_manual = [-500 1700];      % visible y-axis range when free_energy_y_mode = 'manual'
make_dual_zoom_inset = true;
zoom_xlim = [85 650];
zoom_ylim = [-130 25];
zoom_inset_position = [0.175 0.185 0.350 0.100];  % figure-normalized [left bottom width height]
show_zoom_source_box = true;
zoom_source_box_color = [0.88 0.18 0.18];
zoom_source_box_line_width = 0.85;
zoom_inset_font_size = 7.0;
zoom_inset_axis_line_width = 1.05;
zoom_inset_line_width = 2.10;
zoom_inset_single_line_width = 1.80;
zoom_inset_marker_size = 4.8;
zoom_inset_marker_line_width = 0.90;

%% Automatic curve-feature marking
% Only local extrema are plotted as filled black circles.
% Inflection points are not marked because they do not correspond to a unique
% Kelvin-equilibrium state or an independent nucleation barrier in this model.
% If no reliable extremum is found on a curve segment, nothing is marked.
show_auto_curve_features = true;
feature_mark_dual_curves = true;
feature_mark_single_curves = true;
feature_mark_extrema = true;
feature_mark_inflections = false;
feature_label_points = true;
feature_label_mode = 'left_panel';      % 'left_panel' or 'near_curve'
feature_visible_y_only = true;          % true: only label points inside the current y-axis window
% Left-panel text-box position in normalized axes units: [x_top y_top width height].
% x_top: smaller -> move left, larger -> move right.
% y_top: smaller -> move down, larger -> move up.
% width/height are reserved layout parameters; the text anchor is the top-left point.
feature_panel_position = [0.035 0.715 0.66 0.24];
feature_panel_font_name = font_name;
feature_panel_font_size = 10;

% Style for the four large Kelvin key labels T / Sg,max / B / F.
% They are tied to the left feature-panel text so the font family and size stay unified.
% No background and no edge are used, so these labels have no visible text-box outline.
key_label_font_name = feature_panel_font_name;
key_label_font_size = feature_panel_font_size;
key_label_font_weight = 'normal';
key_label_background_color = 'none';
key_label_edge_color = 'none';
key_label_margin = 0.1;

feature_panel_title = 'Extremum points';
feature_panel_show_DeltaG = false;       % false: do not display free-energy values in the panel
feature_panel_sort_by_S = true;          % true: sort S from small to large
feature_panel_layout = 'horizontal_by_S'; % 'horizontal_by_S' or 'vertical_by_S'
feature_panel_column_width = 0.010;       % normalized x spacing between S columns; larger = wider columns
feature_detection_x_range = x_lim_manual;
feature_resample_N = 2400;              % larger value = finer numerical detection
feature_smooth_window = 25;             % odd/even are both accepted; code converts it to an odd window
feature_edge_cut_frac = 0.018;          % ignore features too close to the two ends of a curve segment
feature_derivative_tol_frac = 2.0e-4;   % smaller = more sensitive extremum detection
feature_curvature_tol_frac = 2.0e-4;    % not used when feature_mark_inflections = false
feature_min_log10_separation = 0.050;   % minimum spacing between neighboring markers on log10(i)
feature_bar_height_frac = 0.034;        % vertical-bar height as a fraction of current y-axis range
feature_font_size = 7.8;
feature_label_dx_frac = 0.018;          % label horizontal offset in log10(i) units
feature_label_dy_frac = 0.035;          % label vertical offset as a fraction of y-axis range
feature_text_margin = 2.2;
feature_marker_size = 5.6;
feature_marker_line_width = 1.05;
feature_bar_line_width = 1.75;


%% Export settings
% Keep output_prefix short. MATLAB R2018b warns when script/function names exceed 63 characters.
output_prefix = 'CNT_FE_keypoints';
output_folder_mode = 'script_folder';   % 'script_folder' or 'current_folder'
save_png = true;                        % automatically export PNG
save_tif = false;
save_csv = true;
save_eps = false;
save_pdf = false;
png_dpi = 600;
tif_dpi = 600;
open_png_after_export = false;

%% Figure size in centimeters
fig_width_cm = 20.0;
fig_height_cm = 13.0;
axes_position = [0.105 0.150 0.865 0.805];

%% =================== 1. Constants and basic checks ===================

R      = R_nm * 1e-9;
Rsing  = R_single_nm * 1e-9;
theta  = deg2rad(theta_deg);
Vm     = M / rho_l;
v0     = Vm / NA;

script_fullpath = mfilename('fullpath');
if strcmpi(output_folder_mode, 'script_folder') && ~isempty(script_fullpath)
    output_dir = fileparts(script_fullpath);
else
    output_dir = pwd;
end
if isempty(output_dir) || ~exist(output_dir, 'dir')
    output_dir = pwd;
end
fprintf('Output folder: %s\n', output_dir);

S_list = S_list(:).';
if exist('sort_S_list_for_display','var') && sort_S_list_for_display
    S_list = sort(S_list, 'ascend');
end

if any(S_list <= 1)
    error('All S values in S_list must be larger than 1.');
end

if omega_max_deg >= 180
    error('omega_max_deg must be lower than 180 deg for the present pore geometry.');
end

omega_switch = pi/2 - theta;
omega_min = deg2rad(omega_min_deg);
omega_max = deg2rad(omega_max_deg);
gap = deg2rad(gap_deg);

if omega_switch <= omega_min + gap
    error('omega_switch <= omega_min + gap. Reduce theta or omega_min.');
end
if omega_switch >= omega_max - gap
    error('omega_switch >= omega_max - gap. Increase omega_max or reduce theta.');
end

fprintf('\n============================================================\n');
fprintf('Dual-particle pore CNT free energy: Kelvin-consistent version\n');
fprintf('R = %.3f nm, R_single = %.3f nm, theta = %.2f deg, T = %.2f K\n', R_nm, R_single_nm, theta_deg, T);
fprintf('S values used for free-energy curves: '); fprintf('%.2f ', S_list); fprintf('\n');
fprintf('omega_switch = %.6f deg\n', rad2deg(omega_switch));
fprintf('============================================================\n\n');

%% =================== 3. Dual-particle geometry and Kelvin curves ===================

omega_c = linspace(omega_min, omega_switch-gap, n_conc).';
omega_v = linspace(omega_switch+gap, omega_max, n_conv).';

Gc = dual_pore_geometry_kelvin(omega_c, R, theta, gamma, Vm, Rg, T, v0, 'concave');
Gv = dual_pore_geometry_kelvin(omega_v, R, theta, gamma, Vm, Rg, T, v0, 'convex');

Gc_end = take_last_valid(Gc);
Gv_start = take_first_valid(Gv);

i_trans = mean([Gc_end.i, Gv_start.i]);
S_trans = mean([Gc_end.Sp, Gv_start.Sp, Gc_end.S0, Gv_start.S0]);
omega_trans_deg = rad2deg(omega_switch);

Gdual = merge_geometry(Gc, Gv, i_min_keep, i_max_keep);
Sg_dual = max(Gdual.Sp, Gdual.S0);

[i_control_switch, S_control_switch] = find_intersection(Gdual.i, Gdual.Sp, Gdual.i, Gdual.S0, [max(i_trans*1.05, 500), i_max_keep]);
omega_control_switch_deg = interp1_unique(Gdual.i, Gdual.omega, i_control_switch) * 180/pi;

[Sg_max, idx_Sg_max] = max(Sg_dual);
i_Sg_max = Gdual.i(idx_Sg_max);
omega_Sg_max_deg = Gdual.omega(idx_Sg_max)*180/pi;

%% =================== 4. Single-particle Kelvin reference ===================

GsingleK = single_particle_kelvin_reference(R_single_nm, theta_deg, T, gamma, rho_l, M, Rg, NA, single_r_min_nm, single_r_max_nm, single_scan_N, i_min_keep, i_max_keep);

S_single_on_dual = interp1(GsingleK.i, GsingleK.S, Gdual.i, 'linear', NaN);
valid_cmp = isfinite(S_single_on_dual) & isfinite(Sg_dual);

[i_fail_all, S_fail_all] = find_all_intersections(Gdual.i(valid_cmp), Sg_dual(valid_cmp), Gdual.i(valid_cmp), S_single_on_dual(valid_cmp), [i_min_keep, i_max_keep]);

if isempty(i_fail_all)
    i_pore_fail = NaN;
    S_pore_fail = NaN;
else
    after_trans = i_fail_all > i_trans;
    if any(after_trans)
        ii = find(after_trans, 1, 'last');
    else
        ii = numel(i_fail_all);
    end
    i_pore_fail = i_fail_all(ii);
    S_pore_fail = S_fail_all(ii);
end
omega_pore_fail_deg = interp1_unique(Gdual.i, Gdual.omega, i_pore_fail) * 180/pi;

[i_fail_Sp, S_fail_Sp] = find_all_intersections(Gdual.i, Gdual.Sp, GsingleK.i, GsingleK.S, [i_min_keep, i_max_keep]);
[i_fail_S0, S_fail_S0] = find_all_intersections(Gdual.i, Gdual.S0, GsingleK.i, GsingleK.S, [i_min_keep, i_max_keep]);

fprintf('================ Kelvin key points from the SAME geometry ================\n');
fprintf('Shape transition theta+omega=90 deg:\n');
fprintf('  i = %.6f, S_trans ~= %.6f, omega = %.6f deg\n', i_trans, S_trans, omega_trans_deg);
fprintf('Maximum Kelvin growth threshold Sg=max(Sp,S0):\n');
fprintf('  i = %.6f, Sg_max = %.6f, omega = %.6f deg\n', i_Sg_max, Sg_max, omega_Sg_max_deg);
fprintf('Sp vs S0 control-switch point after transition:\n');
fprintf('  i = %.6f, S = %.6f, omega = %.6f deg\n', i_control_switch, S_control_switch, omega_control_switch_deg);
fprintf('Pore-failure point Sg_dual = S_single:\n');
fprintf('  i = %.6f, S = %.6f, omega = %.6f deg\n', i_pore_fail, S_pore_fail, omega_pore_fail_deg);
fprintf('========================================================================\n\n');

if any(~isfinite(S_list)) || any(S_list <= 1)
    error('All selected saturation ratios in S_list must be finite and larger than 1.');
end

fprintf('Free-energy curves will be calculated at S = ');
fprintf('%.2f ', S_list);
fprintf('\n\n');

%% =================== 5. Free-energy calculation ===================

nS = numel(S_list);
colors = lines(max(nS, 3));

DGc_abs_J = nan(numel(Gc.i), nS);
DGv_abs_J = nan(numel(Gv.i), nS);
DGc_plot  = nan(numel(Gc.i), nS);
DGv_plot  = nan(numel(Gv.i), nS);

summary_rows = {};

for sID = 1:nS
    S = S_list(sID);

    DGc_abs = cnt_free_energy(Gc.i, Gc.Avc, Gc.Asl, Gc.L, theta, T, gamma, tau_line, S);
    DGv_abs = cnt_free_energy(Gv.i, Gv.Avc, Gv.Asl, Gv.L, theta, T, gamma, tau_line, S);

    DG_all_abs = [DGc_abs; DGv_abs];
    i_all_tmp = [Gc.i; Gv.i];
    valid_all = isfinite(DG_all_abs) & isfinite(i_all_tmp) & i_all_tmp >= i_min_keep & i_all_tmp <= i_max_keep;

    DGc_unit = convert_energy_unit(DGc_abs, T, free_energy_unit);
    DGv_unit = convert_energy_unit(DGv_abs, T, free_energy_unit);

    if strcmpi(free_energy_mode, 'absolute')
        offset = 0;
    elseif strcmpi(free_energy_mode, 'relative')
        if strcmpi(relative_zero_mode, 'first')
            [~, first_idx] = min(i_all_tmp(valid_all));
            DGvalid = convert_energy_unit(DG_all_abs(valid_all), T, free_energy_unit);
            offset = DGvalid(first_idx);
        elseif strcmpi(relative_zero_mode, 'min')
            DGvalid = convert_energy_unit(DG_all_abs(valid_all), T, free_energy_unit);
            offset = min(DGvalid);
        else
            error('Unknown relative_zero_mode.');
        end
    else
        error('Unknown free_energy_mode.');
    end

    DGc_abs_J(:,sID) = DGc_abs;
    DGv_abs_J(:,sID) = DGv_abs;
    DGc_plot(:,sID) = DGc_unit - offset;
    DGv_plot(:,sID) = DGv_unit - offset;

    i_tmp = [Gc.i; Gv.i];
    omega_tmp = [Gc.omega; Gv.omega];
    branch_tmp = [Gc.branch; Gv.branch];
    DG_tmp = [DGc_plot(:,sID); DGv_plot(:,sID)];
    valid_tmp = isfinite(i_tmp) & isfinite(DG_tmp) & i_tmp >= i_min_keep & i_tmp <= i_max_keep;

    [DG_star, idxmaxlocal] = max(DG_tmp(valid_tmp));
    i_valid_tmp = i_tmp(valid_tmp);
    omega_valid_tmp = omega_tmp(valid_tmp);
    branch_valid_tmp = branch_tmp(valid_tmp);

    i_star = i_valid_tmp(idxmaxlocal);
    omega_star_deg = omega_valid_tmp(idxmaxlocal)*180/pi;
    branch_star_num = branch_valid_tmp(idxmaxlocal);
    if branch_star_num == 1
        branch_star = 'concave';
    else
        branch_star = 'convex';
    end

    DG_c_end = interp1_unique(Gc.i, DGc_plot(:,sID), Gc_end.i);
    DG_v_start = interp1_unique(Gv.i, DGv_plot(:,sID), Gv_start.i);
    DG_trans_mean = mean([DG_c_end, DG_v_start]);
    DG_trans_jump = DG_v_start - DG_c_end;

    DG_at_Sgmax = interp1_unique(i_tmp(valid_tmp), DG_tmp(valid_tmp), i_Sg_max);
    DG_at_control = interp1_unique(i_tmp(valid_tmp), DG_tmp(valid_tmp), i_control_switch);
    DG_at_fail = interp1_unique(i_tmp(valid_tmp), DG_tmp(valid_tmp), i_pore_fail);

    extrema_c = find_local_extrema(Gc.i, DGc_plot(:,sID), [i_min_keep, i_max_keep]);
    extrema_v = find_local_extrema(Gv.i, DGv_plot(:,sID), [i_min_keep, i_max_keep]);

    fprintf('S = %.4f free-energy key values (%s):\n', S, free_energy_unit);
    fprintf('  Global maximum: i* = %.6f, omega = %.6f deg, DeltaG* = %.6f, branch = %s\n', i_star, omega_star_deg, DG_star, branch_star);
    fprintf('  Shape transition: i = %.6f, DeltaG_conc_end = %.6f, DeltaG_conv_start = %.6f, jump = %.6e\n', i_trans, DG_c_end, DG_v_start, DG_trans_jump);
    fprintf('  At Kelvin Sg maximum: i = %.6f, DeltaG = %.6f\n', i_Sg_max, DG_at_Sgmax);
    fprintf('  At Sp/S0 control switch: i = %.6f, DeltaG = %.6f\n', i_control_switch, DG_at_control);
    fprintf('  At pore failure Sg=Single: i = %.6f, DeltaG = %.6f\n', i_pore_fail, DG_at_fail);

    if ~isempty(extrema_c.i)
        fprintf('  Concave local extrema:\n');
        for kk = 1:numel(extrema_c.i)
            fprintf('    %s: i = %.6f, DeltaG = %.6f\n', extrema_c.type{kk}, extrema_c.i(kk), extrema_c.G(kk));
        end
    else
        fprintf('  Concave local extrema: none within range.\n');
    end

    if ~isempty(extrema_v.i)
        fprintf('  Convex local extrema:\n');
        for kk = 1:numel(extrema_v.i)
            fprintf('    %s: i = %.6f, DeltaG = %.6f\n', extrema_v.type{kk}, extrema_v.i(kk), extrema_v.G(kk));
        end
    else
        fprintf('  Convex local extrema: none within range.\n');
    end
    fprintf('\n');

    summary_rows(end+1,:) = {S, i_star, omega_star_deg, DG_star, branch_star, i_trans, DG_c_end, DG_v_start, DG_trans_jump, i_Sg_max, Sg_max, DG_at_Sgmax, i_control_switch, S_control_switch, DG_at_control, i_pore_fail, S_pore_fail, DG_at_fail};
end

%% =================== 6. Single-particle free-energy reference ===================

GsingleFE = cell(nS, 1);
if show_single_reference_in_free_energy
    for sID = 1:nS
        GsingleFE{sID} = single_particle_free_energy_reference(R_single_nm, theta_deg, T, gamma, rho_l, M, S_list(sID), tau_line, single_r_min_nm, single_r_max_nm, single_scan_N, i_min_keep, i_max_keep, free_energy_mode, free_energy_unit, relative_zero_mode);
    end
end

%% =================== 6b. Kelvin-derived key points mapped onto free-energy curves ===================

% These four points are calculated from the same Kelvin geometry and then
% mapped back to the dual-particle CNT free-energy curves.  Their i values
% do not depend on the ambient S used for the CNT curve, but their free
% energies do.  Therefore every S curve is marked at the same Kelvin-derived
% x locations and the corresponding DeltaG values are exported separately.
key_names = {'T'; 'Sgmax'; 'B'; 'F'};
key_plot_labels = {'T'; sprintf('S_{g,max}=%.2f', Sg_max); 'B'; 'F'};
key_descriptions = {'concave-to-convex transition'; ...
                    'maximum growth saturation ratio'; ...
                    'S_p = S_0 control switch'; ...
                    'pore failure: S_g = S_single'};
key_i = [i_trans; i_Sg_max; i_control_switch; i_pore_fail];
key_S_kelvin = [S_trans; Sg_max; S_control_switch; S_pore_fail];
key_omega_deg = [omega_trans_deg; omega_Sg_max_deg; omega_control_switch_deg; omega_pore_fail_deg];
key_markers = {'o'; '^'; 'd'; 'p'};
key_line_styles = {':'; '-.'; '--'; ':'};
key_valid = isfinite(key_i) & isfinite(key_S_kelvin) & key_i >= i_min_keep & key_i <= i_max_keep;
% Only show T and Sg,max on the exported free-energy figure.
% B and F are still calculated and exported to CSV, but their vertical guides,
% curve markers and text labels are hidden from the figure.
key_show_on_plot = strcmp(key_names, 'T') | strcmp(key_names, 'Sgmax');

AutoFeatureRows = {};

%% =================== 7. Plot free-energy curves: single and dual in one figure ===================

fig1 = figure('Color','w', 'Units','centimeters', 'Position',[2 2 fig_width_cm fig_height_cm]);
ax1 = axes('Parent', fig1, 'Position',axes_position);
hold(ax1,'on');
box(ax1,'on');

% Three saturation ratios are distinguished by color.
% Particle type is distinguished by line style:
%   dual-particle pore: solid line
%   single-particle reference: dashed line
if nS <= 3
    colors = [0.0000 0.4470 0.7410;
              0.8500 0.3250 0.0980;
              0.4660 0.6740 0.1880];
else
    colors = lines(nS);
end

legend_handles = [];
legend_text = {};

for sID = 1:nS
    this_color = colors(sID, :);
    S = S_list(sID);

    mask_c = isfinite(Gc.i) & isfinite(DGc_plot(:,sID)) & Gc.i >= i_min_keep & Gc.i <= i_max_keep;
    mask_v = isfinite(Gv.i) & isfinite(DGv_plot(:,sID)) & Gv.i >= i_min_keep & Gv.i <= i_max_keep;

    h_dual = plot(ax1, Gc.i(mask_c), DGc_plot(mask_c,sID), '-', ...
        'Color', this_color, 'LineWidth', line_width);
    plot(ax1, Gv.i(mask_v), DGv_plot(mask_v,sID), '-', ...
        'Color', this_color, 'LineWidth', line_width, 'HandleVisibility','off');

    legend_handles = [legend_handles, h_dual]; %#ok<AGROW>
    legend_text = [legend_text, {sprintf('Dual-particle pore, S = %.2f', S)}]; %#ok<AGROW>

    if show_single_reference_in_free_energy
        h_single = plot(ax1, GsingleFE{sID}.i, GsingleFE{sID}.DG_plot, '--', ...
            'Color', this_color, 'LineWidth', single_line_width);
        legend_handles = [legend_handles, h_single]; %#ok<AGROW>
        legend_text = [legend_text, {sprintf('Single particle, S = %.2f', S)}]; %#ok<AGROW>
    end
end

if strcmpi(free_energy_y_mode, 'manual')
    yl = y_lim_manual;
else
    yl = estimate_ylim_from_data(ax1);
end

xlim(ax1, x_lim_manual);
ylim(ax1, yl);

% A quiet zero reference line improves readability without competing with the data.
plot(ax1, x_lim_manual, [0 0], '-', 'Color',[0.72 0.72 0.72], 'LineWidth',0.90, 'HandleVisibility','off');

% Kelvin-derived vertical guides and key-point markers on every dual-particle curve.
yr = yl(2) - yl(1);
key_label_frac = [0.910 0.910 0.910 0.062];
for kID = 1:numel(key_i)
    if ~key_valid(kID) || ~key_show_on_plot(kID)
        continue;
    end

    if show_key_vertical_lines
        plot(ax1, [key_i(kID) key_i(kID)], yl, key_line_styles{kID}, ...
            'Color',[0.50 0.50 0.50], 'LineWidth',1.25, 'HandleVisibility','off');
    end

    if show_key_large_labels
        y_text = yl(1) + key_label_frac(min(kID,numel(key_label_frac)))*yr;
        label_now = sprintf('%s\n i = %.0f', key_plot_labels{kID}, key_i(kID));
        text(ax1, key_i(kID), y_text, label_now, ...
            'FontName',key_label_font_name, 'FontSize',key_label_font_size, ...
            'FontWeight',key_label_font_weight, 'Color',[0.12 0.12 0.12], ...
            'HorizontalAlignment','center', 'VerticalAlignment','middle', ...
            'BackgroundColor',key_label_background_color, 'EdgeColor',key_label_edge_color, ...
            'Margin',key_label_margin, 'Interpreter','tex');
    end
end

if show_key_markers_on_curves
for sID = 1:nS
    this_color = colors(sID, :);
    i_dual_fe = [Gc.i; Gv.i];
    DG_dual_fe = [DGc_plot(:,sID); DGv_plot(:,sID)];
    valid_dual_fe = isfinite(i_dual_fe) & isfinite(DG_dual_fe) & i_dual_fe >= i_min_keep & i_dual_fe <= i_max_keep;

    for kID = 1:numel(key_i)
        if ~key_valid(kID) || ~key_show_on_plot(kID)
            continue;
        end
        DG_key = interp1_unique(i_dual_fe(valid_dual_fe), DG_dual_fe(valid_dual_fe), key_i(kID));
        if isfinite(DG_key)
            plot(ax1, key_i(kID), DG_key, key_markers{kID}, ...
                'Color',this_color, 'MarkerFaceColor','w', ...
                'MarkerSize',marker_size, 'LineWidth',marker_line_width, ...
                'HandleVisibility','off');
        end
    end
end
end


%% Automatically mark local extrema on every visible curve segment.
if show_auto_curve_features
    label_points_near_curve = feature_label_points && strcmpi(feature_label_mode, 'near_curve');
    feature_y_range = yl;
    if ~feature_visible_y_only
        feature_y_range = [-Inf Inf];
    end

    for sID = 1:nS
        S = S_list(sID);

        if feature_mark_dual_curves
            features_c = detect_curve_features_logx(Gc.i, DGc_plot(:,sID), ...
                feature_detection_x_range, feature_y_range, feature_visible_y_only, ...
                feature_resample_N, feature_smooth_window, feature_edge_cut_frac, ...
                feature_derivative_tol_frac, feature_curvature_tol_frac, ...
                feature_min_log10_separation, feature_mark_extrema, feature_mark_inflections);

            AutoFeatureRows = plot_and_record_curve_features(ax1, features_c, AutoFeatureRows, ...
                'Dual-concave', S, free_energy_unit, yl, x_lim_manual, ...
                label_points_near_curve, feature_font_size, font_name, ...
                feature_bar_height_frac, feature_label_dx_frac, feature_label_dy_frac, ...
                feature_text_margin, feature_marker_size, feature_marker_line_width, feature_bar_line_width);

            features_v = detect_curve_features_logx(Gv.i, DGv_plot(:,sID), ...
                feature_detection_x_range, feature_y_range, feature_visible_y_only, ...
                feature_resample_N, feature_smooth_window, feature_edge_cut_frac, ...
                feature_derivative_tol_frac, feature_curvature_tol_frac, ...
                feature_min_log10_separation, feature_mark_extrema, feature_mark_inflections);

            AutoFeatureRows = plot_and_record_curve_features(ax1, features_v, AutoFeatureRows, ...
                'Dual-convex', S, free_energy_unit, yl, x_lim_manual, ...
                label_points_near_curve, feature_font_size, font_name, ...
                feature_bar_height_frac, feature_label_dx_frac, feature_label_dy_frac, ...
                feature_text_margin, feature_marker_size, feature_marker_line_width, feature_bar_line_width);

            features_T = detect_transition_junction_extremum(Gc.i, DGc_plot(:,sID), ...
                Gv.i, DGv_plot(:,sID), i_trans, feature_y_range, feature_visible_y_only, ...
                feature_derivative_tol_frac);

            AutoFeatureRows = plot_and_record_curve_features(ax1, features_T, AutoFeatureRows, ...
                'Dual-transition', S, free_energy_unit, yl, x_lim_manual, ...
                label_points_near_curve, feature_font_size, font_name, ...
                feature_bar_height_frac, feature_label_dx_frac, feature_label_dy_frac, ...
                feature_text_margin, feature_marker_size, feature_marker_line_width, feature_bar_line_width);
        end

        if show_single_reference_in_free_energy && feature_mark_single_curves
            features_s = detect_curve_features_logx(GsingleFE{sID}.i, GsingleFE{sID}.DG_plot, ...
                feature_detection_x_range, feature_y_range, feature_visible_y_only, ...
                feature_resample_N, feature_smooth_window, feature_edge_cut_frac, ...
                feature_derivative_tol_frac, feature_curvature_tol_frac, ...
                feature_min_log10_separation, feature_mark_extrema, feature_mark_inflections);

            AutoFeatureRows = plot_and_record_curve_features(ax1, features_s, AutoFeatureRows, ...
                'Single', S, free_energy_unit, yl, x_lim_manual, ...
                label_points_near_curve, feature_font_size, font_name, ...
                feature_bar_height_frac, feature_label_dx_frac, feature_label_dy_frac, ...
                feature_text_margin, feature_marker_size, feature_marker_line_width, feature_bar_line_width);
        end
    end
end

if show_auto_curve_features && feature_label_points && strcmpi(feature_label_mode, 'left_panel') && exist('AutoFeatureRows', 'var') && ~isempty(AutoFeatureRows)
    render_feature_text_panel(ax1, AutoFeatureRows, feature_panel_position, feature_panel_title, feature_panel_font_name, feature_panel_font_size, font_name, feature_panel_show_DeltaG, feature_panel_sort_by_S, feature_panel_layout, feature_panel_column_width);
end

set(ax1, 'XScale','log', ...
         'FontName',font_name, ...
         'FontSize',font_size_axis, ...
         'LineWidth',axis_line_width, ...
         'TickDir','in', ...
         'TickLength',[0.014 0.014], ...
         'XMinorTick','on', ...
         'YMinorTick','on', ...
         'Layer','top');

xlabel(ax1, 'Number of water molecules in embryo, i', ...
    'FontName',font_name, 'FontSize',font_size_label, 'Interpreter','tex');

if strcmpi(free_energy_mode, 'relative')
    ybase = 'Relative CNT free energy, \DeltaG_{rel}';
else
    ybase = 'Absolute CNT free energy, \DeltaG_{abs}';
end

if strcmpi(free_energy_unit, 'kBT')
    ylab = [ybase ' / k_B T'];
elseif strcmpi(free_energy_unit, 'eV')
    ylab = [ybase ' / eV'];
else
    ylab = [ybase ' / J'];
end

ylabel(ax1, ylab, 'FontName',font_name, 'FontSize',font_size_label, 'Interpreter','tex');

if show_title
    title(ax1, sprintf('CNT free-energy curves mapped to Kelvin key points, \\theta = %.1f^\\circ, T = %.2f K', theta_deg, T), ...
        'FontName',font_name, 'FontSize',font_size_title, 'FontWeight','normal', 'Interpreter','tex');
end

if show_grid
    grid(ax1,'on');
    set(ax1, 'GridColor',[0.86 0.86 0.86], 'GridAlpha',0.35, 'XMinorGrid','off', 'YMinorGrid','off');
else
    grid(ax1,'off');
end

lgd1 = legend(ax1, legend_handles, legend_text, 'Location','northwest');
set(lgd1, 'Box','off', 'FontName',font_name, 'FontSize',font_size_legend);

% Compact key-point box: these are Kelvin-curve coordinates.  The marked
% DeltaG values for each S are exported in the key-point CSV file.
key_lines = {};
for kID = 1:numel(key_i)
    if key_valid(kID) && key_show_on_plot(kID)
        key_lines{end+1} = sprintf('%s: i = %.0f, S_K = %.2f', key_plot_labels{kID}, key_i(kID), key_S_kelvin(kID)); %#ok<AGROW>
    end
end
key_text = sprintf('%s\n', key_lines{:});
if show_key_point_box
    text(ax1, key_point_box_position(1), key_point_box_position(2), ['Kelvin key points' char(10) key_text], ...
        'Units','normalized', ...
        'FontName',font_name, 'FontSize',font_size_text, ...
        'Color',[0.12 0.12 0.12], ...
        'HorizontalAlignment','left', 'VerticalAlignment','top', ...
        'BackgroundColor','w', 'EdgeColor',[0.84 0.84 0.84], ...
        'LineWidth',0.75, 'Margin',5, 'Interpreter','tex');
end



%% Local magnified inset for the low-free-energy minimum region.
% The inset is deliberately placed in the lower-left blank region of the
% main axes.  It is created after the main axes is finished and then moved
% to the top of the graphics stack, otherwise MATLAB may hide the inset
% behind the main axes and only leave tiny tick labels visible at the bottom.
if make_dual_zoom_inset
    zoom_xlim_now = zoom_xlim;
    zoom_ylim_now = zoom_ylim;

    if numel(zoom_xlim_now) ~= 2 || zoom_xlim_now(1) <= 0 || zoom_xlim_now(2) <= zoom_xlim_now(1)
        error('zoom_xlim must be [xmin xmax] with 0 < xmin < xmax.');
    end
    if numel(zoom_ylim_now) ~= 2 || zoom_ylim_now(2) <= zoom_ylim_now(1)
        error('zoom_ylim must be [ymin ymax] with ymin < ymax.');
    end

    if show_zoom_source_box
        plot(ax1, [zoom_xlim_now(1) zoom_xlim_now(2) zoom_xlim_now(2) zoom_xlim_now(1) zoom_xlim_now(1)], ...
                  [zoom_ylim_now(1) zoom_ylim_now(1) zoom_ylim_now(2) zoom_ylim_now(2) zoom_ylim_now(1)], '-', ...
            'Color', zoom_source_box_color, 'LineWidth', zoom_source_box_line_width, ...
            'HandleVisibility','off', 'Clipping','on');
    end

    axz = axes('Parent', fig1, 'Position', zoom_inset_position);
    hold(axz,'on');
    box(axz,'on');
    set(axz, 'Color','w');

    for sID = 1:nS
        this_color = colors(sID, :);

        mask_cz = isfinite(Gc.i) & isfinite(DGc_plot(:,sID)) & Gc.i >= zoom_xlim_now(1) & Gc.i <= zoom_xlim_now(2);
        mask_vz = isfinite(Gv.i) & isfinite(DGv_plot(:,sID)) & Gv.i >= zoom_xlim_now(1) & Gv.i <= zoom_xlim_now(2);

        plot(axz, Gc.i(mask_cz), DGc_plot(mask_cz,sID), '-', ...
            'Color', this_color, 'LineWidth', zoom_inset_line_width, 'HandleVisibility','off');
        plot(axz, Gv.i(mask_vz), DGv_plot(mask_vz,sID), '-', ...
            'Color', this_color, 'LineWidth', zoom_inset_line_width, 'HandleVisibility','off');

        if show_single_reference_in_free_energy
            mask_sz = isfinite(GsingleFE{sID}.i) & isfinite(GsingleFE{sID}.DG_plot) & ...
                GsingleFE{sID}.i >= zoom_xlim_now(1) & GsingleFE{sID}.i <= zoom_xlim_now(2);
            plot(axz, GsingleFE{sID}.i(mask_sz), GsingleFE{sID}.DG_plot(mask_sz), '--', ...
                'Color', this_color, 'LineWidth', zoom_inset_single_line_width, 'HandleVisibility','off');
        end
    end

    plot(axz, zoom_xlim_now, [0 0], '-', 'Color',[0.72 0.72 0.72], ...
        'LineWidth',0.70, 'HandleVisibility','off');

    if show_key_vertical_lines
        for kID = 1:numel(key_i)
            if key_valid(kID) && key_show_on_plot(kID) && key_i(kID) >= zoom_xlim_now(1) && key_i(kID) <= zoom_xlim_now(2)
                plot(axz, [key_i(kID) key_i(kID)], zoom_ylim_now, key_line_styles{kID}, ...
                    'Color',[0.52 0.52 0.52], 'LineWidth',0.85, 'HandleVisibility','off');
            end
        end
    end

    if show_key_markers_on_curves
        for sID = 1:nS
            this_color = colors(sID, :);
            i_dual_fe = [Gc.i; Gv.i];
            DG_dual_fe = [DGc_plot(:,sID); DGv_plot(:,sID)];
            valid_dual_fe = isfinite(i_dual_fe) & isfinite(DG_dual_fe) & ...
                i_dual_fe >= i_min_keep & i_dual_fe <= i_max_keep;

            for kID = 1:numel(key_i)
                if ~key_valid(kID) || ~key_show_on_plot(kID) || key_i(kID) < zoom_xlim_now(1) || key_i(kID) > zoom_xlim_now(2)
                    continue;
                end
                DG_key = interp1_unique(i_dual_fe(valid_dual_fe), DG_dual_fe(valid_dual_fe), key_i(kID));
                if isfinite(DG_key) && DG_key >= zoom_ylim_now(1) && DG_key <= zoom_ylim_now(2)
                    plot(axz, key_i(kID), DG_key, key_markers{kID}, ...
                        'Color',this_color, 'MarkerFaceColor','w', ...
                        'MarkerSize',zoom_inset_marker_size, 'LineWidth',zoom_inset_marker_line_width, ...
                        'HandleVisibility','off');
                end
            end
        end
    end

    if exist('AutoFeatureRows','var') && ~isempty(AutoFeatureRows)
        for rr = 1:size(AutoFeatureRows,1)
            feature_kind_now = AutoFeatureRows{rr,3};
            if strcmpi(feature_kind_now, 'inflection')
                continue;
            end
            x0 = AutoFeatureRows{rr,4};
            y0 = AutoFeatureRows{rr,5};
            if isfinite(x0) && isfinite(y0) && x0 >= zoom_xlim_now(1) && x0 <= zoom_xlim_now(2) && y0 >= zoom_ylim_now(1) && y0 <= zoom_ylim_now(2)
                plot(axz, x0, y0, 'ko', ...
                    'MarkerFaceColor','k', 'MarkerSize',zoom_inset_marker_size, ...
                    'LineWidth',zoom_inset_marker_line_width, 'HandleVisibility','off');
            end
        end
    end

    set(axz, 'XScale','log', ...
             'XLim',zoom_xlim_now, ...
             'YLim',zoom_ylim_now, ...
             'FontName',font_name, ...
             'FontSize',zoom_inset_font_size, ...
             'LineWidth',zoom_inset_axis_line_width, ...
             'TickDir','in', ...
             'TickLength',[0.018 0.018], ...
             'XMinorTick','on', ...
             'YMinorTick','on', ...
             'Layer','top', ...
             'XTick',[100 200 300 500], ...
             'YTick',[-120 -80 -40 0 20]);

    % Do not add x/y labels inside the inset; labels protrude downward and
    % make the inset look like tiny, hidden tick marks near the main x-axis.
    text(axz, 0.040, 0.900, 'Zoomed minima', ...
        'Units','normalized', 'FontName',font_name, 'FontSize',zoom_inset_font_size, ...
        'Color',[0.12 0.12 0.12], 'HorizontalAlignment','left', ...
        'VerticalAlignment','top', 'BackgroundColor','w', 'EdgeColor','none', ...
        'Margin',0.5, 'Interpreter','tex');

    % Keep the inset above the main axes.  Do not call axes(ax1) after this,
    % because that would bring the main axes to the front and hide the inset.
    uistack(axz, 'top');
end

% Make the export stable and crisp.
set(fig1, 'InvertHardcopy','off', 'PaperPositionMode','auto', 'Renderer','painters');

%% =================== 8. Plot Kelvin check figure from the SAME geometry ===================

if show_kelvin_check_figure
    fig2 = figure('Color','w', 'Units','centimeters', 'Position',[2 2 22 14]);
    ax2 = axes('Parent', fig2);
    hold(ax2,'on'); box(ax2,'on');

    p1 = plot(ax2, Gdual.i, Gdual.Sp, '-', 'Color',[0.00 0.4470 0.7410], 'LineWidth',2.6);
    p2 = plot(ax2, Gdual.i, Gdual.S0, '--', 'Color',[0.8500 0.3250 0.0980], 'LineWidth',2.4);
    p3 = plot(ax2, Gdual.i, Sg_dual, '-', 'Color',[0 0 0], 'LineWidth',2.0);
    p4 = plot(ax2, GsingleK.i, GsingleK.S, '--', 'Color',[0.25 0.65 0.25], 'LineWidth',2.4);

    for sID = 1:nS
        plot(ax2, x_lim_manual, [S_list(sID) S_list(sID)], ':', 'Color', colors(sID,:), 'LineWidth',1.8, 'HandleVisibility','off');
        text(ax2, x_lim_manual(1)*1.2, S_list(sID)*1.005, sprintf('S=%.2f',S_list(sID)), 'FontName',font_name, 'FontSize',font_size_text, 'Color',colors(sID,:), 'FontWeight','bold');
    end

    plot(ax2, i_trans, S_trans, 'ko', 'MarkerFaceColor','w', 'MarkerSize',marker_size, 'LineWidth',marker_line_width, 'HandleVisibility','off');
    plot(ax2, i_Sg_max, Sg_max, 'ks', 'MarkerFaceColor','w', 'MarkerSize',marker_size, 'LineWidth',marker_line_width, 'HandleVisibility','off');
    % B and F are intentionally hidden from the Kelvin-check figure as well.
    % plot(ax2, i_control_switch, S_control_switch, 'kd', 'MarkerFaceColor','w', 'MarkerSize',marker_size, 'LineWidth',marker_line_width, 'HandleVisibility','off');
    % plot(ax2, i_pore_fail, S_pore_fail, 'kp', 'MarkerFaceColor','w', 'MarkerSize',marker_size+1, 'LineWidth',marker_line_width, 'HandleVisibility','off');

    set(ax2, 'XScale','log', 'FontName',font_name, 'FontSize',font_size_axis, 'LineWidth',axis_line_width, 'TickDir','in', 'TickLength',[0.018 0.018], 'XMinorTick','on', 'YMinorTick','on');
    xlim(ax2, x_lim_manual);

    y_all = [Gdual.Sp; Gdual.S0; Sg_dual; GsingleK.S; S_list(:)];
    y_all = y_all(isfinite(y_all) & y_all > 0);
    ylim(ax2, [max(0.0, min(y_all)*0.95), max(y_all)*1.06]);

    xlabel(ax2, 'Number of water molecules in embryo, i', 'FontName',font_name, 'FontSize',font_size_label, 'Interpreter','tex');
    ylabel(ax2, 'Equilibrium saturation ratio', 'FontName',font_name, 'FontSize',font_size_label, 'Interpreter','tex');
    title(ax2, 'Kelvin check calculated from the same i(\omega) mapping', 'FontName',font_name, 'FontSize',font_size_title, 'FontWeight','normal');

    lgd2 = legend(ax2, [p1 p2 p3 p4], {'Dual: contact point p', 'Dual: neck axis x=0', 'S_g=max(S_p,S_0)', sprintf('Single ref., R=%.3g nm', R_single_nm)}, 'Location','best');
    set(lgd2, 'Box','off', 'FontName',font_name, 'FontSize',font_size_legend);

    if show_grid
        grid(ax2,'on');
    end
end

%% =================== 9. Export data ===================

if save_csv
    branch_cell = cell(numel(Gdual.branch),1);
    for k = 1:numel(branch_cell)
        if Gdual.branch(k) == 1
            branch_cell{k} = 'concave';
        else
            branch_cell{k} = 'convex';
        end
    end

    Tdual = table(Gdual.i, Gdual.omega*180/pi, Gdual.V*1e27, Gdual.Avc, Gdual.Asl, Gdual.L, Gdual.Sp, Gdual.S0, Sg_dual, branch_cell, 'VariableNames', {'i','omega_deg','V_nm3','A_vc_m2','A_sl_m2','L_m','S_p','S_0','S_g','branch'});

    for sID = 1:nS
        S = S_list(sID);
        i_tmp = [Gc.i; Gv.i];
        DG_tmp = [DGc_plot(:,sID); DGv_plot(:,sID)];
        valid_tmp = isfinite(i_tmp) & isfinite(DG_tmp);
        DG_on_Gdual = interp1_unique(i_tmp(valid_tmp), DG_tmp(valid_tmp), Gdual.i);
        Tdual.(make_safe_varname(sprintf('DeltaG_%s_S_%g', free_energy_unit, S))) = DG_on_Gdual;
    end

    writetable(Tdual, fullfile(output_dir, [output_prefix '_dual_data.csv']));

    TsingleK = table(GsingleK.i, GsingleK.S, 'VariableNames', {'i','S_single'});
    writetable(TsingleK, fullfile(output_dir, [output_prefix '_single_kelvin.csv']));

    if show_single_reference_in_free_energy
        i_single_common = GsingleFE{1}.i;
        TsingleFE = table(i_single_common, 'VariableNames', {'i'});
        for sID = 1:nS
            S = S_list(sID);
            DG_single_on_common = interp1_unique(GsingleFE{sID}.i, GsingleFE{sID}.DG_plot, i_single_common);
            TsingleFE.(make_safe_varname(sprintf('DeltaG_%s_single_S_%g', free_energy_unit, S))) = DG_single_on_common;
        end
        writetable(TsingleFE, fullfile(output_dir, [output_prefix '_single_free_energy.csv']));
    end

    Summary = cell2table(summary_rows, 'VariableNames', {'S','i_star','omega_star_deg','DeltaG_star','branch_star','i_transition','DeltaG_concave_end','DeltaG_convex_start','DeltaG_transition_jump','i_Sg_max','Sg_max','DeltaG_at_Sg_max','i_control_switch','S_control_switch','DeltaG_at_control_switch','i_pore_failure','S_pore_failure','DeltaG_at_pore_failure'});
    writetable(Summary, fullfile(output_dir, [output_prefix '_summary.csv']));

    KeyKelvin = table(i_trans, S_trans, omega_trans_deg, i_Sg_max, Sg_max, omega_Sg_max_deg, i_control_switch, S_control_switch, omega_control_switch_deg, i_pore_fail, S_pore_fail, omega_pore_fail_deg, 'VariableNames', {'i_transition','S_transition','omega_transition_deg','i_Sg_max','Sg_max','omega_Sg_max_deg','i_control_switch','S_control_switch','omega_control_switch_deg','i_pore_failure','S_pore_failure','omega_pore_failure_deg'});
    writetable(KeyKelvin, fullfile(output_dir, [output_prefix '_kelvin_key_points.csv']));


    KeyFreeEnergyRows = {};
    for sID = 1:nS
        S = S_list(sID);
        i_dual_fe = [Gc.i; Gv.i];
        DG_dual_fe = [DGc_plot(:,sID); DGv_plot(:,sID)];
        valid_dual_fe = isfinite(i_dual_fe) & isfinite(DG_dual_fe) & i_dual_fe >= i_min_keep & i_dual_fe <= i_max_keep;
        for kID = 1:numel(key_i)
            DG_key = interp1_unique(i_dual_fe(valid_dual_fe), DG_dual_fe(valid_dual_fe), key_i(kID));
            KeyFreeEnergyRows(end+1,:) = {S, key_names{kID}, key_descriptions{kID}, key_i(kID), key_S_kelvin(kID), key_omega_deg(kID), DG_key, free_energy_unit}; %#ok<AGROW>
        end
    end
    KeyFreeEnergy = cell2table(KeyFreeEnergyRows, 'VariableNames', {'S_env','Key_point','Meaning','i','S_Kelvin','omega_deg','DeltaG_on_dual_curve','Energy_unit'});
    writetable(KeyFreeEnergy, fullfile(output_dir, [output_prefix '_free_energy_key_points.csv']));

    if exist('AutoFeatureRows','var') && ~isempty(AutoFeatureRows)
        AutoFeatures = cell2table(AutoFeatureRows, 'VariableNames', {'S_env','Curve','Feature_type','i','DeltaG','Energy_unit','Marker','Detection_basis'});
        writetable(AutoFeatures, fullfile(output_dir, [output_prefix '_auto_curve_features.csv']));
    end


    fprintf('CSV exported:\n');
    fprintf('  %s\n', [output_prefix '_dual_data.csv']);
    fprintf('  %s\n', [output_prefix '_single_kelvin.csv']);
    if show_single_reference_in_free_energy
        fprintf('  %s\n', [output_prefix '_single_free_energy.csv']);
    end
    fprintf('  %s\n', [output_prefix '_summary.csv']);
    fprintf('  %s\n', [output_prefix '_kelvin_key_points.csv']);
    fprintf('  %s\n', [output_prefix '_free_energy_key_points.csv']);
    if exist('AutoFeatureRows','var') && ~isempty(AutoFeatureRows)
        fprintf('  %s\n', [output_prefix '_auto_curve_features.csv']);
    end
end

%% =================== 10. Save figures ===================

set(fig1, 'InvertHardcopy','off', 'PaperPositionMode','manual');
set(fig1, 'PaperUnits','centimeters');
set(fig1, 'PaperPosition',[0 0 fig_width_cm fig_height_cm]);
set(fig1, 'PaperSize',[fig_width_cm fig_height_cm]);
drawnow;

if save_png
    png_file = fullfile(output_dir, [output_prefix '_free_energy_600dpi.png']);
    print(fig1, png_file, '-dpng', ['-r' num2str(png_dpi)]);
    if exist(png_file, 'file') == 2
        fprintf('600 dpi PNG exported successfully:\n  %s\n', png_file);
        if open_png_after_export
            if ispc
                winopen(png_file);
            else
                open(png_file);
            end
        end
    else
        warning('PNG export failed. Please check the output folder permission.');
    end
end
if save_tif
    tif_file = fullfile(output_dir, [output_prefix '_free_energy_600dpi.tif']);
    print(fig1, tif_file, '-dtiff', ['-r' num2str(tif_dpi)]);
end
if save_eps
    eps_file = fullfile(output_dir, [output_prefix '_free_energy.eps']);
    print(fig1, eps_file, '-depsc', '-painters');
end
if save_pdf
    pdf_file = fullfile(output_dir, [output_prefix '_free_energy.pdf']);
    print(fig1, pdf_file, '-dpdf', '-painters');
end

if show_kelvin_check_figure
    set(fig2, 'InvertHardcopy','off', 'PaperPositionMode','auto', 'Renderer','painters');
    if save_png
        print(fig2, fullfile(output_dir, [output_prefix '_kelvin_check_600dpi.png']), '-dpng', ['-r' num2str(png_dpi)]);
    end
    if save_tif
        print(fig2, fullfile(output_dir, [output_prefix '_kelvin_check_600dpi.tif']), '-dtiff', ['-r' num2str(tif_dpi)]);
    end
    if save_eps
        print(fig2, fullfile(output_dir, [output_prefix '_kelvin_check.eps']), '-depsc', '-painters');
    end
    if save_pdf
        print(fig2, fullfile(output_dir, [output_prefix '_kelvin_check.pdf']), '-dpdf', '-painters');
    end
end

fprintf('\nFinished.\n');

%% =================== Local functions ===================

function G = dual_pore_geometry_kelvin(omega, R, theta, gamma, Vm, Rg, T, v0, branchType)
    n = numel(omega);

    i_num  = nan(n,1);
    V_tot  = nan(n,1);
    A_vc   = nan(n,1);
    A_sl   = nan(n,1);
    L_line = nan(n,1);
    S_p    = nan(n,1);
    S_0    = nan(n,1);
    branch = nan(n,1);

    alpha = theta + omega;

    for k = 1:n
        w = omega(k);
        a = alpha(k);

        if ~(isfinite(w) && isfinite(a) && w > 0 && w < pi)
            continue;
        end

        lnS_p = gamma*Vm/(Rg*T) * ( sin(a)/(R*sin(w)) - cos(a)/(R*(1-cos(w))) );
        r_az_0 = R*sin(w) - R*(1-cos(w))*(1-sin(a))/cos(a);
        lnS_0 = gamma*Vm/(Rg*T) * ( 1/r_az_0 - cos(a)/(R*(1-cos(w))) );

        L_line(k) = 4*pi*R*sin(w);
        A_sl(k) = 4*pi*R^2*(1 - cos(w));
        V_cap = (pi/3)*R^3*(1 - cos(w))^2*(2 + cos(w));

        switch lower(branchType)
            case 'concave'
                if a >= pi/2
                    continue;
                end
                r_m = R*(1 - cos(w))/cos(a);
                y0  = R*sin(w) + R*(1 - cos(w))*tan(a);
                phi = pi/2 - a;

                A_vc(k) = 4*pi*r_m*(y0*phi - r_m*sin(phi));

                V_rot = 2*pi*r_m*(y0^2*sin(phi) + r_m^2*sin(phi) - (r_m^2/3)*sin(phi)^3 - y0*r_m*(phi + sin(phi)*cos(phi)));

                branch(k) = 1;

            case 'convex'
                if a <= pi/2
                    continue;
                end
                r_m = -R*(1 - cos(w))/cos(a);
                y0  = R*sin(w) + R*(1 - cos(w))*tan(a);
                phi = a - pi/2;

                A_vc(k) = 4*pi*r_m*(y0*phi + r_m*sin(phi));

                V_rot = 2*pi*r_m*(y0^2*sin(phi) + r_m^2*sin(phi) - (r_m^2/3)*sin(phi)^3 + y0*r_m*(phi + sin(phi)*cos(phi)));

                branch(k) = 2;

            otherwise
                error('Unknown branchType.');
        end

        V_tot(k) = V_rot - 2*V_cap;
        i_num(k) = V_tot(k)/v0;
        S_p(k) = exp(lnS_p);
        S_0(k) = exp(lnS_0);
    end

    valid = isfinite(i_num) & isfinite(V_tot) & isfinite(A_vc) & isfinite(A_sl) & isfinite(L_line) & isfinite(S_p) & isfinite(S_0) & isfinite(branch) & i_num > 0 & V_tot > 0 & A_vc > 0 & A_sl > 0 & L_line > 0 & S_p > 0 & S_0 > 0;

    G.i = i_num(valid);
    G.omega = omega(valid);
    G.V = V_tot(valid);
    G.Avc = A_vc(valid);
    G.Asl = A_sl(valid);
    G.L = L_line(valid);
    G.Sp = S_p(valid);
    G.S0 = S_0(valid);
    G.branch = branch(valid);

    [G.i, ord] = sort(G.i);
    G.omega = G.omega(ord);
    G.V = G.V(ord);
    G.Avc = G.Avc(ord);
    G.Asl = G.Asl(ord);
    G.L = G.L(ord);
    G.Sp = G.Sp(ord);
    G.S0 = G.S0(ord);
    G.branch = G.branch(ord);

    [G.i, ia] = unique(G.i);
    G.omega = G.omega(ia);
    G.V = G.V(ia);
    G.Avc = G.Avc(ia);
    G.Asl = G.Asl(ia);
    G.L = G.L(ia);
    G.Sp = G.Sp(ia);
    G.S0 = G.S0(ia);
    G.branch = G.branch(ia);
end

function G = merge_geometry(Gc, Gv, i_min_keep, i_max_keep)
    G.i = [Gc.i; Gv.i];
    G.omega = [Gc.omega; Gv.omega];
    G.V = [Gc.V; Gv.V];
    G.Avc = [Gc.Avc; Gv.Avc];
    G.Asl = [Gc.Asl; Gv.Asl];
    G.L = [Gc.L; Gv.L];
    G.Sp = [Gc.Sp; Gv.Sp];
    G.S0 = [Gc.S0; Gv.S0];
    G.branch = [Gc.branch; Gv.branch];

    valid = isfinite(G.i) & isfinite(G.omega) & isfinite(G.V) & isfinite(G.Avc) & isfinite(G.Asl) & isfinite(G.L) & isfinite(G.Sp) & isfinite(G.S0) & isfinite(G.branch) & G.i >= i_min_keep & G.i <= i_max_keep;

    fields = fieldnames(G);
    for f = 1:numel(fields)
        G.(fields{f}) = G.(fields{f})(valid);
    end

    [G.i, ord] = sort(G.i);
    fields = fieldnames(G);
    for f = 1:numel(fields)
        if ~strcmp(fields{f}, 'i')
            G.(fields{f}) = G.(fields{f})(ord);
        end
    end

    [G.i, ia] = unique(G.i);
    fields = fieldnames(G);
    for f = 1:numel(fields)
        if ~strcmp(fields{f}, 'i')
            G.(fields{f}) = G.(fields{f})(ia);
        end
    end
end

function item = take_last_valid(G)
    idx = find(isfinite(G.i) & isfinite(G.Sp) & isfinite(G.S0), 1, 'last');
    if isempty(idx)
        error('No valid endpoint in concave branch.');
    end
    item.i = G.i(idx);
    item.omega = G.omega(idx);
    item.Sp = G.Sp(idx);
    item.S0 = G.S0(idx);
end

function item = take_first_valid(G)
    idx = find(isfinite(G.i) & isfinite(G.Sp) & isfinite(G.S0), 1, 'first');
    if isempty(idx)
        error('No valid endpoint in convex branch.');
    end
    item.i = G.i(idx);
    item.omega = G.omega(idx);
    item.Sp = G.Sp(idx);
    item.S0 = G.S0(idx);
end

function DG = cnt_free_energy(i, A_vc, A_sl, L, theta, T, gamma, tau_line, S)
    kB = 1.380649e-23;
    DG = -i .* kB .* T .* log(S) + gamma .* (A_vc - cos(theta).*A_sl) + tau_line .* L;
end

function Eout = convert_energy_unit(E_J, T, unitName)
    kB = 1.380649e-23;
    eV = 1.602176634e-19;
    if strcmpi(unitName, 'kBT')
        Eout = E_J ./ (kB*T);
    elseif strcmpi(unitName, 'eV')
        Eout = E_J ./ eV;
    elseif strcmpi(unitName, 'J')
        Eout = E_J;
    else
        error('Unknown energy unit.');
    end
end

function Gsingle = single_particle_kelvin_reference(R_single_nm, theta_deg, T, gamma, rho_l, M, Rg, NA, r_min_nm, r_max_nm, scanN, i_min_keep, i_max_keep)
    R = R_single_nm*1e-9;
    theta = deg2rad(theta_deg);
    Vm = M/rho_l;
    v0 = Vm/NA;

    r_scan = logspace(log10(r_min_nm*1e-9), log10(r_max_nm*1e-9), scanN).';

    i_all = nan(size(r_scan));
    S_all = nan(size(r_scan));

    for k = 1:numel(r_scan)
        r = r_scan(k);
        d = sqrt(R^2 + r^2 - 2*r*R*cos(theta));
        if ~isfinite(d) || d <= 0
            continue;
        end

        cos_phi = (R*cos(theta) - r)/d;
        cos_Phi = (R - r*cos(theta))/d;
        cos_phi = max(-1, min(1, cos_phi));
        cos_Phi = max(-1, min(1, cos_Phi));

        V_cap_vapor = (pi/3)*r^3*(2 - 3*cos_phi + cos_phi^3);
        V_cap_solid = (pi/3)*R^3*(2 - 3*cos_Phi + cos_Phi^3);
        V_droplet = V_cap_vapor - V_cap_solid;

        if ~isfinite(V_droplet) || V_droplet <= 0
            continue;
        end

        i_all(k) = V_droplet/v0;
        S_all(k) = exp(2*gamma*Vm/(Rg*T*r));
    end

    valid = isfinite(i_all) & isfinite(S_all) & i_all > 0 & S_all > 0;
    i_all = i_all(valid);
    S_all = S_all(valid);

    [i_all, ord] = sort(i_all);
    S_all = S_all(ord);

    [i_all, ia] = unique(i_all);
    S_all = S_all(ia);

    mask = i_all >= i_min_keep & i_all <= i_max_keep;

    Gsingle.i = i_all(mask);
    Gsingle.S = S_all(mask);
end

function singleData = single_particle_free_energy_reference(R_single_nm, theta_deg, T, gamma, rho_l, M, S, tau_line, r_min_nm, r_max_nm, scanN, i_min_keep, i_max_keep, free_energy_mode, free_energy_unit, relative_zero_mode)
    kB = 1.380649e-23;
    NA = 6.02214076e23;

    R = R_single_nm*1e-9;
    theta = deg2rad(theta_deg);
    Vm = M/rho_l;
    v0 = Vm/NA;

    r_scan = logspace(log10(r_min_nm*1e-9), log10(r_max_nm*1e-9), scanN).';

    i_all = nan(size(r_scan));
    V_all = nan(size(r_scan));
    DG_abs = nan(size(r_scan));

    for k = 1:numel(r_scan)
        r = r_scan(k);
        d = sqrt(R^2 + r^2 - 2*r*R*cos(theta));
        if ~isfinite(d) || d <= 0
            continue;
        end

        cos_phi = (R*cos(theta) - r)/d;
        cos_Phi = (R - r*cos(theta))/d;
        cos_phi = max(-1, min(1, cos_phi));
        cos_Phi = max(-1, min(1, cos_Phi));
        sin_phi = sqrt(max(0, 1 - cos_phi^2));

        A_vc = 2*pi*r^2*(1 - cos_phi);
        A_sl = pi*(r*sin_phi)^2;
        L = 2*pi*r*sin_phi;

        V_cap_v = (pi/3)*r^3*(2 - 3*cos_phi + cos_phi^3);
        V_cap_s = (pi/3)*R^3*(2 - 3*cos_Phi + cos_Phi^3);
        V_drop = V_cap_v - V_cap_s;

        if ~isfinite(V_drop) || V_drop <= 0 || A_vc <= 0 || A_sl <= 0 || L <= 0
            continue;
        end

        i_all(k) = V_drop/v0;
        V_all(k) = V_drop;
        DG_abs(k) = -i_all(k)*kB*T*log(S) + gamma*(A_vc - cos(theta)*A_sl) + tau_line*L;
    end

    valid = isfinite(i_all) & isfinite(V_all) & isfinite(DG_abs) & i_all > 0 & V_all > 0;
    i_all = i_all(valid);
    V_all = V_all(valid);
    DG_abs = DG_abs(valid);

    [i_all, ord] = sort(i_all);
    V_all = V_all(ord);
    DG_abs = DG_abs(ord);

    [i_all, ia] = unique(i_all);
    V_all = V_all(ia);
    DG_abs = DG_abs(ia);

    mask = i_all >= i_min_keep & i_all <= i_max_keep;
    iP = i_all(mask);
    VP = V_all(mask);
    DGJ = DG_abs(mask);

    DG_unit = convert_energy_unit(DGJ, T, free_energy_unit);
    if strcmpi(free_energy_mode, 'absolute')
        DG_plot = DG_unit;
    elseif strcmpi(free_energy_mode, 'relative')
        if strcmpi(relative_zero_mode, 'first')
            DG_plot = DG_unit - DG_unit(1);
        elseif strcmpi(relative_zero_mode, 'min')
            DG_plot = DG_unit - min(DG_unit);
        else
            error('Unknown relative_zero_mode.');
        end
    else
        error('Unknown free_energy_mode.');
    end

    singleData.i = iP;
    singleData.V = VP;
    singleData.DG_abs_J = DGJ;
    singleData.DG_plot = DG_plot;
end

function [x_int, y_int] = find_intersection(x1, y1, x2, y2, x_range)
    [x_all, y_all] = find_all_intersections(x1, y1, x2, y2, x_range);
    if isempty(x_all)
        x_int = NaN;
        y_int = NaN;
    else
        x_int = x_all(1);
        y_int = y_all(1);
    end
end

function [x_int, y_int] = find_all_intersections(x1, y1, x2, y2, x_range)
    x1 = x1(:); y1 = y1(:); x2 = x2(:); y2 = y2(:);

    valid1 = isfinite(x1) & isfinite(y1);
    valid2 = isfinite(x2) & isfinite(y2);
    x1 = x1(valid1); y1 = y1(valid1);
    x2 = x2(valid2); y2 = y2(valid2);

    [x1, ord1] = sort(x1); y1 = y1(ord1);
    [x2, ord2] = sort(x2); y2 = y2(ord2);

    [x1, ia1] = unique(x1); y1 = y1(ia1);
    [x2, ia2] = unique(x2); y2 = y2(ia2);

    mask = x1 >= x_range(1) & x1 <= x_range(2);
    x_sub = x1(mask);
    y1_sub = y1(mask);
    y2_sub = interp1(x2, y2, x_sub, 'linear', NaN);

    valid = isfinite(x_sub) & isfinite(y1_sub) & isfinite(y2_sub);
    x_sub = x_sub(valid);
    y1_sub = y1_sub(valid);
    y2_sub = y2_sub(valid);

    if numel(x_sub) < 2
        x_int = [];
        y_int = [];
        return;
    end

    diff_y = y1_sub - y2_sub;
    idx = find(diff_y(1:end-1).*diff_y(2:end) <= 0);

    x_int = [];
    y_int = [];

    for n = 1:numel(idx)
        k = idx(n);
        x_a = x_sub(k); x_b = x_sub(k+1);
        d_a = diff_y(k); d_b = diff_y(k+1);

        if ~isfinite(d_a) || ~isfinite(d_b)
            continue;
        end

        if d_a == d_b
            x_cross = x_a;
        else
            x_cross = x_a - d_a*(x_b-x_a)/(d_b-d_a);
        end

        if x_cross >= x_range(1) && x_cross <= x_range(2)
            y_cross = interp1(x_sub, y1_sub, x_cross, 'linear');
            x_int = [x_int; x_cross]; %#ok<AGROW>
            y_int = [y_int; y_cross]; %#ok<AGROW>
        end
    end

    if ~isempty(x_int)
        [x_int, ord] = sort(x_int);
        y_int = y_int(ord);
    end
end

function yq = interp1_unique(x, y, xq)
    xq_size = size(xq);
    xq_vec = xq(:);
    yq_vec = nan(size(xq_vec));

    x = x(:);
    y = y(:);
    valid = isfinite(x) & isfinite(y);
    x = x(valid);
    y = y(valid);

    if numel(x) < 2
        yq = reshape(yq_vec, xq_size);
        return;
    end

    [x, ord] = sort(x);
    y = y(ord);
    [x, ia] = unique(x);
    y = y(ia);

    if numel(x) < 2
        yq = reshape(yq_vec, xq_size);
        return;
    end

    valid_q = isfinite(xq_vec) & xq_vec >= min(x) & xq_vec <= max(x);
    if any(valid_q)
        yq_vec(valid_q) = interp1(x, y, xq_vec(valid_q), 'linear');
    end

    yq = reshape(yq_vec, xq_size);
end

function extrema = find_local_extrema(x, G, x_range)
    x = x(:);
    G = G(:);
    valid = isfinite(x) & isfinite(G) & x >= x_range(1) & x <= x_range(2);
    x = x(valid);
    G = G(valid);

    extrema.i = [];
    extrema.G = [];
    extrema.type = {};

    if numel(x) < 5
        return;
    end

    [x, ord] = sort(x);
    G = G(ord);
    [x, ia] = unique(x);
    G = G(ia);

    dG = diff(G)./diff(x);
    scale = max(abs(dG));
    if ~isfinite(scale) || scale == 0
        return;
    end
    tol = 1e-8*scale;
    dG(abs(dG) < tol) = 0;

    for k = 1:numel(dG)-1
        if dG(k) > 0 && dG(k+1) < 0
            idx = k+1;
            extrema.i(end+1,1) = x(idx); %#ok<AGROW>
            extrema.G(end+1,1) = G(idx); %#ok<AGROW>
            extrema.type{end+1,1} = 'maximum'; %#ok<AGROW>
        elseif dG(k) < 0 && dG(k+1) > 0
            idx = k+1;
            extrema.i(end+1,1) = x(idx); %#ok<AGROW>
            extrema.G(end+1,1) = G(idx); %#ok<AGROW>
            extrema.type{end+1,1} = 'minimum'; %#ok<AGROW>
        end
    end
end

function yl = estimate_ylim_from_data(ax)
    ch = get(ax, 'Children');
    ymin = Inf;
    ymax = -Inf;
    for k = 1:numel(ch)
        if isprop(ch(k), 'YData')
            yd = get(ch(k), 'YData');
            yd = yd(isfinite(yd));
            if ~isempty(yd)
                ymin = min(ymin, min(yd));
                ymax = max(ymax, max(yd));
            end
        end
    end
    if ~isfinite(ymin) || ~isfinite(ymax) || ymin == ymax
        yl = [-1 1];
    else
        dy = ymax - ymin;
        yl = [ymin - 0.10*dy, ymax + 0.18*dy];
    end
end



function features = detect_transition_junction_extremum(xc, Gc, xv, Gv, i_trans, y_range, visible_only, derivative_tol_frac)
    features = empty_curve_features();

    if ~isfinite(i_trans) || i_trans <= 0
        return;
    end

    x_all = [xc(:); xv(:)];
    G_all = [Gc(:); Gv(:)];
    valid = isfinite(x_all) & isfinite(G_all) & x_all > 0;
    x_all = x_all(valid);
    G_all = G_all(valid);

    if numel(x_all) < 9
        return;
    end

    [x_all, ord] = sort(x_all);
    G_all = G_all(ord);
    [x_all, ia] = unique(x_all);
    G_all = G_all(ia);

    if numel(x_all) < 9
        return;
    end

    u_all = log10(x_all);
    u_trans = log10(i_trans);

    search_half_width = 0.090;
    core_half_width = 0.035;

    local_mask = u_all >= u_trans - search_half_width & u_all <= u_trans + search_half_width;
    u_local = u_all(local_mask);
    G_local = G_all(local_mask);

    if numel(u_local) < 7
        return;
    end

    G_trans = interp1_unique(x_all, G_all, i_trans);
    if ~isfinite(G_trans)
        [G_left, ~] = endpoint_value_slope_logx(xc, Gc, 'right');
        [G_right, ~] = endpoint_value_slope_logx(xv, Gv, 'left');
        if isfinite(G_left) && isfinite(G_right)
            G_trans = 0.5 * (G_left + G_right);
        else
            return;
        end
    end

    if visible_only && numel(y_range) == 2
        if G_trans < y_range(1) || G_trans > y_range(2)
            return;
        end
    end

    G_left_ref = interp1(u_all, G_all, u_trans - search_half_width, 'linear', NaN);
    G_right_ref = interp1(u_all, G_all, u_trans + search_half_width, 'linear', NaN);

    if ~isfinite(G_left_ref) || ~isfinite(G_right_ref)
        return;
    end

    G_scale = max(G_local) - min(G_local);
    if ~isfinite(G_scale) || G_scale <= 0
        return;
    end

    value_tol = max(1.0e-6 * G_scale, 1.0e-8);
    [G_min_local, idx_min] = min(G_local);
    u_min_local = u_local(idx_min);

    [G_max_local, idx_max] = max(G_local);
    u_max_local = u_local(idx_max);

    near_transition_min = abs(u_min_local - u_trans) <= core_half_width;
    reliable_min_shape = G_min_local <= G_left_ref - value_tol && G_min_local <= G_right_ref - value_tol;

    near_transition_max = abs(u_max_local - u_trans) <= core_half_width;
    reliable_max_shape = G_max_local >= G_left_ref + value_tol && G_max_local >= G_right_ref + value_tol;

    if near_transition_min && reliable_min_shape
        features = add_curve_feature(features, i_trans, G_trans, 'minimum', 'filled black circle', 'transition-edge extremum near T');
    elseif near_transition_max && reliable_max_shape
        features = add_curve_feature(features, i_trans, G_trans, 'maximum', 'filled black circle', 'transition-edge extremum near T');
    end
end

function [G_edge, slope_edge] = endpoint_value_slope_logx(x, G, side_name)
    G_edge = NaN;
    slope_edge = NaN;

    x = x(:);
    G = G(:);
    valid = isfinite(x) & isfinite(G) & x > 0;
    x = x(valid);
    G = G(valid);

    if numel(x) < 5
        return;
    end

    [x, ord] = sort(x);
    G = G(ord);
    [x, ia] = unique(x);
    G = G(ia);

    if numel(x) < 5
        return;
    end

    nfit = min(24, numel(x));
    if strcmpi(side_name, 'right')
        idx = (numel(x)-nfit+1):numel(x);
        G_edge = G(end);
    else
        idx = 1:nfit;
        G_edge = G(1);
    end

    u = log10(x(idx));
    y = G(idx);

    valid_fit = isfinite(u) & isfinite(y);
    u = u(valid_fit);
    y = y(valid_fit);

    if numel(u) < 3 || max(u) <= min(u)
        return;
    end

    p = polyfit(u, y, 1);
    slope_edge = p(1);
end

function features = detect_curve_features_logx(x, G, x_range, y_range, visible_only, resample_N, smooth_window, edge_cut_frac, derivative_tol_frac, curvature_tol_frac, min_log10_separation, mark_extrema, mark_inflections)
    features = empty_curve_features();

    x = x(:);
    G = G(:);

    if numel(x_range) ~= 2 || any(~isfinite(x_range)) || x_range(1) <= 0 || x_range(2) <= x_range(1)
        x_range = [min(x(x>0)), max(x(x>0))];
    end
    if numel(y_range) ~= 2 || y_range(2) <= y_range(1)
        y_range = [-Inf Inf];
    end

    valid = isfinite(x) & isfinite(G) & x > 0 & x >= x_range(1) & x <= x_range(2);
    x = x(valid);
    G = G(valid);

    if numel(x) < 9
        return;
    end

    [x, ord] = sort(x);
    G = G(ord);
    [x, ia] = unique(x);
    G = G(ia);

    if numel(x) < 9
        return;
    end

    u = log10(x);
    u_min = max(min(u), log10(x_range(1)));
    u_max = min(max(u), log10(x_range(2)));
    if ~isfinite(u_min) || ~isfinite(u_max) || u_max <= u_min
        return;
    end

    ngrid = max(80, round(resample_N));
    ngrid = min(ngrid, max(120, 8*numel(x)));
    uq = linspace(u_min, u_max, ngrid).';

    Gq = interp1(u, G, uq, 'pchip', NaN);
    valid_q = isfinite(uq) & isfinite(Gq);
    uq = uq(valid_q);
    Gq = Gq(valid_q);

    if numel(uq) < 15
        return;
    end

    w = max(3, round(smooth_window));
    if mod(w,2) == 0
        w = w + 1;
    end
    w = min(w, max(3, 2*floor((numel(Gq)-1)/2)+1));
    Gs = movmean(Gq, w);

    d1 = gradient(Gs, uq);
    d2 = gradient(d1, uq);

    edge_margin = max(0, edge_cut_frac) * (u_max - u_min);
    u_left = u_min + edge_margin;
    u_right = u_max - edge_margin;

    extrema_u = [];
    extrema_kind = {};

    if mark_extrema
        tol1 = derivative_tol_frac * max(abs(d1));
        if ~isfinite(tol1) || tol1 <= 0
            tol1 = 0;
        end
        s1 = local_sign_with_tolerance(d1, tol1);
        idx = find(s1(1:end-1).*s1(2:end) < 0);

        for kk = 1:numel(idx)
            j = idx(kk);
            u0 = local_zero_crossing(uq(j), uq(j+1), d1(j), d1(j+1));
            if ~isfinite(u0) || u0 < u_left || u0 > u_right
                continue;
            end

            if s1(j) > 0 && s1(j+1) < 0
                kind_now = 'maximum';
            elseif s1(j) < 0 && s1(j+1) > 0
                kind_now = 'minimum';
            else
                continue;
            end

            x0 = 10.^u0;
            G0 = interp1(u, G, u0, 'linear', NaN);
            if ~isfinite(G0)
                G0 = interp1(uq, Gq, u0, 'linear', NaN);
            end
            if ~isfinite(G0)
                continue;
            end
            if visible_only && (G0 < y_range(1) || G0 > y_range(2))
                continue;
            end

            features = add_curve_feature(features, x0, G0, kind_now, 'filled black circle', 'dDeltaG/dlog10(i)=0');
            extrema_u(end+1,1) = u0; %#ok<AGROW>
            extrema_kind{end+1,1} = kind_now; %#ok<AGROW>
        end
    end

    if mark_inflections
        tol2 = curvature_tol_frac * max(abs(d2));
        if ~isfinite(tol2) || tol2 <= 0
            tol2 = 0;
        end
        s2 = local_sign_with_tolerance(d2, tol2);
        idx = find(s2(1:end-1).*s2(2:end) < 0);

        for kk = 1:numel(idx)
            j = idx(kk);
            u0 = local_zero_crossing(uq(j), uq(j+1), d2(j), d2(j+1));
            if ~isfinite(u0) || u0 < u_left || u0 > u_right
                continue;
            end

            x0 = 10.^u0;
            G0 = interp1(u, G, u0, 'linear', NaN);
            if ~isfinite(G0)
                G0 = interp1(uq, Gq, u0, 'linear', NaN);
            end
            if ~isfinite(G0)
                continue;
            end
            if visible_only && (G0 < y_range(1) || G0 > y_range(2))
                continue;
            end

            features = add_curve_feature(features, x0, G0, 'inflection', 'short vertical bar', 'd2DeltaG/dlog10(i)^2=0');
        end
    end

    features = merge_close_curve_features(features, min_log10_separation);
end

function features = empty_curve_features()
    features.i = [];
    features.G = [];
    features.kind = {};
    features.marker = {};
    features.basis = {};
end

function features = add_curve_feature(features, x0, G0, kind_now, marker_now, basis_now)
    features.i(end+1,1) = x0;
    features.G(end+1,1) = G0;
    features.kind{end+1,1} = kind_now;
    features.marker{end+1,1} = marker_now;
    features.basis{end+1,1} = basis_now;
end

function features_out = merge_close_curve_features(features, min_log10_separation)
    features_out = empty_curve_features();

    if isempty(features.i)
        return;
    end

    u = log10(features.i(:));
    [u, ord] = sort(u);
    i_sorted = features.i(ord);
    G_sorted = features.G(ord);
    kind_sorted = features.kind(ord);
    marker_sorted = features.marker(ord);
    basis_sorted = features.basis(ord);

    used = false(numel(u),1);
    for k = 1:numel(u)
        if used(k)
            continue;
        end

        same_kind = strcmp(kind_sorted, kind_sorted{k});
        close_now = abs(u - u(k)) <= min_log10_separation & same_kind & ~used;
        idx = find(close_now);

        if numel(idx) == 1
            keep_idx = idx;
        else
            if strcmpi(kind_sorted{k}, 'maximum')
                [~, loc] = max(G_sorted(idx));
                keep_idx = idx(loc);
            elseif strcmpi(kind_sorted{k}, 'minimum')
                [~, loc] = min(G_sorted(idx));
                keep_idx = idx(loc);
            else
                loc = ceil(numel(idx)/2);
                keep_idx = idx(loc);
            end
        end

        features_out = add_curve_feature(features_out, i_sorted(keep_idx), G_sorted(keep_idx), kind_sorted{keep_idx}, marker_sorted{keep_idx}, basis_sorted{keep_idx});
        used(idx) = true;
    end

    if ~isempty(features_out.i)
        [features_out.i, ord2] = sort(features_out.i);
        features_out.G = features_out.G(ord2);
        features_out.kind = features_out.kind(ord2);
        features_out.marker = features_out.marker(ord2);
        features_out.basis = features_out.basis(ord2);
    end
end

function s = local_sign_with_tolerance(v, tol)
    s = zeros(size(v));
    s(v > tol) = 1;
    s(v < -tol) = -1;

    for k = 2:numel(s)
        if s(k) == 0
            s(k) = s(k-1);
        end
    end
    for k = numel(s)-1:-1:1
        if s(k) == 0
            s(k) = s(k+1);
        end
    end
end

function x0 = local_zero_crossing(x1, x2, y1, y2)
    if ~isfinite(x1) || ~isfinite(x2) || ~isfinite(y1) || ~isfinite(y2)
        x0 = NaN;
        return;
    end

    if y1 == y2
        x0 = 0.5*(x1+x2);
    else
        x0 = x1 - y1*(x2-x1)/(y2-y1);
    end

    if x0 < min(x1,x2) || x0 > max(x1,x2)
        x0 = 0.5*(x1+x2);
    end
end

function rows = plot_and_record_curve_features(ax, features, rows, curve_label, S, unit_name, yl, xlimv, label_points, font_size, font_name, bar_height_frac, label_dx_frac, label_dy_frac, text_margin, marker_size, marker_line_width, bar_line_width)
    if isempty(features.i)
        return;
    end

    yr = yl(2) - yl(1);
    if ~isfinite(yr) || yr <= 0
        yr = 1;
    end

    bar_half_height = 0.5 * bar_height_frac * yr;
    u_lim = log10(xlimv);
    u_span = u_lim(2) - u_lim(1);

    for kk = 1:numel(features.i)
        x0 = features.i(kk);
        G0 = features.G(kk);
        kind_now = features.kind{kk};

        if ~isfinite(x0) || ~isfinite(G0)
            continue;
        end
        if x0 < xlimv(1) || x0 > xlimv(2) || G0 < yl(1) || G0 > yl(2)
            continue;
        end

        if strcmpi(kind_now, 'inflection')
            y1 = max(yl(1), G0 - bar_half_height);
            y2 = min(yl(2), G0 + bar_half_height);
            plot(ax, [x0 x0], [y1 y2], 'k-', ...
                'LineWidth', bar_line_width, 'HandleVisibility','off');
            short_kind = 'infl.';
            marker_now = 'short vertical bar';
            dy_sign = 1;
        else
            plot(ax, x0, G0, 'ko', ...
                'MarkerFaceColor','k', ...
                'MarkerSize', marker_size, ...
                'LineWidth', marker_line_width, ...
                'HandleVisibility','off');
            marker_now = 'filled black circle';
            if strcmpi(kind_now, 'maximum')
                short_kind = 'max';
                dy_sign = 1;
            else
                short_kind = 'min';
                dy_sign = -1;
            end
        end

        rows(end+1,:) = {S, curve_label, kind_now, x0, G0, unit_name, marker_now, features.basis{kk}}; %#ok<AGROW>

        if label_points
            cshort = curve_short_label(curve_label);
            u0 = log10(x0);
            if mod(kk,2) == 0
                dx_sign = -1;
            else
                dx_sign = 1;
            end
            u_text = u0 + dx_sign * label_dx_frac * u_span;
            u_text = min(max(u_text, u_lim(1)+0.018*u_span), u_lim(2)-0.018*u_span);
            x_text = 10.^u_text;

            y_text = G0 + dy_sign * label_dy_frac * yr;
            y_text = min(max(y_text, yl(1)+0.030*yr), yl(2)-0.030*yr);

            if dy_sign > 0
                valign = 'bottom';
            else
                valign = 'top';
            end

            label_now = sprintf('%s, %s, S=%.2f\ni=%.0f, \\DeltaG=%.1f', short_kind, cshort, S, x0, G0);
            text(ax, x_text, y_text, label_now, ...
                'FontName', font_name, ...
                'FontSize', font_size, ...
                'FontWeight','normal', ...
                'Color',[0 0 0], ...
                'HorizontalAlignment','center', ...
                'VerticalAlignment',valign, ...
                'BackgroundColor','w', ...
                'EdgeColor',[0.82 0.82 0.82], ...
                'LineWidth',0.45, ...
                'Margin',text_margin, ...
                'Interpreter','tex', ...
                'Clipping','on');
        end
    end
end

function cshort = curve_short_label(curve_label)
    % Short labels used only in the feature-summary panel.
    % Dc = dual-particle concave branch; Dv = dual-particle convex branch; Sp = single particle.
    if strcmpi(curve_label, 'Dual-transition')
        cshort = 'T';
    elseif strcmpi(curve_label, 'Dual-concave')
        cshort = 'Dc';
    elseif strcmpi(curve_label, 'Dual-convex')
        cshort = 'Dv';
    elseif strcmpi(curve_label, 'Single')
        cshort = 'Sp';
    else
        cshort = curve_label;
    end
end



function render_feature_text_panel(ax, rows, panel_pos, panel_title, panel_font_name, panel_font_size, fallback_font_name, show_DeltaG, sort_by_S, panel_layout, column_width)
    if isempty(rows)
        return;
    end

    if nargin < 4 || isempty(panel_title)
        panel_title = 'Feature points';
    end
    if nargin < 5 || isempty(panel_font_name)
        panel_font_name = fallback_font_name;
    end
    if nargin < 6 || isempty(panel_font_size)
        panel_font_size = 8.2;
    end
    if nargin < 7 || isempty(fallback_font_name)
        fallback_font_name = 'Times New Roman';
    end
    if nargin < 8 || isempty(show_DeltaG)
        show_DeltaG = false;
    end
    if nargin < 9 || isempty(sort_by_S)
        sort_by_S = true;
    end
    if nargin < 10 || isempty(panel_layout)
        panel_layout = 'horizontal_by_S';
    end
    if nargin < 11 || isempty(column_width)
        column_width = 0.210;
    end
    if numel(panel_pos) ~= 4
        panel_pos = [0.035 0.715 0.66 0.24];
    end

    S_all = cell2mat(rows(:,1));
    S_unique = unique(S_all(isfinite(S_all)));
    if sort_by_S
        S_unique = sort(S_unique, 'ascend');
    end

    curve_order = {'Dual-transition', 'Dual-concave', 'Dual-convex', 'Single'};
    kind_order  = {'minimum', 'maximum', 'inflection'};

    if strcmpi(panel_layout, 'horizontal_by_S')
        % Clean horizontal layout: every saturation ratio is drawn as an
        % independent left-aligned text object.  No background box, no border.
        % The black filled-circle icon is generated by char(9679), so the
        % marker used on the curves and the symbol used in the panel are visually consistent.
        bullet_symbol = char(9679);
        header_text = sprintf('%s: %s', bullet_symbol, panel_title);
        text(ax, panel_pos(1), panel_pos(2), header_text, ...
            'Units','normalized', ...
            'FontName', panel_font_name, ...
            'FontSize', panel_font_size, ...
            'FontWeight','normal', ...
            'Color',[0 0 0], ...
            'HorizontalAlignment','left', ...
            'VerticalAlignment','top', ...
            'BackgroundColor','none', ...
            'EdgeColor','none', ...
            'Margin',0.1, ...
            'Interpreter','none', ...
            'Clipping','on');

        % Regime labels aligned above the S columns.  The numerical value is
        % fixed to 1.48 for the figure annotation requested by the user.
        y_regime = panel_pos(2) - 0.052;
        text(ax, panel_pos(1), y_regime, '<S_{g,max}=1.48 (\color{red}barrier-mediated\color{black})', ...
            'Units','normalized', ...
            'FontName', panel_font_name, ...
            'FontSize', panel_font_size, ...
            'FontWeight','normal', ...
            'Color',[0 0 0], ...
            'HorizontalAlignment','left', ...
            'VerticalAlignment','top', ...
            'BackgroundColor','none', ...
            'EdgeColor','none', ...
            'Margin',0.1, ...
            'Interpreter','tex', ...
            'Clipping','on');

        text(ax, panel_pos(1) + 0.365, y_regime, '>S_{g,max}=1.48 (\color{red}barrierless\color{black})', ...
            'Units','normalized', ...
            'FontName', panel_font_name, ...
            'FontSize', panel_font_size, ...
            'FontWeight','normal', ...
            'Color',[0 0 0], ...
            'HorizontalAlignment','left', ...
            'VerticalAlignment','top', ...
            'BackgroundColor','none', ...
            'EdgeColor','none', ...
            'Margin',0.1, ...
            'Interpreter','tex', ...
            'Clipping','on');

        if column_width > 1
            column_dx = panel_pos(3) / max(1, numel(S_unique));
        else
            column_dx = column_width;
        end
        column_dx = max(0.185, column_dx);
        y_column_top = panel_pos(2) - 0.113;

        for ss = 1:numel(S_unique)
            S_now_group = S_unique(ss);
            idx_S = find(abs(S_all - S_now_group) < 1e-10);
            col_lines = {};
            col_lines{end+1} = sprintf('S = %.2f', S_now_group); %#ok<AGROW>

            for cc = 1:numel(curve_order)
                curve_now = curve_order{cc};
                idx_curve = idx_S(strcmp(rows(idx_S,2), curve_now));
                if isempty(idx_curve)
                    continue;
                end

                order_score = zeros(numel(idx_curve),1);
                i_score = zeros(numel(idx_curve),1);
                for kk = 1:numel(idx_curve)
                    rr = idx_curve(kk);
                    kind_now_full = rows{rr,3};
                    kpos = find(strcmp(kind_order, kind_now_full), 1);
                    if isempty(kpos)
                        kpos = 99;
                    end
                    order_score(kk) = kpos;
                    i_score(kk) = rows{rr,4};
                end
                [~, ord] = sortrows([order_score, i_score], [1 2]);
                idx_curve = idx_curve(ord);

                for kk = 1:numel(idx_curve)
                    rr = idx_curve(kk);
                    kind_now = rows{rr,3};
                    curve_now_for_label = rows{rr,2};
                    i_now = rows{rr,4};
                    G_now = rows{rr,5};

                    if strcmpi(kind_now, 'inflection')
                        continue;
                    end

                    if strcmpi(curve_now_for_label, 'Single') && strcmpi(kind_now, 'maximum')
                        item_label = 'Smax';
                    elseif strcmpi(curve_now_for_label, 'Dual-convex') && strcmpi(kind_now, 'maximum')
                        item_label = 'Dmax';
                    elseif (strcmpi(curve_now_for_label, 'Dual-concave') || strcmpi(curve_now_for_label, 'Dual-transition')) && strcmpi(kind_now, 'minimum')
                        item_label = 'Dmin';
                    elseif strcmpi(kind_now, 'maximum')
                        item_label = 'Dmax';
                    elseif strcmpi(kind_now, 'minimum')
                        item_label = 'Dmin';
                    else
                        item_label = kind_now;
                    end

                    if show_DeltaG
                        item_now = sprintf('%s %s i=%.0f, G=%.1f', bullet_symbol, item_label, i_now, G_now);
                    else
                        item_now = sprintf('%s %s i=%.0f', bullet_symbol, item_label, i_now);
                    end
                    col_lines{end+1} = item_now; %#ok<AGROW>
                end
            end

            col_text = sprintf('%s\n', col_lines{:});
            x_column = panel_pos(1) + (ss-1)*column_dx;

            text(ax, x_column, y_column_top, col_text, ...
                'Units','normalized', ...
                'FontName', panel_font_name, ...
                'FontSize', panel_font_size, ...
                'FontWeight','normal', ...
                'Color',[0 0 0], ...
                'HorizontalAlignment','left', ...
                'VerticalAlignment','top', ...
                'BackgroundColor','none', ...
                'EdgeColor','none', ...
                'Margin',0.1, ...
                'Interpreter','none', ...
                'Clipping','on');
        end
    else
        bullet_symbol = char(9679);
        line_cells = {};
        line_cells{end+1} = sprintf('%s: %s', bullet_symbol, panel_title); %#ok<AGROW>
        line_cells{end+1} = '<Sg,max=1.48 (barrier-mediated)    >Sg,max=1.48 (barrierless)'; %#ok<AGROW>

        for ss = 1:numel(S_unique)
            S_now_group = S_unique(ss);
            idx_S = find(abs(S_all - S_now_group) < 1e-10);
            if isempty(idx_S)
                continue;
            end

            if ss > 1
                line_cells{end+1} = ' '; %#ok<AGROW>
            end
            line_cells{end+1} = sprintf('S = %.2f', S_now_group); %#ok<AGROW>

            for cc = 1:numel(curve_order)
                curve_now = curve_order{cc};
                idx_curve = idx_S(strcmp(rows(idx_S,2), curve_now));
                if isempty(idx_curve)
                    continue;
                end

                order_score = zeros(numel(idx_curve),1);
                i_score = zeros(numel(idx_curve),1);
                for kk = 1:numel(idx_curve)
                    rr = idx_curve(kk);
                    kind_now_full = rows{rr,3};
                    kpos = find(strcmp(kind_order, kind_now_full), 1);
                    if isempty(kpos)
                        kpos = 99;
                    end
                    order_score(kk) = kpos;
                    i_score(kk) = rows{rr,4};
                end
                [~, ord] = sortrows([order_score, i_score], [1 2]);
                idx_curve = idx_curve(ord);

                for kk = 1:numel(idx_curve)
                    rr = idx_curve(kk);
                    kind_now = rows{rr,3};
                    curve_now_for_label = rows{rr,2};
                    i_now = rows{rr,4};
                    G_now = rows{rr,5};

                    if strcmpi(kind_now, 'inflection')
                        continue;
                    end

                    if strcmpi(curve_now_for_label, 'Single') && strcmpi(kind_now, 'maximum')
                        item_label = 'Smax';
                    elseif strcmpi(curve_now_for_label, 'Dual-convex') && strcmpi(kind_now, 'maximum')
                        item_label = 'Dmax';
                    elseif (strcmpi(curve_now_for_label, 'Dual-concave') || strcmpi(curve_now_for_label, 'Dual-transition')) && strcmpi(kind_now, 'minimum')
                        item_label = 'Dmin';
                    elseif strcmpi(kind_now, 'maximum')
                        item_label = 'Dmax';
                    elseif strcmpi(kind_now, 'minimum')
                        item_label = 'Dmin';
                    else
                        item_label = kind_now;
                    end

                    if show_DeltaG
                        line_cells{end+1} = sprintf('  %s %s i=%.0f, G=%.1f', bullet_symbol, item_label, i_now, G_now); %#ok<AGROW>
                    else
                        line_cells{end+1} = sprintf('  %s %s i=%.0f', bullet_symbol, item_label, i_now); %#ok<AGROW>
                    end
                end
            end
        end

        panel_text = sprintf('%s\n', line_cells{:});
        text(ax, panel_pos(1), panel_pos(2), panel_text, ...
            'Units','normalized', ...
            'FontName', panel_font_name, ...
            'FontSize', panel_font_size, ...
            'FontWeight','normal', ...
            'Color',[0 0 0], ...
            'HorizontalAlignment','left', ...
            'VerticalAlignment','top', ...
            'BackgroundColor','none', ...
            'EdgeColor','none', ...
            'Margin',0.1, ...
            'Interpreter','none', ...
            'Clipping','on');
    end
end

function txt_out = truncate_text_for_panel(txt_in, max_len)
    txt_out = txt_in;
    if max_len < 4
        return;
    end
    if length(txt_out) > max_len
        txt_out = [txt_out(1:max_len-3), '...'];
    end
end

function plot_vertical_marker(ax, x0, yl, color, style, labelText, font_name, font_size_text)
    if ~isfinite(x0)
        return;
    end
    plot(ax, [x0 x0], yl, style, 'Color',color, 'LineWidth',1.8, 'HandleVisibility','off');
    text(ax, x0*1.04, yl(1)+0.88*(yl(2)-yl(1)), labelText, 'FontName',font_name, 'FontSize',font_size_text, 'Color',color, 'FontWeight','bold', 'VerticalAlignment','top', 'Interpreter','tex');
end

function safeName = make_safe_varname(rawName)
    safeName = rawName;
    safeName = strrep(safeName, '.', 'p');
    safeName = strrep(safeName, '-', 'm');
    safeName = strrep(safeName, '+', 'p');
    safeName = strrep(safeName, ' ', '_');
    if isempty(regexp(safeName(1), '[A-Za-z]', 'once'))
        safeName = ['Var_' safeName];
    end
    for k = 1:length(safeName)
        if isempty(regexp(safeName(k), '[A-Za-z0-9_]', 'once'))
            safeName(k) = '_';
        end
    end
end
