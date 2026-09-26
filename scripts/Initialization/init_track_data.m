% Locate repository folders
init_dir    = fileparts(mfilename('fullpath'));
scripts_dir = fileparts(init_dir);
repo_root   = fileparts(scripts_dir);

% Save current folder so we can restore it afterwards
old_folder = pwd;

% Make original script available by name
addpath(scripts_dir);

% The original initialization script expects the repo root
% to be the current working directory because it uses:
% readtable('data\cones_continues.csv')
cd(repo_root);

try
    % IMPORTANT: call by name, do NOT use run(fullfile(...))
    Track_data_initialization;
catch ME
    cd(old_folder);
    rethrow(ME);
end

% Restore user's previous working directory
cd(old_folder);

clear init_dir scripts_dir repo_root old_folder