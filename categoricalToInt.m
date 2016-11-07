categories_str = cell(1,9);
for k=1:9
    cir = sprintf('CIR%d',k);
    categories_str{k} = cir;
end
categories_int = 1:9;
category_map = containers.Map(categories_str,categories_int');

labels_int = zeros(size(label));

for k=1:length(labels_int)
    labels_int(k) = category_map(char(label(k)));
end