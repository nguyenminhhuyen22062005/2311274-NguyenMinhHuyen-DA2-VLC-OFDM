function T = csv_named(fname)
% CSV_NAMED  Doc file CSV (dong dau la ten cot) thanh struct, moi cot la mot truong.
% Ten cot duoc loc bo ky tu dac biet (vd 'ACO_b0.1_sim' -> 'ACO_b01_sim').
fid = fopen(fname, 'r');
if fid < 0, error('Khong mo duoc file %s', fname); end
hdr = fgetl(fid);
names = strsplit(strtrim(hdr), ',');
C = textscan(fid, repmat('%f', 1, numel(names)), 'Delimiter', ',', 'CollectOutput', true);
fclose(fid);
M = C{1};
T = struct();
for i = 1:numel(names)
    nm = regexprep(names{i}, '[^A-Za-z0-9_]', '');
    if isempty(nm) || ~isempty(regexp(nm, '^[0-9]', 'once')), nm = ['c' nm]; end
    T.(nm) = M(:, i);
end
end
