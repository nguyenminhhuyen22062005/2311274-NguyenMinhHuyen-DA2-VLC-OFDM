function write_csv(fname, header, data)
% WRITE_CSV  Ghi ma tran so ra file CSV kem dong tieu de (MATLAB & Octave).
fid = fopen(fname, 'w');
fprintf(fid, '%s', header{1});
for i = 2:numel(header), fprintf(fid, ',%s', header{i}); end
fprintf(fid, '\n');
for r = 1:size(data, 1)
    fprintf(fid, '%.10g', data(r, 1));
    for c = 2:size(data, 2), fprintf(fid, ',%.10g', data(r, c)); end
    fprintf(fid, '\n');
end
fclose(fid);
end
