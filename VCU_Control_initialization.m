% VCU Control parameters

% Rate limiter
VCU_torque_rise_rate = 4000;   % [Nm/s] TESTING VALUE NON FINAL!
VCU_torque_fall_rate = -8000;  % [Nm/s] TESTING VALUE NON FINAL!

% Low-pass filter
VCU_torque_lpf_fc = 10;   % [Hz] TEMPORARY
VCU_torque_lpf_tau = 1 / (2*pi*VCU_torque_lpf_fc);   % [sec]

% Power limiting
VCU_max_power = 75e3;       % [W] TEMPORARY, note that 75K is the mechanical power and not the actual power outputted by the battery
VCU_omega_floor = 1;        % [rad/s], prevents division by zero

fprintf('VCU_torque_lpf_tau = %.6f s\n', VCU_torque_lpf_tau)
disp('DONE')