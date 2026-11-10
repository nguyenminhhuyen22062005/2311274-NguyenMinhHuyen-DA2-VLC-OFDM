function export_results(resDir)
% EXPORT_RESULTS  Chuyen toan bo ket qua CSV sang MAT va JSON.
%   - results/<ten>.mat   : cung du lieu voi <ten>.csv (bien header, data, T)
%   - results/all_results.mat : gom tat ca bang vao mot struct R
%   - results/params.json : tham so mo phong mac dinh va moi truong chay
if nargin < 1
    resDir = fullfile(fileparts(fileparts(mfilename('fullpath'))), 'results');
end
f = dir(fullfile(resDir, '*.csv'));
R = struct();
for k = 1:numel(f)
    [~, name] = fileparts(f(k).name);
    fid = fopen(fullfile(resDir, f(k).name), 'r');
    header = strsplit(strtrim(fgetl(fid)), ',');
    fclose(fid);
    data = dlmread(fullfile(resDir, f(k).name), ',', 1, 0);
    T = csv_named(fullfile(resDir, f(k).name));
    save(fullfile(resDir, [name '.mat']), 'header', 'data', 'T', '-v7');
    R.(matlab.lang.makeValidName(name)) = T;
end
save(fullfile(resDir, 'all_results.mat'), 'R', '-v7');

P = default_opt();
P.target_BER = 1e-3;
P.seed = 2026;
P.bias_dB_definition = '10*log10(1+mu^2), B_DC = mu*sigma';
P.beta_definition = 'fc/(fs/2), LED bac 1, impulse invariance';
P.snr_definition = 'Eb/N0 = N*P/(2*nb*sigma_n^2); elec: P=E[y^2], opt: P=(E[y])^2';
P.spectral_efficiency = 'log2(M)*Nd/(N+Ncp), quy uoc B = fs';
P.exp_maxBits = struct('exp1', 1e7, 'exp2', 4e6, 'exp3', 1e7, 'exp4', 0, 'exp5', 1e7);
if exist('OCTAVE_VERSION', 'builtin') ~= 0
    P.environment = ['GNU Octave ' OCTAVE_VERSION];
else
    P.environment = ['MATLAB ' version];
end
P.note = 'null trong JSON nghia la Inf: clipTop = Inf la khong xen tren, beta = Inf la LED ly tuong';
P.exported = datestr(now, 'yyyy-mm-dd HH:MM:SS');
fid = fopen(fullfile(resDir, 'params.json'), 'w');
fprintf(fid, '%s\n', jsonencode(P));
fclose(fid);
fprintf('Da xuat %d bang sang MAT, all_results.mat va params.json trong %s\n', numel(f), resDir);
end
