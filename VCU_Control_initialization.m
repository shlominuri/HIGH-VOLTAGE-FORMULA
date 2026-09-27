% VCU Control parameters

% Rate limiter
VCU_torque_rise_rate = 2000;   % [Nm/s] TESTING VALUE NON FINAL!
VCU_torque_fall_rate = -4000;  % [Nm/s] TESTING VALUE NON FINAL!

% Low-pass filter
VCU_torque_lpf_fc = 10;   % [Hz] TEMPORARY
VCU_torque_lpf_tau = 1 / (2*pi*VCU_torque_lpf_fc);   % [sec]

% Power limiting
VCU_max_power = 77e3;       % [W] TEMPORARY, note that 75K is the mechanical power and not the actual power outputted by the battery
VCU_omega_floor = 1;        % [rad/s], prevents division by zero

VCU_batt_series_cells   = 140;     % 140S
VCU_batt_parallel_cells = 4;       % 4P
VCU_cell_voltage_min = 2.25;       % [V/cell]

VCU_derate_Vmin  = 315;   % [V] temporary tuning value
VCU_derate_Vfull = 350;   % [V] temporary tuning value

VCU_power_floor = 1;               % [W], prevents division by zero

VCU_drivetrain_efficiency = 0.80;   % [-] temporary approximation MUST CHANGE THE ENTIRE EFFICIENCY LOGIC LATER!!!!!!!!!!!!!!!!!!!

% Battery data for VCU derating
% Read directly from the battery model that is actually active.

if ~bdIsLoaded('Accumulator')
    repo_root = fileparts(mfilename('fullpath'));
    load_system(fullfile(repo_root, 'models', 'Accumulator.slx'));
end

batt_block = ...
    'Accumulator/P50_14s4pX10/ModuleAssembly10/P50_14s4p';

% Breakpoints
VCU_batt_soc_bp_ocv = ...
    str2num(get_param(batt_block, 'SOCBreakpointsCell'));

VCU_batt_soc_bp_r0 = ...
    str2num(get_param(batt_block, 'ResistanceSOCBreakpointsCell'));

VCU_batt_temp_bp_r0 = ...
    str2num(get_param(batt_block, 'ResistanceTemperatureBreakpointsCell'));

% Electrical tables
VCU_batt_ocv_table_full = ...
    str2num(get_param(batt_block, 'OpenCircuitVoltageThermalCell'));

VCU_batt_r0_table = ...
    str2num(get_param(batt_block, 'R0ThermalCell'));

% OCV is temperature-independent in this parameterization,
% so one column is sufficient for the 1-D SOC lookup.
VCU_batt_ocv_table = VCU_batt_ocv_table_full(:,1);

fprintf('VCU_torque_lpf_tau = %.6f s\n', VCU_torque_lpf_tau)
disp('DONE')