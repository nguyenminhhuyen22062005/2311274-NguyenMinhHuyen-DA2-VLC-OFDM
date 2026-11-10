%% EXP5 - Bang tong hop: BER, hieu suat pho, SNR yeu cau, PAPR, cac danh doi
% Voi moi bac dieu che M: SNR yeu cau @ BER = 1e-3 (mo phong + giai tich),
% DCO dung bias toi uu (tim bang giai tich), ca theo Eb(elec)/N0 va Eb(opt)/N0.
% Ket qua: results/exp5_summary.csv
cfg = init_sim();
fprintf('\n===== EXP5: Summary =====\n');
base = default_opt(); base.maxBits = 1e7;
rows = [];
list = { 'aco', 4; 'aco', 16; 'aco', 64; 'aco', 256; 'dco', 4; 'dco', 16; 'dco', 64 };
for c = 1:size(list, 1)
    sch = list{c, 1}; M = list{c, 2};
    o = base; o.M = M;
    if strcmp(sch, 'dco')
        o.biasdB = optimum_bias(o, cfg.target);
    else
        o.biasdB = NaN;
    end
    % Eb(elec)/N0
    st = required_snr_theory(sch, cfg.target, o);
    sgrid = floor(st) - 3 : 0.5 : ceil(st) + 4;
    oo = o; oo.verbose = false; oo.minBER = 1e-4;
    r = sim_link(sch, sgrid, oo);
    ss = required_snr(sgrid, r.ber, cfg.target);
    % BER tai Eb(elec)/N0 = 20 dB
    r20 = sim_link(sch, 20, oo);
    % Eb(opt)/N0
    oo.snrMode = 'opt'; o2 = o; o2.snrMode = 'opt';
    sto = required_snr_theory(sch, cfg.target, o2);
    sgrid = floor(sto) - 3 : 0.5 : ceil(sto) + 4;
    r = sim_link(sch, sgrid, oo);
    sso = required_snr(sgrid, r.ber, cfg.target);
    isd = strcmp(sch, 'dco');
    rows = [rows; isd, M, r.se, o.biasdB, st, ss, sto, sso, r20.ber];
    fprintf('  %s %3d-QAM  SE=%.3f  bias=%5.2f  Eb(elec)/N0 req: th %.2f sim %.2f | Eb(opt)/N0 req: th %.2f sim %.2f | BER@20dB=%.2e\n', ...
        upper(sch), M, r.se, o.biasdB, st, ss, sto, sso, r20.ber);
end
write_csv(fullfile(cfg.resDir, 'exp5_summary.csv'), ...
    {'isDCO', 'M', 'SE', 'biasdB', 'req_elec_th', 'req_elec_sim', 'req_opt_th', 'req_opt_sim', 'BER_at_20dB'}, rows);
