clear; clc; close all;

R_nm = 2.0;
R2_nm = 2.828;
theta_deg = 30.0;
T = 300.0;
gamma = 0.0715;
rho_l = 998.0;
M = 18.01528e-3;
Rg = 8.314462618;
NA = 6.02214076e23;

i_min_plot = 1.0;
i_max_plot = 30000.0;
omega_min_deg = 0.5;
omega_max_deg = 359.0;
npts_each = 5000;
r_min_nm = 0.01;
r_max_nm = 200.0;
npts_single = 8000;
fig_name_png = 'Scrit_dual_vs_single_green_intersections.png';
fig_name_tif = 'Scrit_dual_vs_single_green_intersections.tif';
csv_dual = 'Scrit_dual_vs_single_dual_Final.csv';
csv_single = 'Scrit_dual_vs_single_single_Final.csv';
csv_green_intersections = 'Green_single_intersections.csv';

R = R_nm * 1e-9;
R2 = R2_nm * 1e-9;
theta = deg2rad(theta_deg);
Vm = M / rho_l;
v0 = Vm / NA;

omega_switch = pi/2 - theta;
buffer = deg2rad(0.02);

if omega_switch <= deg2rad(omega_min_deg)
    error('omega_switch <= omega_min. Please reduce theta or omega_min.');
end
if omega_switch >= deg2rad(omega_max_deg)
    error('omega_switch >= omega_max. Please increase omega_max or reduce theta.');
end

omega_c = linspace(deg2rad(omega_min_deg), omega_switch - buffer, npts_each).';
omega_v = linspace(omega_switch + buffer, deg2rad(omega_max_deg), npts_each).';

[i_c, Sp_c, S0_c] = dual_branch_calc(omega_c, R, theta, gamma, Vm, Rg, T, v0, 'concave');
[i_v, Sp_v, S0_v] = dual_branch_calc(omega_v, R, theta, gamma, Vm, Rg, T, v0, 'convex');

i_trans = mean([i_c(end), i_v(1)]);
S_trans = mean([Sp_c(end), Sp_v(1)]);

i_dual = [i_c; i_v];
Sp_dual = [Sp_c; Sp_v];
S0_dual = [S0_c; S0_v];
branch_dual = [repmat({'concave'}, numel(i_c), 1); repmat({'convex'}, numel(i_v), 1)];

valid_d = isfinite(i_dual) & isfinite(Sp_dual) & isfinite(S0_dual) & (i_dual > 0) & (Sp_dual > 0) & (S0_dual > 0);
i_dual = i_dual(valid_d);
Sp_dual = Sp_dual(valid_d);
S0_dual = S0_dual(valid_d);
branch_dual = branch_dual(valid_d);

[i_dual, idxd] = sort(i_dual);
Sp_dual = Sp_dual(idxd);
S0_dual = S0_dual(idxd);
branch_dual = branch_dual(idxd);

mask_d = (i_dual >= i_min_plot) & (i_dual <= i_max_plot);
i_dual = i_dual(mask_d);
Sp_dual = Sp_dual(mask_d);
S0_dual = S0_dual(mask_d);
branch_dual = branch_dual(mask_d);

show_transition = isfinite(i_trans) && (i_trans >= i_min_plot) && (i_trans <= i_max_plot);

r_scan = logspace(log10(r_min_nm*1e-9), log10(r_max_nm*1e-9), npts_single).';
i_single2 = nan(size(r_scan));
S_single2 = nan(size(r_scan));

for k = 1:numel(r_scan)
    r = r_scan(k);
    d = sqrt(R2^2 + r^2 - 2*r*R2*cos(theta));
    if ~isfinite(d) || d <= 0
        continue;
    end
    cos_phi = (R2*cos(theta) - r) / d;
    cos_Phi = (R2 - r*cos(theta)) / d;
    cos_phi = max(-1, min(1, cos_phi));
    cos_Phi = max(-1, min(1, cos_Phi));
    V_cap_vapor = (pi/3) * r^3 * (2 - 3*cos_phi + cos_phi^3);
    V_cap_solid = (pi/3) * R2^3 * (2 - 3*cos_Phi + cos_Phi^3);
    V_droplet = V_cap_vapor - V_cap_solid;
    if ~isfinite(V_droplet) || V_droplet <= 0
        continue;
    end
    i_single2(k) = V_droplet / v0;
    lnS = 2 * gamma * Vm / (Rg * T * r);
    S_single2(k) = exp(lnS);
end

valid_s2 = isfinite(i_single2) & isfinite(S_single2) & (i_single2 > 0) & (S_single2 > 0);
i_single2 = i_single2(valid_s2);
S_single2 = S_single2(valid_s2);

