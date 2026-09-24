%% Formula Student - Lap Energy Simulation V1
clear;
clc;
close all;

%% Vehicle parameters

m = 300;           % Vehicle + driver mass [kg]
g = 9.81;          % Gravitational acceleration [m/s^2]
Crr = 0.015;       % Rolling resistance coefficient

%% Load track data
data = readtable("track_with_cones_no_regen_2.csv");

%% Extract track data

t = data.elapsedTime;          % Time [s]
s = data.elapsedDistance;      % Distance [m]

v_kmh = data.speed;            % Vehicle speed [km/h]
v = v_kmh / 3.6;              % Vehicle speed [m/s]

x = data.xposition;            % X position [m]
y = data.yposition;            % Y position [m]

%% Basic lap information

fprintf('Lap time: %.2f s\n', t(end));
fprintf('Lap distance: %.2f m\n', s(end));
fprintf('Maximum speed: %.2f km/h\n', max(v_kmh));
fprintf('Average speed: %.2f km/h\n', mean(v_kmh));

%% Plot track colored by vehicle speed

figure;

scatter(x, y, 18, v_kmh, 'filled');

axis equal;
grid on;

xlabel('X Position [m]');
ylabel('Y Position [m]');
title('Formula Student Track - Vehicle Speed');

cb = colorbar;
cb.Label.String = 'Speed [km/h]';

%% Calculate longitudinal acceleration

% Calculate acceleration from the speed profile
a_calc = gradient(v, t);       % [m/s^2]

%% Calculate longitudinal forces

% Force required for vehicle acceleration
F_acc = m .* a_calc;

% Rolling resistance
F_rr = Crr * m * g;

% Aerodynamic drag force from source CSV [N]
% TEMPORARY V1 assumption:
% Replace with 0.5*rho*CdA*v.^2 when vehicle aerodynamic data is available.
F_drag = data.dragForce;

% Total force that must be supplied at the wheels
F_required = F_acc + F_drag + F_rr;

% No regenerative braking:
% During braking, negative required force is supplied by the brakes,
% not returned to the battery.
F_tractive = max(F_required, 0);

%% Plot longitudinal forces

figure;

plot(t, F_acc, 'LineWidth', 1.2);
hold on;
plot(t, F_drag, 'LineWidth', 1.2);
plot(t, F_tractive, 'LineWidth', 1.5);

grid on;

xlabel('Time [s]');
ylabel('Force [N]');
title('Vehicle Longitudinal Forces');

legend('Acceleration Force', ...
    'Aerodynamic Drag', ...
    'Required Traction Force');

fprintf('\n--- Force Results ---\n');
fprintf('Rolling resistance: %.2f N\n', F_rr);
fprintf('Maximum drag force: %.2f N\n', max(F_drag));
fprintf('Maximum traction force: %.2f N\n', max(F_tractive));

%% Calculate wheel power

P_wheel = F_tractive .* v;     % Mechanical power at wheels [W]

% Convert to kW for plotting
P_wheel_kW = P_wheel / 1000;

%% Plot wheel power

figure;

plot(t, P_wheel_kW, 'LineWidth', 1.5);

grid on;

xlabel('Time [s]');
ylabel('Wheel Power [kW]');
title('Mechanical Power Required at Wheels');

%% Calculate mechanical energy per lap

E_wheel_J = trapz(t, P_wheel);       % [J]

E_wheel_kWh = E_wheel_J / 3.6e6;     % [kWh] : 1kWh=3.6*10^6 J

fprintf('\n--- Wheel Power & Energy ---\n');
fprintf('Maximum wheel power: %.2f kW\n', max(P_wheel_kW));
fprintf('Average wheel power: %.2f kW\n', mean(P_wheel_kW));
fprintf('Mechanical energy per lap: %.4f kWh\n', E_wheel_kWh);

P_avg_lap_kW = E_wheel_J / (t(end)-t(1)) / 1000;

fprintf('Average traction power over lap: %.2f kW\n', P_avg_lap_kW);

%% Drivetrain parameters

