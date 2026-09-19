% 1. קריאת קובץ ה-CSV לתוך טבלה במטלאב
track_data = readtable('data\track with cones new and improved.csv');

% --- תוספת לסימולציית Endurance ---
num_laps = 26; % מספר הקפות
lap_duration = track_data.elapsedTime(end); % משך זמן של הקפה בודדת
N_samples = length(track_data.elapsedTime); % מספר הדגימות בהקפה אחת

% 2. שכפול וקטורי הנתונים 26 פעמים בעזרת repmat
full_speed  = repmat(track_data.speed, num_laps, 1);
full_rpm    = repmat(track_data.engineSpeed, num_laps, 1);
full_torque = repmat(track_data.torque, num_laps, 1);

% 3. יצירת וקטור זמן רציף מ-0 ועד סוף המרוץ
full_time = repmat(track_data.elapsedTime, num_laps, 1);
for i = 1:num_laps
    % חישוב אינדקסים לכל הקפה בנפרד
    idx_start = (i-1)*N_samples + 1;
    idx_end   = i*N_samples;
    % הוספת זמן ההקפה המצטבר לכל מחזור (ההקפה הראשונה מקבלת +0)
    full_time(idx_start:idx_end) = full_time(idx_start:idx_end) + (i-1)*lap_duration;
end
% ---------------------------------

% 4. הכנת נתוני המהירות והזמן (עבור אופציה 1 - סימולציית דינמיקת רכב)
Drive_Cycle_Data = timeseries(full_speed, full_time);
Drive_Cycle_Data.Data = Drive_Cycle_Data.Data / 3.6; % המרה מקמ"ש למטר לשנייה

% 5. התוספת החדשה: חילוץ הסל"ד והמומנט (עבור אופציה 2 - שליטה ישירה במנוע)
Motor_RPM_Data = timeseries(full_rpm, full_time);
Motor_Torque_Data = timeseries(full_torque, full_time);
