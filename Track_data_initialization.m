track_data = readtable('speed-km with drag and without.csv');

% 1. קריאת קובץ ה-CSV המלא לתוך טבלה במאטלאב
track_data = readtable('speed-km with drag and without.csv');

% 2. הכנת נתוני המהירות והזמן (עבור אופציה 1 - סימולציית דינמיקת רכב)
Drive_Cycle_Data = timeseries(track_data.speed, track_data.elapsedTime);
Drive_Cycle_Data.Data = Drive_Cycle_Data.Data / 3.6; % המרה מקמ"ש למטר לשנייה

% 3. התוספת החדשה: חילוץ הסל"ד והמומנט (עבור אופציה 2 - שליטה ישירה במנוע)
% הערה: החלף את השמות 'Engine_Speed' ו-'Engine_Torque' לשמות המדויקים של העמודות בקובץ שלך.
Motor_RPM_Data = timeseries(track_data.engineSpeed, track_data.elapsedTime);
Motor_Torque_Data = timeseries(track_data.torque, track_data.elapsedTime);