function run_all_experiments(mode)
%RUN_ALL_EXPERIMENTS  Chay lai toan bo thi nghiem va sinh lai hinh, bang.
%
%   run_all_experiments            % mac dinh 'full'
%   run_all_experiments('full')    % kiem tra + 6 thi nghiem + xuat MAT/JSON + ve hinh (40 den 60 phut)
%   run_all_experiments('figures') % chi xuat MAT/JSON va ve lai hinh tu results/*.csv co san (khoang 1 phut)
%   run_all_experiments('quick')   % chi chay quick_test de kiem tra chuong trinh (khoang 1 phut)
%
%   Ket qua:
%     results/*.csv            bang so lieu dang van ban
%     results/*.mat            cung du lieu dang nhi phan MAT
%     results/all_results.mat  gom tat ca bang
%     results/params.json      tham so mo phong va moi truong chay
%     figures_matlab/*.png     toan bo hinh trong bao cao
if nargin < 1, mode = 'full'; end
here = fileparts(mfilename('fullpath'));
addpath(here, fullfile(here, 'lib'));
t0 = tic;
switch lower(mode)
    case 'quick'
        quick_test;
    case 'figures'
        export_results(fullfile(here, 'results'));
        make_figures;
    case 'full'
        quick_test;
        exp1_ber_vs_snr;
        exp2_led_bandwidth;
        exp3_dc_bias;
        exp4_papr;
        exp5_summary;
        exp6_bias_sweep;
        export_results(fullfile(here, 'results'));
        make_figures;
    otherwise
        error('mode phai la ''full'', ''figures'' hoac ''quick''');
end
fprintf('\nrun_all_experiments(''%s'') xong sau %.1f phut.\n', mode, toc(t0) / 60);
end
