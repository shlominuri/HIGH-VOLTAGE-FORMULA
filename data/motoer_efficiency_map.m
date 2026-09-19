%% EMRAX 228 Motor Efficiency Map
% Approximation based on the published EMRAX 228 efficiency contour map.
% Efficiency values stored as decimal values (0-1).

% Motor speed breakpoints [rpm]
rpm_bp = [0 500 1000 1500 2000 2500 3000 3500 4000 4500 5000 5500];

% Motor torque breakpoints [Nm]
torque_bp = [0 25 50 75 100 125 150 175 200 225];

%% Digitized efficiency contours
% Approximate points extracted from the published EMRAX 228 efficiency map.
% These are NOT raw dynamometer data.

% 96% efficiency contour
rpm_96 = [1600 1800 2000 2250 2500 2750 3000 3250 3500 3750 3900];

torque_96_upper = ...
    [124 128 129 130 130 129 127 125 120 114 105];

torque_96_lower = ...
    [115  95  84  77  75  76  78  81  86  94 105];

% Close the 96% contour
rpm_96_closed = ...
    [rpm_96 fliplr(rpm_96) rpm_96(1)];

torque_96_closed = ...
    [torque_96_upper fliplr(torque_96_lower) torque_96_upper(1)];

%% 95% efficiency contour

rpm_95 = [1250 1500 1750 2000 2250 2500 2750 3000 ...
    3250 3500 3750 4000 4250 4500 4700];

torque_95_upper = ...
    [145 158 164 167 169 170 170 169 ...
    168 166 163 159 154 147 138];

torque_95_lower = ...
    [145 100  78  68  63  60  60  61 ...
    63  66  70  75  82  94 115];

% Close the 95% contour
rpm_95_closed = ...
    [rpm_95 fliplr(rpm_95) rpm_95(1)];

torque_95_closed = ...
    [torque_95_upper fliplr(torque_95_lower) torque_95_upper(1)];


%% 94% efficiency contour

rpm_94 = [900 1100 1300 1500 1750 2000 2250 2500 ...
    2750 3000 3250 3500 3750 4000 4250 4500 ...
    4750 5000 5200];

torque_94_upper = ...
    [150 175 188 195 198 200 201 201 ...
    201 201 201 201 201 201 201 201 ...
    201 200 195];

torque_94_lower = ...
    [150 100 75 62 57 55 54 54 ...
    54 54 54 55 56 58 61 65 ...
    72 85 110];

rpm_94_closed = ...
    [rpm_94 fliplr(rpm_94) rpm_94(1)];

torque_94_closed = ...
    [torque_94_upper fliplr(torque_94_lower) torque_94_upper(1)];

[RPM_grid, Torque_grid] = meshgrid(rpm_bp, torque_bp);

assert(isequal(size(RPM_grid), ...
               [length(torque_bp), length(rpm_bp)]), ...
       'Lookup-table grid dimensions are inconsistent');


%% Approximate 90% efficiency boundary
% Estimated from the boundary between the published
% "86-90%" and "90-94%" efficiency regions.
% NOT an exact 90% contour supplied by EMRAX.

rpm_90 = [500 750 1000 1250 1500 1750 2000 2250 2500 ...
    2750 3000 3250 3500 3750 4000 4250 4500 ...
    4750 5000 5250 5500];

torque_90_upper = ...
    [100 145 180 205 220 230 235 240 242 ...
     243 243 242 240 238 235 230 222 ...
     210 205 180 150];

torque_90_lower = ...
    [100  65  45  35  30  27  25  24  23 ...
    23  23  24  25  27  30  34  40 ...
    48  60  78 105];

rpm_90_closed = ...
    [rpm_90 fliplr(rpm_90) rpm_90(1)];

torque_90_closed = ...
    [torque_90_upper fliplr(torque_90_lower) torque_90_upper(1)];

%% Approximate 86% efficiency boundary
% Approximate outer boundary of the published 86-90% region.
% NOT an exact 86% contour supplied by EMRAX.

rpm_86 = [0 250 500 750 1000 1250 1500 1750 2000 ...
    2250 2500 2750 3000 3250 3500 3750 4000 ...
    4250 4500 4750 5000 5250 5500];

torque_86_upper = ...
    [50 100 150 190 220 240 250 250 250 ...
    250 250 250 250 250 250 250 250 ...
    250 250 245 235 215 185];

torque_86_lower = ...
    [50 35 25 18 15 13 12 12 12 ...
    12 12 12 12 12 13 14 16 ...
    19 23 30 40 55 80];

rpm_86_closed = ...
    [rpm_86 fliplr(rpm_86) rpm_86(1)];

torque_86_closed = ...
    [torque_86_upper fliplr(torque_86_lower) torque_86_upper(1)];

%% Identify grid points inside each efficiency contour

inside_96 = inpolygon(RPM_grid, Torque_grid, ...
    rpm_96_closed, torque_96_closed);

inside_95 = inpolygon(RPM_grid, Torque_grid, ...
    rpm_95_closed, torque_95_closed);

inside_94 = inpolygon(RPM_grid, Torque_grid, ...
    rpm_94_closed, torque_94_closed);

