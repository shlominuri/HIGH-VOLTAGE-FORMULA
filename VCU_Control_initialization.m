% VCU Control parameters

VCU_torque_rise_rate = 50;   % [Nm/s]
VCU_torque_fall_rate = -50;  % [Nm/s]

VCU_torque_lpf_fc = 10;   % [Hz] TEMPORARY
VCU_torque_lpf_tau = 1 / (2*pi*VCU_torque_lpf_fc);   % [sec]

disp('DONE')