r_wheel = 0.23;        % Effective wheel radius [m]
GR = 3.8;              % Fixed gear ratio
eta_gear = 0.97;       % Mechanical drivetrain efficiency


%% Calculate wheel and motor operating point

% Wheel torque
T_wheel = F_tractive .* r_wheel;        % [Nm]

% Required motor torque
T_motor = T_wheel ./ (GR * eta_gear);   % [Nm]

% Wheel angular speed
omega_wheel = v ./ r_wheel;             % [rad/s]

% Motor angular speed
omega_motor = omega_wheel .* GR;         % [rad/s]

% Motor speed
RPM_motor = omega_motor .* 60 ./ (2*pi); % [rpm]

% Mechanical power produced by the motor
P_motor = T_motor .* omega_motor;        % [W]
P_motor_kW = P_motor / 1000;             % [kW]


%% Motor mechanical energy

E_motor_J = trapz(t, P_motor);           % [J]
E_motor_kWh = E_motor_J / 3.6e6;         % [kWh]


%% Motor limits

T_motor_max = 220;                       % Peak motor torque [Nm]


%% Display drivetrain and motor results

fprintf('\n--- Drivetrain & Motor Results ---\n');

fprintf('Maximum motor torque: %.2f Nm\n', max(T_motor));
fprintf('Maximum motor speed: %.0f rpm\n', max(RPM_motor));
fprintf('Maximum motor mechanical power: %.2f kW\n', max(P_motor_kW));
fprintf('Motor mechanical energy per lap: %.4f kWh\n', E_motor_kWh);


%% Check motor torque limit

if max(T_motor) <= T_motor_max
    fprintf('Motor torque requirement is within the motor limit.\n');
else
    fprintf('WARNING: Required motor torque exceeds motor limit!\n');
end

%% EMRAX 228 motor efficiency

% Generate EMRAX 228 efficiency map
run('motor_efficiency_map.m');

%% Interpolate motor efficiency along the lap

eta_motor = interp2( ...
    rpm_bp, ...
    torque_bp, ...
    eta_table, ...
    RPM_motor, ...
    T_motor, ...
    'linear');

if any(isnan(eta_motor))
    warning('Some motor operating points are outside the efficiency map.');
end

%% Motor electrical power and energy

% Electrical power required by the motor
P_motor_elec = P_motor ./ eta_motor;          % [W]
P_motor_elec_kW = P_motor_elec / 1000;        % [kW]

% Electrical energy supplied to the motor
E_motor_elec_J = trapz(t, P_motor_elec);      % [J]
E_motor_elec_kWh = E_motor_elec_J / 3.6e6;    % [kWh]

% Effective motor efficiency over the lap
eta_motor_effective = E_motor_J / E_motor_elec_J;

fprintf('\n--- Motor Electrical Results ---\n');
fprintf('Maximum motor electrical power: %.2f kW\n', ...
    max(P_motor_elec_kW));

fprintf('Motor electrical energy per lap: %.4f kWh\n', ...
    E_motor_elec_kWh);

fprintf('Effective motor efficiency: %.2f %%\n', ...
    100 * eta_motor_effective);

%% Motor phase current

Kt = 0.48;                         % Torque constant [Nm/Arms]

I_ac = T_motor ./ Kt;              % Motor phase current [Arms]

fprintf('\n--- Motor Current Results ---\n');
fprintf('Maximum motor current: %.2f Arms\n', max(I_ac));

%% Load inverter loss map

run('inverter_efficiency_map.m');

%% Extend inverter map to zero current

I_ac_ext = [0 I_ac_bp];

P_loss_ext = [zeros(length(V_dc_bp),1) P_loss_table];

%% Inverter losses

V_dc = 450;                         % Nominal battery voltage [V]

P_inv_loss = interp2( ...
    I_ac_ext, ...
    V_dc_bp, ...
    P_loss_ext, ...
    I_ac, ...
    V_dc * ones(size(I_ac)), ...
    'linear');

fprintf('\n--- Inverter Loss Results ---\n');
fprintf('Maximum inverter loss: %.2f kW\n', ...
    max(P_inv_loss) / 1000);

