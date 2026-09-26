repo_root = fileparts(fileparts(fileparts(mfilename('fullpath'))));

old_folder = pwd;
cd(repo_root);

try
    run(fullfile(repo_root, 'data', 'inverter_efficiency_map.m'));
catch ME
    cd(old_folder);
    rethrow(ME);
end

cd(old_folder);

clear repo_root old_folder