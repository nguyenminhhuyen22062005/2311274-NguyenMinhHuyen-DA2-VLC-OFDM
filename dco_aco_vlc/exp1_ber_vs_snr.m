%% EXP1 - BER theo SNR cua DCO-OFDM va ACO-OFDM (cung N, cung M)
% Ket qua:
%   results/exp1_ber_elec.csv   BER theo Eb(elec)/N0 (co tinh cong suat DC)
%   results/exp1_ber_opt.csv    BER theo Eb(opt)/N0
%   results/exp1_ber_eqse.csv   so sanh cung hieu suat pho (ACO 16-QAM vs DCO 4-QAM,
%                               ACO 256-QAM vs DCO 16-QAM)
cfg = init_sim();
fprintf('\n===== EXP1: BER vs SNR =====\n');
base = default_opt();          % N = 128, Ncp = 16, M = 16
base.maxBits = 1e7;
EbN0 = 0:1:34;

%% (a) Eb(elec)/N0 - cung M = 16
cases = { 'aco', NaN;  'dco', 7;  'dco', 10;  'dco', 13 };
data = EbN0(:);
hdr  = {'EbN0dB'};
for c = 1:size(cases, 1)
    o = base; sch = cases{c, 1};
    if strcmp(sch, 'dco'), o.biasdB = cases{c, 2}; end
    r  = sim_link(sch, EbN0, o);
    th = ber_theory(sch, EbN0, o);
    tag = upper(sch); if strcmp(sch, 'dco'), tag = sprintf('DCO%d', o.biasdB); end
    data = [data, r.ber(:), th(:)];
    hdr  = [hdr, {[tag '_sim'], [tag '_th']}];
end
% gioi han OFDM luong cuc ly tuong (khong DC, khong clipping) cung 16-QAM
data = [data, ber_qam_awgn(16, 4*10.^(EbN0(:)/10))];
hdr  = [hdr, {'bipolar_ideal'}];
write_csv(fullfile(cfg.resDir, 'exp1_ber_elec.csv'), hdr, data);

%% (b) Eb(opt)/N0
o = base; o.snrMode = 'opt';
data2 = EbN0(:); hdr2 = {'EbN0optdB'};
cases2 = { 'aco', NaN; 'dco', 7; 'dco', 10; 'dco', 13 };
for c = 1:size(cases2, 1)
    oo = o; sch = cases2{c, 1};
    if strcmp(sch, 'dco'), oo.biasdB = cases2{c, 2}; end
    r  = sim_link(sch, EbN0, oo);
    th = ber_theory(sch, EbN0, oo);
    tag = upper(sch); if strcmp(sch, 'dco'), tag = sprintf('DCO%d', oo.biasdB); end
    data2 = [data2, r.ber(:), th(:)];
    hdr2  = [hdr2, {[tag '_sim'], [tag '_th']}];
end
write_csv(fullfile(cfg.resDir, 'exp1_ber_opt.csv'), hdr2, data2);

%% (c) Cung hieu suat pho (bias DCO = bias toi uu tim bang giai tich)
pairs = { 'aco', 16, NaN;  'dco', 4, NaN;  'aco', 256, NaN;  'dco', 16, NaN };
data3 = EbN0(:); hdr3 = {'EbN0dB'};
for c = 1:size(pairs, 1)
    o = base; sch = pairs{c, 1}; o.M = pairs{c, 2};
    if strcmp(sch, 'dco')
        o.biasdB = optimum_bias(o, cfg.target);
        fprintf('  DCO %d-QAM: bias toi uu = %.2f dB\n', o.M, o.biasdB);
    end
    r  = sim_link(sch, EbN0, o);
    th = ber_theory(sch, EbN0, o);
    tag = sprintf('%s%d', upper(sch), o.M);
    data3 = [data3, r.ber(:), th(:)];
    hdr3  = [hdr3, {[tag '_sim'], [tag '_th']}];
    if strcmp(sch, 'dco'), fprintf('  %s: SE = %.3f bit/s/Hz, bias = %g dB\n', tag, r.se, o.biasdB);
    else, fprintf('  %s: SE = %.3f bit/s/Hz (khong can bias)\n', tag, r.se); end
end
write_csv(fullfile(cfg.resDir, 'exp1_ber_eqse.csv'), hdr3, data3);

%% Ve hinh (MATLAB)
if cfg.plot
    figure; hold on; grid on; box on;
    semilogy(EbN0, data(:, 2), 'bo', EbN0, data(:, 3), 'b-');
    semilogy(EbN0, data(:, 4), 'rs', EbN0, data(:, 5), 'r-');
    semilogy(EbN0, data(:, 6), 'm^', EbN0, data(:, 7), 'm-');
    semilogy(EbN0, data(:, 8), 'kd', EbN0, data(:, 9), 'k-');
    semilogy(EbN0, data(:, 10), 'k--');
    set(gca, 'YScale', 'log'); ylim([1e-6 1]);
    xlabel('E_{b(elec)}/N_0 (dB)'); ylabel('BER');
    legend('ACO sim', 'ACO ly thuyet', 'DCO 7dB sim', 'DCO 7dB ly thuyet', ...
           'DCO 10dB sim', 'DCO 10dB ly thuyet', 'DCO 13dB sim', 'DCO 13dB ly thuyet', ...
           'OFDM luong cuc (16-QAM)', 'Location', 'southwest');
    title('BER vs E_{b(elec)}/N_0, N = 128, 16-QAM');
    save_fig(cfg, 'exp1_ber_elec');
end