fprintf('Average inverter loss: %.2f kW\n', ...
    mean(P_inv_loss) / 1000);

E_inv_loss_J = trapz(t, P_inv_loss);
E_inv_loss_kWh = E_inv_loss_J / 3.6e6;

fprintf('Inverter energy loss per lap: %.4f kWh\n', ...
    E_inv_loss_kWh);

%% Battery power and energy

% Power drawn from the battery
P_battery = P_motor_elec + P_inv_loss;        % [W]
P_battery_kW = P_battery / 1000;              % [kW]

% Battery energy consumed per lap
E_battery_J = trapz(t, P_battery);            % [J]
E_battery_kWh = E_battery_J / 3.6e6;          % [kWh]

% Effective powertrain efficiency
eta_powertrain = E_wheel_J / E_battery_J;


%% Display battery results

fprintf('\n--- Battery Results ---\n');

fprintf('Maximum battery power: %.2f kW\n', ...
    max(P_battery_kW));

fprintf('Battery energy per lap: %.4f kWh\n', ...
    E_battery_kWh);

fprintf('Overall powertrain efficiency: %.2f %%\n', ...
    100 * eta_powertrain);

%% Endurance energy estimation

endurance_distance_km = 22;                  % Endurance distance [km]
lap_distance_km = s(end) / 1000;            % Lap distance [km]

equivalent_laps = endurance_distance_km / lap_distance_km;

E_endurance_kWh = E_battery_kWh * equivalent_laps;


%% Display endurance results

fprintf('\n--- Endurance Energy Estimate ---\n');

fprintf('Lap distance: %.3f km\n', lap_distance_km);

fprintf('Equivalent laps for 22 km: %.2f\n', equivalent_laps);

fprintf('Battery traction energy for 22 km: %.2f kWh\n', ...
    E_endurance_kWh);


%% Mass sensitivity analysis

mass_values = 280:10:330;               % Vehicle + driver mass [kg]

E_endurance_mass = zeros(size(mass_values));

for k = 1:length(mass_values)

    m_test = mass_values(k);

    % Vehicle forces
    F_acc_test = m_test .* a_calc;
    F_rr_test = Crr * m_test * g;

    F_required_test = ...
        F_acc_test + F_drag + F_rr_test;

    % No regenerative braking
    F_tractive_test = max(F_required_test, 0);


    % Motor torque
    T_wheel_test = F_tractive_test .* r_wheel;

    T_motor_test = ...
        T_wheel_test ./ (GR * eta_gear);


    % Motor mechanical power
    P_motor_test = ...
        T_motor_test .* omega_motor;


    % Motor efficiency
    eta_motor_test = interp2( ...
        rpm_bp, ...
        torque_bp, ...
        eta_table, ...
        RPM_motor, ...
        T_motor_test, ...
        'linear');


    % Check efficiency map limits
    if any(isnan(eta_motor_test))
        warning('Mass %.0f kg produces operating points outside motor efficiency map.', ...
            m_test);
    end


    % Motor electrical power
    P_motor_elec_test = ...
        P_motor_test ./ eta_motor_test;


    % Motor phase current
    I_ac_test = ...
        T_motor_test ./ Kt;


    % Inverter losses
    P_inv_loss_test = interp2( ...
        I_ac_ext, ...
        V_dc_bp, ...
        P_loss_ext, ...
        I_ac_test, ...
        V_dc * ones(size(I_ac_test)), ...
        'linear');


    % Battery power
    P_battery_test = ...
        P_motor_elec_test + P_inv_loss_test;


    % Battery energy per lap
    E_battery_test_J = ...
        trapz(t, P_battery_test);

    E_battery_test_kWh = ...
        E_battery_test_J / 3.6e6;


    % Endurance energy
    E_endurance_mass(k) = ...
        E_battery_test_kWh * equivalent_laps;

end

%% Display mass sensitivity results

fprintf('\n--- Mass Sensitivity ---\n');