inside_90 = inpolygon(RPM_grid, Torque_grid, ...
    rpm_90_closed, torque_90_closed);

inside_86 = inpolygon(RPM_grid, Torque_grid, ...
    rpm_86_closed, torque_86_closed);

%% Separate efficiency regions

region_96 = inside_96;

region_95_96 = inside_95 & ~region_96;

region_94_95 = inside_94 & ...
               ~region_95_96 & ~region_96;

region_90_94 = inside_90 & ~inside_94;

region_86_90 = inside_86 & ~inside_90;

region_below_86 = ~(region_96 | ...
                    region_95_96 | ...
                    region_94_95 | ...
                    region_90_94 | ...
                    region_86_90);
%% Initialize efficiency lookup table

eta_table = NaN(size(RPM_grid));

% Known / approximated contour regions
eta_table(region_96) = 0.96;

%% Interpolate efficiency between 95% and 96%

idx = find(region_95_96);

for k = 1:length(idx)

    i = idx(k);

    eta_table(i) = interpolateBetweenContours( ...
        RPM_grid(i), Torque_grid(i), ...
        rpm_95_closed, torque_95_closed, 0.95, ...
        rpm_96_closed, torque_96_closed, 0.96);

end

%% Interpolate efficiency between 94% and 95%

idx = find(region_94_95);

for k = 1:length(idx)

    i = idx(k);

    eta_table(i) = interpolateBetweenContours( ...
        RPM_grid(i), Torque_grid(i), ...
        rpm_94_closed, torque_94_closed, 0.94, ...
        rpm_95_closed, torque_95_closed, 0.95);

end

%% Interpolate efficiency between ~90% and 94%

idx = find(region_90_94);

for k = 1:length(idx)

    i = idx(k);

    eta_table(i) = interpolateBetweenContours( ...
        RPM_grid(i), Torque_grid(i), ...
        rpm_90_closed, torque_90_closed, 0.90, ...
        rpm_94_closed, torque_94_closed, 0.94);

end

%% Interpolate efficiency between ~86% and ~90%

idx = find(region_86_90);

for k = 1:length(idx)

    i = idx(k);

    eta_table(i) = interpolateBetweenContours( ...
        RPM_grid(i), Torque_grid(i), ...
        rpm_86_closed, torque_86_closed, 0.86, ...
        rpm_90_closed, torque_90_closed, 0.90);

end

%% Extrapolate efficiency outside the ~86% contour

outside_idx = find(isnan(eta_table));

rpm_scale = 5500;
torque_scale = 250;

eta_min = 0.80;

for k = 1:length(outside_idx)

    i = outside_idx(k);

    % Normalize operating point
    x = RPM_grid(i) / rpm_scale;
    y = Torque_grid(i) / torque_scale;

    % Normalize ~86% contour
    contour_x = rpm_86_closed / rpm_scale;
    contour_y = torque_86_closed / torque_scale;

    % Distance from operating point to ~86% contour
    d86 = min(sqrt((contour_x - x).^2 + ...
        (contour_y - y).^2));

    % Efficiency decreases as we move away from the ~86% contour
    eta_table(i) = 0.86 - 0.20*d86;

    % Prevent unrealistically low efficiency
    eta_table(i) = max(eta_table(i), eta_min);

end


%% Plot digitized efficiency contours

figure;

% ~86% boundary
plot(rpm_86_closed, torque_86_closed, 'o-');
hold on;

% ~90% boundary
plot(rpm_90_closed, torque_90_closed, 'o-');

% 94% contour
plot(rpm_94_closed, torque_94_closed, 'o-');

% 95% contour
plot(rpm_95_closed, torque_95_closed, 'o-');

% 96% contour
plot(rpm_96_closed, torque_96_closed, 'o-');

grid on;

xlabel('Motor Speed [rpm]');
ylabel('Torque [Nm]');
title('EMRAX 228 - Digitized Efficiency Map');

xlim([0 5500]);
ylim([0 250]);

legend('~86% boundary', ...
       '~90% boundary', ...
       '94%', ...
       '95%', ...
       '96%', ...
       'Location', 'best');

hold off;


function eta = interpolateBetweenContours(rpm, torque, ...
    outer_rpm, outer_torque, outer_eta, ...
    inner_rpm, inner_torque, inner_eta)

% Normalize axes so RPM does not dominate the distance calculation
rpm_scale = 5500;
torque_scale = 250;

x = rpm / rpm_scale;
y = torque / torque_scale;

outer_x = outer_rpm / rpm_scale;
outer_y = outer_torque / torque_scale;

inner_x = inner_rpm / rpm_scale;
inner_y = inner_torque / torque_scale;

% Distance to each contour
d_outer = min(sqrt((outer_x - x).^2 + ...
    (outer_y - y).^2));

d_inner = min(sqrt((inner_x - x).^2 + ...
    (inner_y - y).^2));

% Relative position between contours
alpha = d_outer / (d_outer + d_inner);

% Efficiency interpolation
eta = outer_eta + alpha * (inner_eta - outer_eta);

end