[i_single2, idxs2] = sort(i_single2);
S_single2 = S_single2(idxs2);

mask_s2 = (i_single2 >= i_min_plot) & (i_single2 <= i_max_plot);
i_single2 = i_single2(mask_s2);
S_single2 = S_single2(mask_s2);

search_range_dual = [1000, 20000];
[i_cross_Sp_S0, S_cross_Sp_S0] = find_intersection(i_dual, Sp_dual, i_dual, S0_dual, search_range_dual);

search_range_green = [i_min_plot, i_max_plot];
[i_green_sp, S_green_sp] = find_all_intersections(i_dual, Sp_dual, i_single2, S_single2, search_range_green);
[i_green_s0, S_green_s0] = find_all_intersections(i_dual, S0_dual, i_single2, S_single2, search_range_green);

valid_v = isfinite(i_v) & isfinite(Sp_v) & isfinite(S0_v) & (i_v > 0);
i_v_valid = i_v(valid_v);
omega_v_valid = omega_v(valid_v);

[i_v_valid, ord_v] = sort(i_v_valid);
omega_v_valid = omega_v_valid(ord_v);

[i_v_unique, ia] = unique(i_v_valid);
omega_v_unique = omega_v_valid(ia);

omega_trans_rad = omega_switch;
omega_trans_deg = rad2deg(omega_trans_rad);

if ~isnan(i_cross_Sp_S0)
    omega_cross_SpS0_rad = interp1(i_v_unique, omega_v_unique, i_cross_Sp_S0, 'pchip', NaN);
    omega_cross_SpS0_deg = rad2deg(omega_cross_SpS0_rad);
else
    omega_cross_SpS0_rad = NaN;
    omega_cross_SpS0_deg = NaN;
end

omega_green_sp_rad = interp1(i_v_unique, omega_v_unique, i_green_sp, 'pchip', NaN);
omega_green_sp_deg = rad2deg(omega_green_sp_rad);
omega_green_s0_rad = interp1(i_v_unique, omega_v_unique, i_green_s0, 'pchip', NaN);
omega_green_s0_deg = rad2deg(omega_green_s0_rad);

fprintf('\nFilling angle omega at key points\n');
fprintf('Transition: i = %.6f, S = %.6f, omega = %.6f deg\n', i_trans, S_trans, omega_trans_deg);
fprintf('Sp vs S0 second intersection: i = %.6f, S = %.6f, omega = %.6f deg\n', i_cross_Sp_S0, S_cross_Sp_S0, omega_cross_SpS0_deg);
fprintf('\nSingle-particle intersections\n');
for n = 1:numel(i_green_sp)
    fprintf('Sp_dual vs Single R=2.828 #%d: i = %.6f, S = %.6f, omega = %.6f deg\n', n, i_green_sp(n), S_green_sp(n), omega_green_sp_deg(n));
end
for n = 1:numel(i_green_s0)
    fprintf('S0_dual vs Single R=2.828 #%d: i = %.6f, S = %.6f, omega = %.6f deg\n', n, i_green_s0(n), S_green_s0(n), omega_green_s0_deg(n));
end

point_name = {'Transition'; 'Sp_dual_vs_S0_dual_second'};
i_point = [i_trans; i_cross_Sp_S0];
S_point = [S_trans; S_cross_Sp_S0];
omega_rad_point = [omega_trans_rad; omega_cross_SpS0_rad];
omega_deg_point = [omega_trans_deg; omega_cross_SpS0_deg];
T_omega = table(point_name, i_point, S_point, omega_rad_point, omega_deg_point, 'VariableNames', {'Point','i','S','omega_rad','omega_deg'});
writetable(T_omega, 'Intersection_omega_values.csv');

