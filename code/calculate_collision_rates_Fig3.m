clc; clear; close all;

R_dual = 2e-9;
R_single = 2.828e-9;
theta_deg = 30;
T = 300;
S = 12;
pi_ratio = 0.04;

iMax_plot = 600;
omegaN = 2000;
scanN = 5000;
omega_gap = deg2rad(0.5);

R_yMin = 0;
R_yMax = 1200;

kB = 1.3806e-23;
N_A = 6.022e23;
Mw = 18.015e-3;
m_water = Mw / N_A;
rho_water = 998;
v0 = m_water / rho_water;
sigma_vc = 0.0715;
P_inf = 1017;
P_vapor = S * P_inf;
a2 = 1.98e-28 * 1e-11;
b2 = 1.313e-15 * 1e-4;

pi_film = pi_ratio * sigma_vc;
eq_F = @(F) (F ./ b2) .* ((kB*T)./(1-F) - (a2.*F)./b2) - pi_film;
F_opt = fzero(eq_F, [1e-6, 0.999999], optimset('Display','off'));
n1_ads = F_opt / b2;

fprintf('theta = %.2f deg, pi/sigma = %.2f\n', theta_deg, pi_ratio);
fprintf('n(1) = %.6e 1/m^2\n', n1_ads);

alpha = n1_ads * sqrt((pi * kB * T) / (32 * m_water));
beta = P_vapor / sqrt(2 * pi * m_water * kB * T);
fprintf('alpha = %.6e 1/(m*s), beta = %.6e 1/(m^2*s)\n', alpha, beta);

theta_rad = deg2rad(theta_deg);

r_scan = logspace(log10(0.01e-9), log10(100e-9), scanN);
i_sing = zeros(1, scanN);
Jsm_sing = zeros(1, scanN);
Jc_sing = zeros(1, scanN);

for k = 1:scanN
    r = r_scan(k);
    d = sqrt(R_single^2 + r^2 - 2 * r * R_single * cos(theta_rad));
    cos_phi = (R_single * cos(theta_rad) - r) / d;
    cos_Phi = (R_single - r * cos(theta_rad)) / d;
    a_vc = 2 * pi * r^2 * (1 - cos_phi);
    sin_phi = sqrt(max(0, 1 - cos_phi^2));
    l_circ = 2 * pi * r * sin_phi;
    V_cap_v = (pi/3) * r^3 * (2 - 3*cos_phi + cos_phi^3);
    V_cap_s = (pi/3) * R_single^3 * (2 - 3*cos_Phi + cos_Phi^3);
    V_drop = V_cap_v - V_cap_s;
    i_sing(k) = V_drop / v0;
    Jsm_sing(k) = alpha * l_circ;
    Jc_sing(k) = beta * a_vc;
end

omega_switch = pi/2 - theta_rad;

wMin = 1e-3;
wMax = omega_switch - omega_gap;
i_conc = [];
Jsm_conc = [];
Jc_conc = [];
if wMax > wMin
    omega = linspace(wMin, wMax, omegaN);
    i_conc = zeros(size(omega));
    Jsm_conc = zeros(size(omega));
    Jc_conc = zeros(size(omega));
    for k = 1:omegaN
        w = omega(k);
        if theta_rad + w >= pi/2, continue; end
        l_circ = 2 * pi * R_dual * sin(w);
        V_cap = (pi/3) * R_dual^3 * (1 - cos(w))^2 * (2 + cos(w));
        denom = cos(theta_rad + w);
        if denom <= 0, continue; end
        r2 = R_dual * (1 - cos(w)) / denom;
        phi = pi/2 - (theta_rad + w);
        y0 = R_dual * sin(w) + r2 * sin(theta_rad + w);
        a_vc = 2 * pi * r2 * (y0 * phi - r2 * sin(phi));
        V_tor = 2 * pi * r2 * (y0^2 * sin(phi) - y0 * r2 * (phi + sin(phi)*cos(phi)) + r2^2 * (sin(phi) - sin(phi)^3/3));
        V_br = V_tor - V_cap;
        if a_vc <= 0 || V_br <= 0, continue; end
        i_conc(k) = V_br / v0;
        Jsm_conc(k) = alpha * l_circ;
        Jc_conc(k) = beta * a_vc;
    end
