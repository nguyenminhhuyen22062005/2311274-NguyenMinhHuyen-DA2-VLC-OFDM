function fig_save(f, outdir, name)
% FIG_SAVE  Luu figure ra <outdir>/<name>.png (200 dpi) roi dong lai.
if ~exist(outdir, 'dir'), mkdir(outdir); end
print(f, fullfile(outdir, [name '.png']), '-dpng', '-r200');
close(f);
fprintf('  da luu %s.png\n', name);
end