green_point_sp = arrayfun(@(n) sprintf('Sp_dual_vs_Single_R2p828_%d', n), (1:numel(i_green_sp)).', 'UniformOutput', false);
green_point_s0 = arrayfun(@(n) sprintf('S0_dual_vs_Single_R2p828_%d', n), (1:numel(i_green_s0)).', 'UniformOutput', false);
green_point_name = [green_point_sp; green_point_s0];
green_i = [i_green_sp; i_green_s0];
green_S = [S_green_sp; S_green_s0];
green_omega_rad = [omega_green_sp_rad; omega_green_s0_rad];
green_omega_deg = [omega_green_sp_deg; omega_green_s0_deg];
T_green = table(green_point_name, green_i, green_S, green_omega_rad, green_omega_deg, 'VariableNames', {'Point','i','S','omega_rad','omega_deg'});
writetable(T_green, csv_green_intersections);

T_dual = table(i_dual, Sp_dual, S0_dual, branch_dual, 'VariableNames', {'i','Sp','S0','branch'});
writetable(T_dual, csv_dual);
T_single = table(i_single2, S_single2, 'VariableNames', {'i','S_single'});
writetable(T_single, csv_single);

fig = figure('Color','w', 'Units','centimeters', 'Position',[2 2 16.8 11.8]);
ax = axes('Parent', fig);
hold(ax,'on');
box(ax,'off');

y_all = [Sp_dual; S0_dual; S_single2];
ymin_plot = min(y_all);
ymax_plot = max(y_all);
yrange = ymax_plot - ymin_plot;
y_lower_limit = max(0, ymin_plot - 0.05*yrange);
y_upper_limit = ymax_plot + 0.06*yrange;

set(ax, 'Color','w', 'FontName','Times New Roman', 'FontSize',11, 'LineWidth',1.2, 'TickDir','in', 'TickLength',[0.02 0.02], 'XScale','log', 'XMinorTick','on', 'YMinorTick','on');

c1 = [0.0000, 0.4470, 0.7410];
c2 = [0.8500, 0.3250, 0.0980];
c3 = [0.25, 0.65, 0.25];
c4 = [0.45, 0.45, 0.45];

p1 = plot(ax, i_dual, Sp_dual, '-', 'LineWidth',2.0, 'Color',c1);
p2 = plot(ax, i_dual, S0_dual, '--', 'LineWidth',1.8, 'Color',c2);
p3 = plot(ax, i_single2, S_single2, '--', 'LineWidth',1.7, 'Color',c3);
p_green_sp = plot(ax, i_green_sp, S_green_sp, 'ks', 'MarkerFaceColor','w', 'MarkerSize',5, 'LineWidth',1.1);
p_green_s0 = plot(ax, i_green_s0, S_green_s0, 'kd', 'MarkerFaceColor','w', 'MarkerSize',5, 'LineWidth',1.1);

if show_transition
    plot(ax, [i_trans i_trans], [y_lower_limit S_trans], 'k:', 'LineWidth', 1.0, 'Color', c4);
    plot(ax, [i_min_plot i_trans], [S_trans S_trans], 'k:', 'LineWidth', 1.0, 'Color', c4);
    plot(ax, i_trans, S_trans, 'ko', 'MarkerFaceColor', 'w', 'MarkerSize', 5, 'LineWidth', 1.1);
    p_guide = plot(ax, NaN, NaN, 'k:', 'LineWidth',1.2, 'Color',c4);
    lgd = legend(ax, [p1, p2, p3, p_green_sp, p_green_s0, p_guide], {'Dual particle: at contact point p', 'Dual particle: at neck axis x = 0', 'Single particle: R = 2.828 nm', 'Green single vs contact point p', 'Green single vs neck axis x = 0', 'Dual-particle shape transition'}, 'Location','northeast');
else
    lgd = legend(ax, [p1, p2, p3, p_green_sp, p_green_s0], {'Dual particle: at contact point p', 'Dual particle: at neck axis x = 0', 'Single particle: R = 2.828 nm', 'Green single vs contact point p', 'Green single vs neck axis x = 0'}, 'Location','northeast');
end

set(lgd, 'Box','off', 'FontName','Times New Roman', 'FontSize',10);
set(lgd, 'Units','normalized');
set(ax, 'Units','normalized');
lgd_pos = get(lgd, 'Position');
ax_pos = get(ax, 'Position');
lgd_pos(2) = min(ax_pos(2) + ax_pos(4) - lgd_pos(4) - 0.005, lgd_pos(2) + 0.02);
set(lgd, 'Position', lgd_pos);

xlabel(ax, 'Number of water molecules in embryo, {\iti}', 'FontName','Times New Roman', 'FontSize',13, 'Interpreter', 'tex');
ylabel(ax, 'Equilibrium saturation ratio of liquid bridge embryo, {\itS_c}', 'FontName','Times New Roman', 'FontSize',13, 'Interpreter', 'tex');

xlim(ax, [i_min_plot, i_max_plot]);
ylim(ax, [y_lower_limit, y_upper_limit]);

main_xlim = xlim(ax);
main_ylim = ylim(ax);
line(ax, main_xlim, [main_ylim(2) main_ylim(2)], 'Color','k', 'LineWidth',1.2, 'Clipping','off', 'HandleVisibility','off');
line(ax, [main_xlim(2) main_xlim(2)], main_ylim, 'Color','k', 'LineWidth',1.2, 'Clipping','off', 'HandleVisibility','off');

coord_lines = {};
coord_lines{end+1} = sprintf('T: (%.0f, %.2f)', i_trans, S_trans);
coord_lines{end+1} = sprintf('D: (%.0f, %.2f)', i_cross_Sp_S0, S_cross_Sp_S0);
for n = 1:numel(i_green_sp)
    coord_lines{end+1} = sprintf('B%d: (%.0f, %.2f)', n, i_green_sp(n), S_green_sp(n));
end
for n = 1:numel(i_green_s0)
    coord_lines{end+1} = sprintf('O%d: (%.0f, %.2f)', n, i_green_s0(n), S_green_s0(n));
end
coord_text = sprintf('%s\n', coord_lines{:});
text(ax, 0.075, 0.965, coord_text, 'Units','normalized', 'VerticalAlignment','top', 'HorizontalAlignment','left', 'FontName','Times New Roman', 'FontSize',9, 'BackgroundColor','none', 'Margin',4);

ax_inset = axes('Parent', fig, 'Position', [0.53 0.42 0.35 0.25]);
hold(ax_inset, 'on');
box(ax_inset, 'off');

plot(ax_inset, i_dual, Sp_dual, '-', 'LineWidth', 1.5, 'Color', c1);
plot(ax_inset, i_dual, S0_dual, '--', 'LineWidth', 1.5, 'Color', c2);
plot(ax_inset, i_single2, S_single2, '--', 'LineWidth', 1.5, 'Color', c3);

if show_transition
    plot(ax_inset, i_trans, S_trans, 'ko', 'MarkerFaceColor', 'w', 'MarkerSize', 4, 'LineWidth', 0.9);
    text(ax_inset, i_trans * 0.90, S_trans - 0.04, 'T', 'FontName', 'Times New Roman', 'FontSize', 8, 'FontWeight', 'bold', 'Color', 'k');
end

if ~isnan(i_cross_Sp_S0)
    plot(ax_inset, i_cross_Sp_S0, S_cross_Sp_S0, 'ko', 'MarkerFaceColor', 'w', 'MarkerSize', 4, 'LineWidth', 0.9);
    text(ax_inset, i_cross_Sp_S0 * 0.86, S_cross_Sp_S0 - 0.055, 'D', 'FontName', 'Times New Roman', 'FontSize', 8, 'FontWeight', 'bold', 'Color', 'k');
end

for n = 1:numel(i_green_sp)
    plot(ax_inset, i_green_sp(n), S_green_sp(n), 'ks', 'MarkerFaceColor', 'w', 'MarkerSize', 4, 'LineWidth', 0.9);
    if n == 1
        text(ax_inset, i_green_sp(n) * 0.80, S_green_sp(n) + 0.038, 'B1', 'FontName', 'Times New Roman', 'FontSize', 8, 'FontWeight', 'bold', 'Color', 'k');
    else
        text(ax_inset, i_green_sp(n) * 1.10, S_green_sp(n) - 0.045, 'B2', 'FontName', 'Times New Roman', 'FontSize', 8, 'FontWeight', 'bold', 'Color', 'k');
    end
end

for n = 1:numel(i_green_s0)
    plot(ax_inset, i_green_s0(n), S_green_s0(n), 'kd', 'MarkerFaceColor', 'w', 'MarkerSize', 4, 'LineWidth', 0.9);
    text(ax_inset, i_green_s0(n) * 1.07, S_green_s0(n) + 0.038, sprintf('O%d', n), 'FontName', 'Times New Roman', 'FontSize', 8, 'FontWeight', 'bold', 'Color', 'k');
end

inset_x_min = 100;
inset_x_max = 20000;
inset_y_min = 1.1;
inset_y_max = 1.6;

set(ax_inset, 'XScale', 'log', 'FontName', 'Times New Roman', 'FontSize', 9, 'LineWidth', 1.0, 'TickDir', 'in');
xlim(ax_inset, [inset_x_min, inset_x_max]);
ylim(ax_inset, [inset_y_min, inset_y_max]);

inset_xlim = xlim(ax_inset);
inset_ylim = ylim(ax_inset);
line(ax_inset, inset_xlim, [inset_ylim(2) inset_ylim(2)], 'Color','k', 'LineWidth',1.0, 'Clipping','off', 'HandleVisibility','off');
line(ax_inset, [inset_xlim(2) inset_xlim(2)], inset_ylim, 'Color','k', 'LineWidth',1.0, 'Clipping','off', 'HandleVisibility','off');

rectangle(ax, 'Position', [inset_x_min, inset_y_min, inset_x_max-inset_x_min, inset_y_max-inset_y_min], 'EdgeColor', c4, 'LineStyle', ':', 'LineWidth', 1.2);

set(fig, 'InvertHardcopy', 'off');
set(fig, 'PaperPositionMode', 'auto');
set(fig, 'Renderer', 'painters');
drawnow;
print(fig, fig_name_png, '-dpng', '-r3000');
print(fig, fig_name_tif, '-dtiff', '-r3000');

fprintf('Finished.\n');
fprintf('Figure saved to: %s\n', fig_name_png);
fprintf('Figure saved to: %s\n', fig_name_tif);
fprintf('Curve data saved to: %s and %s\n', csv_dual, csv_single);

function [x_int, y_int] = find_intersection(x1, y1, x2, y2, x_range)
    mask = x1 >= x_range(1) & x1 <= x_range(2);
    x_sub = x1(mask);
    y1_sub = y1(mask);
    y2_sub = interp1(x2, y2, x_sub, 'linear');
    diff_y = y1_sub - y2_sub;
    idx = find(diff_y(1:end-1) .* diff_y(2:end) <= 0, 1);
    if isempty(idx)
        x_int = NaN;
        y_int = NaN;
        return;
    end
    x_a = x_sub(idx);
    x_b = x_sub(idx+1);
    d_a = diff_y(idx);
    d_b = diff_y(idx+1);
    x_int = x_a - d_a * (x_b - x_a) / (d_b - d_a);
    y_int = interp1(x_sub, y1_sub, x_int, 'linear');
end

function [x_int, y_int] = find_all_intersections(x1, y1, x2, y2, x_range)
    mask = x1 >= x_range(1) & x1 <= x_range(2);
    x_sub = x1(mask);
    y1_sub = y1(mask);
    y2_sub = interp1(x2, y2, x_sub, 'linear', NaN);
    valid = isfinite(x_sub) & isfinite(y1_sub) & isfinite(y2_sub);
    x_sub = x_sub(valid);
    y1_sub = y1_sub(valid);
    y2_sub = y2_sub(valid);
    diff_y = y1_sub - y2_sub;
    idx = find(diff_y(1:end-1) .* diff_y(2:end) <= 0);
    x_int = nan(numel(idx), 1);
    y_int = nan(numel(idx), 1);
    for n = 1:numel(idx)
        k = idx(n);
        x_a = x_sub(k);
        x_b = x_sub(k+1);
        d_a = diff_y(k);
        d_b = diff_y(k+1);
        if d_a == d_b
            x_int(n) = x_a;
        else
            x_int(n) = x_a - d_a * (x_b - x_a) / (d_b - d_a);
        end
        y_int(n) = interp1(x_sub, y1_sub, x_int(n), 'linear');
    end
end

function [i_num, S_p, S_0] = dual_branch_calc(omega, R, theta, gamma, Vm, Rg, T, v0, branchType)
    alpha = theta + omega;
    lnS_p = gamma*Vm/(Rg*T) .* (sin(alpha)./(R*sin(omega)) - cos(alpha)./(R*(1-cos(omega))));
    r_az_0 = R*sin(omega) - R*(1-cos(omega)).*(1-sin(alpha))./cos(alpha);
    lnS_0 = gamma*Vm/(Rg*T) .* (1./r_az_0 - cos(alpha)./(R*(1-cos(omega))));
    V_cap = (pi/3) * R^3 .* (1-cos(omega)).^2 .* (2 + cos(omega));
    switch lower(branchType)
        case 'concave'
            r_m = R*(1-cos(omega))./cos(alpha);
            y0 = R*sin(omega) + R*(1-cos(omega)).*tan(alpha);
            phi = pi/2 - alpha;
            V_rot = 2*pi*r_m .* (y0.^2 .* sin(phi) + r_m.^2 .* sin(phi) - (r_m.^2/3).*sin(phi).^3 - y0.*r_m .* (phi + sin(phi).*cos(phi)));
        case 'convex'
            r_m = -R*(1-cos(omega))./cos(alpha);
            y1 = R*sin(omega) + R*(1-cos(omega)).*tan(alpha);
            phi = alpha - pi/2;
            V_rot = 2*pi*r_m .* (y1.^2 .* sin(phi) + r_m.^2 .* sin(phi) - (r_m.^2/3).*sin(phi).^3 + y1.*r_m .* (phi + sin(phi).*cos(phi)));
        otherwise
            error('Unknown branchType.');
    end
    V_total = V_rot - V_cap;
    i_num = V_total ./ v0;
    S_p = exp(lnS_p);
    S_0 = exp(lnS_0);
end