end

wMin = max(1e-3, omega_switch + omega_gap);
wMax = pi/2 - 1e-3;
i_conv = [];
Jsm_conv = [];
Jc_conv = [];
if wMax > wMin
    omega = linspace(wMin, wMax, omegaN);
    i_conv = zeros(size(omega));
    Jsm_conv = zeros(size(omega));
    Jc_conv = zeros(size(omega));
    for k = 1:omegaN
        w = omega(k);
        if theta_rad + w <= pi/2, continue; end
        l_circ = 2 * pi * R_dual * sin(w);
        V_cap = (pi/3) * R_dual^3 * (1 - cos(w))^2 * (2 + cos(w));
        denom = cos(theta_rad + w);
        if denom >= 0, continue; end
        r2 = - R_dual * (1 - cos(w)) / denom;
        phi = (theta_rad + w) - pi/2;
        y0 = R_dual * sin(w) - r2 * sin(theta_rad + w);
        a_vc = 2 * pi * r2 * (y0 * phi + r2 * sin(phi));
        V_tor = 2 * pi * r2 * (y0^2 * sin(phi) + y0 * r2 * (phi + sin(phi)*cos(phi)) + r2^2 * (sin(phi) - sin(phi)^3/3));
        V_br = V_tor - V_cap;
        if a_vc <= 0 || V_br <= 0, continue; end
        i_conv(k) = V_br / v0;
        Jsm_conv(k) = alpha * l_circ;
        Jc_conv(k) = beta * a_vc;
    end
end

maskS = isfinite(i_sing) & (i_sing > 1) & (i_sing <= iMax_plot);
iS = i_sing(maskS)';
JsmS = Jsm_sing(maskS)';
JcS = Jc_sing(maskS)';
[iS, ord] = sort(iS);
JsmS = JsmS(ord);
JcS = JcS(ord);

maskC = isfinite(i_conc) & (i_conc > 1) & (i_conc <= iMax_plot);
iC = i_conc(maskC)';
JsmC = Jsm_conc(maskC)';
JcC = Jc_conc(maskC)';
[iC, ord] = sort(iC);
JsmC = JsmC(ord);
JcC = JcC(ord);

maskV = isfinite(i_conv) & (i_conv > 1) & (i_conv <= iMax_plot);
iV = i_conv(maskV)';
JsmV = Jsm_conv(maskV)';
JcV = Jc_conv(maskV)';
[iV, ord] = sort(iV);
JsmV = JsmV(ord);
JcV = JcV(ord);

JsmS_fun = @(x) interp1(iS, JsmS, x, 'pchip');
JcS_fun = @(x) interp1(iS, JcS, x, 'pchip');

if ~isempty(iC)
    JsmS_on = JsmS_fun(iC);
    JcS_on = JcS_fun(iC);
    fprintf('\nConcave i: %.1f to %.1f\n', min(iC), max(iC));
    fprintf('Jsm_D/Jsm_S: %.4f | Jc_D/Jc_S: %.4f | R_D: %.2f\n', mean(JsmC./JsmS_on), mean(JcC./JcS_on), mean(JsmC./JcC));
end

if ~isempty(iV)
    JsmS_on = JsmS_fun(iV);
    JcS_on = JcS_fun(iV);
    fprintf('\nConvex i: %.1f to %.1f\n', min(iV), max(iV));
    fprintf('Jsm_D/Jsm_S: %.4f | Jc_D/Jc_S: %.4f | R_D: %.2f\n', mean(JsmV./JsmS_on), mean(JcV./JcS_on), mean(JsmV./JcV));
end

