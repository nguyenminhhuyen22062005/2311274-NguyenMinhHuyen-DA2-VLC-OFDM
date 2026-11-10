function cfg = init_sim()
% INIT_SIM  Khoi tao duong dan, thu muc ket qua, seed ngau nhien.
here = fileparts(mfilename('fullpath'));
addpath(fullfile(here, 'lib'));
cfg.resDir = fullfile(here, 'results');
cfg.figDir = fullfile(here, 'figures');
if ~exist(cfg.resDir, 'dir'), mkdir(cfg.resDir); end
if ~exist(cfg.figDir, 'dir'), mkdir(cfg.figDir); end
cfg.isOctave = exist('OCTAVE_VERSION', 'builtin') ~= 0;
% Ve hinh trong MATLAB; Octave chay khong giao dien thi tat (dat bien moi
% truong VLC_PLOT=1 de bat).
cfg.plot = ~cfg.isOctave || strcmp(getenv('VLC_PLOT'), '1');
cfg.seed = 2026;
try
    rng(cfg.seed);
catch
    rand('state', cfg.seed); randn('state', cfg.seed);
end
cfg.target = 1e-3;          % BER muc tieu de tinh SNR yeu cau / power penalty
end