for k = 1:length(mass_values)

    fprintf('Mass = %.0f kg  -->  Endurance Energy = %.2f kWh\n', ...
        mass_values(k), E_endurance_mass(k));

end

figure;

plot(mass_values, E_endurance_mass, 'o-', ...
    'LineWidth', 1.5);

grid on;

xlabel('Vehicle + Driver Mass [kg]');
ylabel('Endurance Battery Energy [kWh]');
title('Effect of Vehicle Mass on Endurance Energy');

%% Rolling resistance sensitivity analysis

Crr_values = [0.010 0.0125 0.015 0.0175 0.020];

E_endurance_Crr = zeros(size(Crr_values));

for k = 1:length(Crr_values)

    Crr_test = Crr_values(k);

    % Rolling resistance
    F_rr_test = Crr_test * m * g;

    % Total required longitudinal force
    F_required_test = ...
        F_acc + F_drag + F_rr_test;

    % No regenerative braking
    F_tractive_test = max(F_required_test, 0);


    % Wheel and motor torque
    T_wheel_test = F_tractive_test .* r_wheel;

    T_motor_test = ...
        T_wheel_test ./ (GR * eta_gear);


    % Motor mechanical power
    P_motor_test = ...
        T_motor_test .* omega_motor;


    % Motor efficiency
    eta_motor_test = interp2( ...
        rpm_bp, ...
        torque_bp, ...
        eta_table, ...
        RPM_motor, ...
        T_motor_test, ...
        'linear');


    % Check motor efficiency map limits
    if any(isnan(eta_motor_test))
        warning('Crr = %.4f produces operating points outside motor efficiency map.', ...
            Crr_test);
    end


    % Motor electrical power
    P_motor_elec_test = ...
        P_motor_test ./ eta_motor_test;


    % Motor phase current
    I_ac_test = ...
        T_motor_test ./ Kt;


    % Inverter losses
    P_inv_loss_test = interp2( ...
        I_ac_ext, ...
        V_dc_bp, ...
        P_loss_ext, ...
        I_ac_test, ...
        V_dc * ones(size(I_ac_test)), ...
        'linear');


    % Battery power
    P_battery_test = ...
        P_motor_elec_test + P_inv_loss_test;


    % Battery energy per lap
    E_battery_test_J = ...
        trapz(t, P_battery_test);

    E_battery_test_kWh = ...
        E_battery_test_J / 3.6e6;


    % Endurance energy
    E_endurance_Crr(k) = ...
        E_battery_test_kWh * equivalent_laps;

end

%% Display rolling resistance sensitivity results

fprintf('\n--- Rolling Resistance Sensitivity ---\n');

for k = 1:length(Crr_values)

    fprintf('Crr = %.4f  -->  Endurance Energy = %.3f kWh\n', ...
        Crr_values(k), E_endurance_Crr(k));

end


%% Plot rolling resistance sensitivity

figure;

plot(Crr_values, E_endurance_Crr, 'o-', ...
    'LineWidth', 1.5);

grid on;

xlabel('Rolling Resistance Coefficient C_{rr}');
ylabel('Endurance Battery Energy [kWh]');
title('Effect of Rolling Resistance on Endurance Energy');

%% =========================================================
%  OptimumLap vs Our Model - Diagnostic Comparison
% ==========================================================

% OptimumLap data
T_opt = data.torque;                 % Motor torque [Nm]
RPM_opt = data.engineSpeed;          % Motor speed [rpm]
P_opt_hp = data.power;               % OptimumLap power [hp]
P_opt_kW = P_opt_hp * 0.7457;        % Convert hp -> kW

throttle_opt = data.throttlePosition;
brake_opt = data.brakePosition;
TC_opt = data.tractionControl;

% Our model
T_our = T_motor;                     % [Nm]
RPM_our = RPM_motor;                 % [rpm]
P_our_kW = P_motor / 1000;           % [kW]


%% Torque difference

T_diff = T_opt - T_our;

fprintf('\n--- OptimumLap vs Our Model ---\n');

fprintf('Maximum OptimumLap torque: %.2f Nm\n', max(T_opt));
fprintf('Maximum our torque: %.2f Nm\n', max(T_our));