color_single = [0.4, 0.4, 0.4];
color_conc = [0.75, 0.15, 0.20];
color_conv = [0.15, 0.35, 0.65];
color_switch = [0, 0.4, 0.4];
fontN = 'Times New Roman';
fLabel = 15;
fTick = 12;
lw = 2.5;

i_switch = [];
if ~isempty(iC) && ~isempty(iV)
    i_switch = mean([iC(end), iV(1)]);
end

fig1 = figure('Color','w','Position',[50,200,480,420]);
hold on;
h = {};
t = {};
p1 = plot(iS, JsmS, '-', 'Color', color_single, 'LineWidth', lw);
h = [h; p1];
t = [t; {'Single (R=2.828 nm)'}];
if ~isempty(iC)
    p2 = plot(iC, JsmC, '-', 'Color', color_conc, 'LineWidth', lw);
    h = [h; p2];
    t = [t; {'Double (Concave)'}];
    plot(iC(end), JsmC(end), 'o', 'Color', color_conc, 'MarkerFaceColor', 'w', 'LineWidth', 1.5, 'MarkerSize', 6);
end
if ~isempty(iV)
    p3 = plot(iV, JsmV, '--', 'Color', color_conv, 'LineWidth', lw);
    h = [h; p3];
    t = [t; {'Double (Convex)'}];
    plot(iV(1), JsmV(1), 's', 'Color', color_conv, 'MarkerFaceColor', 'w', 'LineWidth', 1.5, 'MarkerSize', 6);
end
if ~isempty(i_switch)
    xline(i_switch, '-.', 'Color', color_switch, 'LineWidth', 1.5);
    text(i_switch+20, 2.6e12, 'Geometrical Singularity', 'FontName', fontN, 'FontSize', fTick, 'Color', 'k');
    text(i_switch+20, 2.42e12, '(\theta+\omega=90^\circ)', 'FontName', fontN, 'FontSize', fTick, 'Color', 'k');
end
xlim([0, iMax_plot]);
grid on;
box on;
set(gca, 'FontName', fontN, 'FontSize', fTick, 'LineWidth', 1.5, 'TickDir', 'in');
xlabel('Number of water molecules \it i', 'FontSize', fLabel, 'FontName', fontN, 'FontWeight', 'bold');
ylabel('Surface migration rate \it J_{sm} \rm (s^{-1})', 'FontSize', fLabel, 'FontName', fontN, 'FontWeight', 'bold');
lgd = legend(h, t, 'Location', 'SouthEast', 'FontSize', fTick, 'FontName', fontN, 'Box', 'off');
lgd.Position(1) = lgd.Position(1) + 0.02;
print(fig1, 'Fig1_Jsm.png', '-dpng', '-r3000');
close(fig1);

fig2 = figure('Color','w','Position',[550,200,480,420]);
hold on;
h = {};
t = {};
p1 = plot(iS, JcS, '-', 'Color', color_single, 'LineWidth', lw);
h = [h; p1];
t = [t; {'Single (R=2.828 nm)'}];
if ~isempty(iC)
    p2 = plot(iC, JcC, '-', 'Color', color_conc, 'LineWidth', lw);
    h = [h; p2];
    t = [t; {'Double (Concave)'}];
    plot(iC(end), JcC(end), 'o', 'Color', color_conc, 'MarkerFaceColor', 'w', 'LineWidth', 1.5, 'MarkerSize', 6);
end
if ~isempty(iV)
    p3 = plot(iV, JcV, '--', 'Color', color_conv, 'LineWidth', lw);
    h = [h; p3];
    t = [t; {'Double (Convex)'}];
    plot(iV(1), JcV(1), 's', 'Color', color_conv, 'MarkerFaceColor', 'w', 'LineWidth', 1.5, 'MarkerSize', 6);
end
if ~isempty(i_switch)
    xline(i_switch, '-.', 'Color', color_switch, 'LineWidth', 1.5);
    text(i_switch+20, 9e9, 'Geometrical Singularity', 'FontName', fontN, 'FontSize', fTick, 'Color', 'k');
    text(i_switch+20, 8e9, '(\theta+\omega=90^\circ)', 'FontName', fontN, 'FontSize', fTick, 'Color', 'k');
