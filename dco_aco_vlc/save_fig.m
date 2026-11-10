function save_fig(cfg, name)
% SAVE_FIG  Luu hinh hien tai ra figures/<name>.png (200 dpi) va .fig (MATLAB)
print(gcf, fullfile(cfg.figDir, [name '.png']), '-dpng', '-r200');
if ~cfg.isOctave
    savefig(gcf, fullfile(cfg.figDir, [name '.fig']));
end
end
