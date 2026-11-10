function d = default_opt()
% DEFAULT_OPT  Tham so mo phong mac dinh (dung chung cho DCO va ACO).
d.N         = 128;     % kich thuoc FFT (giong nhau cho 2 he thong)
d.Ncp       = 16;      % CP = N/8
d.M         = 16;      % 16-QAM (giong nhau cho 2 he thong)
d.biasdB    = 7;       % DC bias DCO (dB), ~ mu = 2 (2 sigma)
d.clipTop   = Inf;     % khong gioi han tren
d.beta      = Inf;     % LED ly tuong
d.snrMode   = 'elec';
d.nSymBatch = 1000;
d.minErr    = 200;
d.maxBits   = 4e6;
d.minBER    = 1e-6;
d.verbose   = true;
end