end
xlim([0, iMax_plot]);
grid on;
box on;
set(gca, 'FontName', fontN, 'FontSize', fTick, 'LineWidth', 1.5, 'TickDir', 'in');
xlabel('Number of water molecules \it i', 'FontSize', fLabel, 'FontName', fontN, 'FontWeight', 'bold');
ylabel('Gas-phase collision rate \it J_c \rm (s^{-1})', 'FontSize', fLabel, 'FontName', fontN, 'FontWeight', 'bold');
lgd = legend(h, t, 'Location', 'SouthEast', 'FontSize', fTick, 'FontName', fontN, 'Box', 'off');
lgd.Position(1) = lgd.Position(1) + 0.02;
print(fig2, 'Fig2_Jc.png', '-dpng', '-r3000');
close(fig2);

fig3 = figure('Color','w','Position',[1050,200,480,420]);
hold on;
h = {};
t = {};
p1 = plot(iS, JsmS./JcS, '-', 'Color', color_single, 'LineWidth', lw);
h = [h; p1];
t = [t; {'Single (R=2.828 nm)'}];
if ~isempty(iC)
    RC = JsmC./JcC;
    p2 = plot(iC, RC, '-', 'Color', color_conc, 'LineWidth', lw);
    h = [h; p2];
    t = [t; {'Double (Concave)'}];
    plot(iC(end), RC(end), 'o', 'Color', color_conc, 'MarkerFaceColor', 'w', 'LineWidth', 1.5, 'MarkerSize', 6);
end
if ~isempty(iV)
    RV = JsmV./JcV;
    p3 = plot(iV, RV, '--', 'Color', color_conv, 'LineWidth', lw);
    h = [h; p3];
    t = [t; {'Double (Convex)'}];
    plot(iV(1), RV(1), 's', 'Color', color_conv, 'MarkerFaceColor', 'w', 'LineWidth', 1.5, 'MarkerSize', 6);
end
if ~isempty(i_switch)
    xline(i_switch, '-.', 'Color', color_switch, 'LineWidth', 1.5);
    text(i_switch+12, 410, 'Geometrical Singularity', 'FontName', fontN, 'FontSize', fTick, 'Color', 'k');
    text(i_switch+12, 340, '(\theta+\omega=90^\circ)', 'FontName', fontN, 'FontSize', fTick, 'Color', 'k');
end
xlim([0, iMax_plot]);
ylim([R_yMin, R_yMax]);
grid on;
box on;
set(gca, 'FontName', fontN, 'FontSize', fTick, 'LineWidth', 1.5, 'TickDir', 'in');
xlabel('Number of water molecules \it i', 'FontSize', fLabel, 'FontName', fontN, 'FontWeight', 'bold');
ylabel('Ratio \it R = J_{sm} / J_c', 'FontSize', fLabel, 'FontName', fontN, 'FontWeight', 'bold');
lgd = legend(h, t, 'Location', 'NorthEast', 'FontSize', fTick, 'FontName', fontN, 'Box', 'off');
lgd.Position(1) = lgd.Position(1) + 0.02;
print(fig3, 'Fig3_R.png', '-dpng', '-r3000');
close(fig3);

disp('Calculation and plotting completed.');

if ~isempty(iS)
    writetable(array2table([iS, JsmS, JcS, JsmS./JcS], 'VariableNames', {'i','Jsm','Jc','R'}), 'Data_Single_R2.828nm.csv');
end
if ~isempty(iC)
    writetable(array2table([iC, JsmC, JcC, JsmC./JcC], 'VariableNames', {'i','Jsm','Jc','R'}), 'Data_Concave.csv');
end
if ~isempty(iV)
    writetable(array2table([iV, JsmV, JcV, JsmV./JcV], 'VariableNames', {'i','Jsm','Jc','R'}), 'Data_Convex.csv');
end

disp('Data files exported.');
