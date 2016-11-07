function clearDuplicateFiles(fDir)

d = dir(fDir);
bytes = [d.bytes];

del = false(1, numel(bytes));

for ii = 1:numel(bytes)
    if bytes(ii)
        same = find(bytes == bytes(ii));
        if numel(same) > 1
            del(same(2:end)) = true;
        end
    end
end

fNames = {d.name};
fNames = fNames(del);
fNames = strcat(fDir, '\', fNames);
if numel(fNames) > 0
    delete(fNames{:});
end

return;