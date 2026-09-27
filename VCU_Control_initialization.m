% VCU Control parameters

% Rate limiter
VCU_torque_rise_rate = 2000;   % [Nm/s] TESTING VALUE NON FINAL!
VCU_torque_fall_rate = -4000;  % [Nm/s] TESTING VALUE NON FINAL!

% Low-pass filter
VCU_torque_lpf_fc = 10;   % [Hz] TEMPORARY
VCU_torque_lpf_tau = 1 / (2*pi*VCU_torque_lpf_fc);   % [sec]

% Power limiting
VCU_max_power = 75e3;       % [W] TEMPORARY, note that 75K is the mechanical power and not the actual power outputted by the battery
VCU_omega_floor = 1;        % [rad/s], prevents division by zero

VCU_batt_series_cells   = 140;     % 140S
VCU_batt_parallel_cells = 4;       % 4P
VCU_cell_voltage_min = 2.25;       % [V/cell]

VCU_derate_Vmin  = 315;   % [V] temporary tuning value
VCU_derate_Vfull = 350;   % [V] temporary tuning value

VCU_power_floor = 1;               % [W], prevents division by zero

% Battery lookup tables used by VCU derating
%VCU_batt_soc_bp_ocv = ModuleType1.SOCBreakpointsCell;
%VCU_batt_ocv_table  = ModuleType1.OpenCircuitVoltageThermalCell(:,1);

%VCU_batt_soc_bp_r0  = ModuleType1.ResistanceSOCBreakpointsCell;
%VCU_batt_temp_bp_r0 = ModuleType1.ResistanceTemperatureBreakpointsCell;
%VCU_batt_r0_table   = ModuleType1.R0ThermalCell;

fprintf('VCU_torque_lpf_tau = %.6f s\n', VCU_torque_lpf_tau)
disp('DONE')