fprintf('Mean OptimumLap torque: %.2f Nm\n', mean(T_opt));
fprintf('Mean our torque: %.2f Nm\n', mean(T_our));

fprintf('Maximum torque difference: %.2f Nm\n', max(abs(T_diff)));


%% Plot torque comparison

figure;

plot(t, T_opt, 'LineWidth', 1.2);
hold on;
plot(t, T_our, 'LineWidth', 1.5);

grid on;

xlabel('Time [s]');
ylabel('Motor Torque [Nm]');
title('Motor Torque: OptimumLap vs Our Model');

legend('OptimumLap', 'Our Model');


%% Plot mechanical power comparison

figure;

plot(t, P_opt_kW, 'LineWidth', 1.2);
hold on;
plot(t, P_our_kW, 'LineWidth', 1.5);

grid on;

xlabel('Time [s]');
ylabel('Mechanical Power [kW]');
title('Motor Power: OptimumLap vs Our Model');

legend('OptimumLap', 'Our Model');


%% Compare RPM

figure;

plot(t, RPM_opt, 'LineWidth', 1.2);
hold on;
plot(t, RPM_our, 'LineWidth', 1.5);

grid on;

xlabel('Time [s]');
ylabel('Motor Speed [rpm]');
title('Motor Speed: OptimumLap vs Our Model');

legend('OptimumLap', 'Our Model');


%% Energy calculated directly from OptimumLap power

E_opt_mech_J = trapz(t, P_opt_kW * 1000);
E_opt_mech_kWh = E_opt_mech_J / 3.6e6;

fprintf('\n--- Mechanical Energy Comparison ---\n');

fprintf('OptimumLap mechanical energy per lap: %.4f kWh\n', ...
    E_opt_mech_kWh);

fprintf('Our motor mechanical energy per lap: %.4f kWh\n', ...
    E_motor_kWh);

fprintf('OptimumLap / Our energy ratio: %.2f\n', ...
    E_opt_mech_kWh / E_motor_kWh);

%% Check whether OptimumLap torque explains CSV acceleration

F_wheel_from_opt = ...
    T_opt .* GR .* eta_gear ./ r_wheel;

a_from_opt_torque = ...
    (F_wheel_from_opt - F_drag - F_rr) ./ m;

figure;

plot(t, a_calc, 'LineWidth', 1.5);
hold on;

plot(t, a_from_opt_torque, 'LineWidth', 1.2);

grid on;

xlabel('Time [s]');
ylabel('Acceleration [m/s^2]');
title('Acceleration Consistency Check');

legend('Acceleration from speed profile', ...
    'Acceleration predicted from OptimumLap torque');

%% Compare CSV acceleration with our calculated acceleration

% Acceleration directly from OptimumLap CSV
a_opt = data.longitudinalAcceleration;

% Our acceleration calculated from the CSV speed profile
a_our = gradient(v, t);

figure;

plot(t, a_opt, 'LineWidth', 1.5);
hold on;

plot(t, a_our, '--', 'LineWidth', 1.3);

grid on;

xlabel('Time [s]');
ylabel('Longitudinal Acceleration [m/s^2]');
title('Longitudinal Acceleration: OptimumLap CSV vs Our Calculation');

legend('OptimumLap CSV', ...
    'Our calculation from v(t)', ...
    'Location', 'best');

%% Acceleration comparison statistics

a_error = a_opt - a_our;

fprintf('\n--- Acceleration Comparison ---\n');

fprintf('CSV max acceleration: %.3f m/s^2\n', max(a_opt));
fprintf('Our max acceleration: %.3f m/s^2\n', max(a_our));

fprintf('CSV min acceleration: %.3f m/s^2\n', min(a_opt));
fprintf('Our min acceleration: %.3f m/s^2\n', min(a_our));

fprintf('Mean absolute difference: %.4f m/s^2\n', ...
    mean(abs(a_error)));

fprintf('Maximum absolute difference: %.4f m/s^2\n', ...
    max(abs(a_error)));